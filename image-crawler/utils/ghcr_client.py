"""Fetch DevBox image tags via the crane CLI."""

from __future__ import annotations

import asyncio
import json
import logging
import shlex
from dataclasses import dataclass
from typing import Any, Callable, Dict, Iterable, List, Optional, Tuple
from urllib.parse import urlparse

from asyncio.subprocess import PIPE
from config.config import ClientConfig
from utils.runtime_inventory import RuntimeImage

logger = logging.getLogger(__name__)


@dataclass
class TagInfo:
    image: str
    tag: str
    category: str
    component: str
    runtime_version: str
    repository: str
    registry: str
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    digest: Optional[str] = None
    size: Optional[int] = None
    source: str = "crane"

    @property
    def image_ref(self) -> str:
        return f"{self.registry}/{self.repository}/{self.image}:{self.tag}"


class GHCRClient:
    def __init__(self, config: Optional[ClientConfig] = None, *, crane_bin: str = "crane") -> None:
        self.config = config or ClientConfig()
        parsed = urlparse(self.config.base_registry_url)
        self.registry = parsed.netloc or self.config.base_registry_url.replace("https://", "").replace("http://", "")
        if not self.registry:
            raise ValueError("Invalid registry base URL configured")
        self.repository = self.config.repository.strip("/")
        self.crane_bin = crane_bin
        self._semaphore = asyncio.Semaphore(self.config.concurrent_requests)
        self._command_timeout = self.config.request_timeout

    async def get_all_tags(
        self,
        runtimes: Iterable[RuntimeImage],
        progress_cb: Optional[Callable[[int], None]] = None,
    ) -> List[TagInfo]:
        tasks = [asyncio.create_task(self._fetch_runtime_tags(runtime, progress_cb)) for runtime in runtimes]
        results: List[TagInfo] = []
        for task in asyncio.as_completed(tasks):
            try:
                results.extend(await task)
            except Exception as exc:  # noqa: BLE001
                logger.warning("Failed to fetch tags: %s", exc)
        return results

    async def get_architectures(self, image_refs: Iterable[str]) -> Dict[str, List[str]]:
        unique_refs = list(dict.fromkeys(image_refs))
        tasks = [asyncio.create_task(self._fetch_architectures(image_ref)) for image_ref in unique_refs]
        results: Dict[str, List[str]] = {}
        for task in asyncio.as_completed(tasks):
            try:
                image_ref, archs = await task
                results[image_ref] = archs
            except Exception as exc:  # noqa: BLE001
                logger.warning("Failed to fetch architectures: %s", exc)
        return results

    async def _fetch_runtime_tags(self, runtime: RuntimeImage, progress_cb: Optional[Callable[[int], None]]) -> List[TagInfo]:
        image_repo = f"{self.registry}/{self.repository}/{runtime.image_name}"
        try:
            output = await self._run_crane(["ls", image_repo])
        except RuntimeError as exc:
            logger.warning("Unable to list tags for %s: %s", image_repo, exc)
            return []

        tags = [line.strip() for line in output.splitlines() if line.strip()]
        records: List[TagInfo] = []
        for tag in tags:
            records.append(
                TagInfo(
                    image=runtime.image_name,
                    tag=tag,
                    category=runtime.normalized_category,
                    component=runtime.component,
                    runtime_version=runtime.variant,
                    repository=self.repository,
                    registry=self.registry,
                )
            )
            if progress_cb:
                progress_cb(1)
        return records

    async def _fetch_architectures(self, image_ref: str) -> Tuple[str, List[str]]:
        try:
            manifest_raw = await self._run_crane(["manifest", image_ref])
        except RuntimeError as exc:
            logger.warning("Unable to inspect manifest for %s: %s", image_ref, exc)
            return image_ref, []
        manifest = self._parse_json(manifest_raw, image_ref, "manifest")
        if manifest:
            archs = self._extract_architectures(manifest)
            if archs:
                return image_ref, archs
        try:
            config_raw = await self._run_crane(["config", image_ref])
        except RuntimeError as exc:
            logger.warning("Unable to inspect config for %s: %s", image_ref, exc)
            return image_ref, []
        config = self._parse_json(config_raw, image_ref, "config")
        if config:
            return image_ref, self._extract_architectures(config)
        return image_ref, []

    def _parse_json(self, raw: str, image_ref: str, label: str) -> Optional[Dict[str, Any]]:
        try:
            return json.loads(raw)
        except json.JSONDecodeError as exc:
            logger.warning("Unable to parse %s JSON for %s: %s", label, image_ref, exc)
            return None

    def _extract_architectures(self, payload: Dict[str, Any]) -> List[str]:
        archs: set[str] = set()
        manifests = payload.get("manifests")
        if isinstance(manifests, list):
            for entry in manifests:
                platform = entry.get("platform", {}) if isinstance(entry, dict) else {}
                arch = self._normalize_arch_field(platform.get("architecture"))
                if not arch:
                    continue
                variant = self._normalize_arch_field(platform.get("variant"))
                archs.add(self._format_arch(arch, variant))
        if archs:
            return sorted(archs)
        arch = self._normalize_arch_field(payload.get("architecture"))
        if arch:
            variant = self._normalize_arch_field(payload.get("variant"))
            archs.add(self._format_arch(arch, variant))
        return sorted(archs)

    @staticmethod
    def _format_arch(arch: str, variant: Optional[str]) -> str:
        return f"{arch}/{variant}" if variant else arch

    @staticmethod
    def _normalize_arch_field(value: Any) -> Optional[str]:
        if not isinstance(value, str):
            return None
        cleaned = value.strip()
        if not cleaned or cleaned.lower() == "unknown":
            return None
        return cleaned

    async def _run_crane(self, args: List[str]) -> str:
        cmd = [self.crane_bin, *args]
        attempts = self.config.retry.attempts
        backoff = 1.0
        for attempt in range(1, attempts + 1):
            async with self._semaphore:
                proc = await asyncio.create_subprocess_exec(*cmd, stdout=PIPE, stderr=PIPE)
                try:
                    stdout, stderr = await asyncio.wait_for(proc.communicate(), timeout=self._command_timeout)
                except asyncio.TimeoutError:
                    proc.kill()
                    await proc.communicate()
                    stdout, stderr = b"", f"crane timed out after {self._command_timeout}s".encode()
            if proc.returncode == 0:
                return stdout.decode()
            message = stderr.decode().strip() or stdout.decode().strip() or "unknown error"
            if attempt == attempts:
                raise RuntimeError(f"crane {' '.join(shlex.quote(arg) for arg in args)} failed: {message}")
            await asyncio.sleep(backoff)
            backoff = min(backoff * self.config.retry.backoff_factor, self.config.retry.max_backoff)
