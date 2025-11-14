"""Fetch DevBox image tags via the crane CLI."""

from __future__ import annotations

import asyncio
import logging
import shlex
from dataclasses import dataclass
from typing import Callable, Iterable, List, Optional
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

    async def _run_crane(self, args: List[str]) -> str:
        cmd = [self.crane_bin, *args]
        attempts = self.config.retry.attempts
        backoff = 1.0
        for attempt in range(1, attempts + 1):
            async with self._semaphore:
                proc = await asyncio.create_subprocess_exec(*cmd, stdout=PIPE, stderr=PIPE)
                stdout, stderr = await proc.communicate()
            if proc.returncode == 0:
                return stdout.decode()
            message = stderr.decode().strip() or stdout.decode().strip() or "unknown error"
            if attempt == attempts:
                raise RuntimeError(f"crane {' '.join(shlex.quote(arg) for arg in args)} failed: {message}")
            await asyncio.sleep(backoff)
            backoff = min(backoff * self.config.retry.backoff_factor, self.config.retry.max_backoff)
