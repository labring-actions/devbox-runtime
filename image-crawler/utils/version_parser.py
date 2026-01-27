"""Tag parsing, categorisation, and metadata helpers."""

from __future__ import annotations

import fnmatch
import re
from dataclasses import dataclass, field
from typing import Any, Dict, Iterable, List, Optional, Tuple, cast

from packaging.version import InvalidVersion, Version

from config.config import CrawlConfig
from utils.ghcr_client import TagInfo


@dataclass
class ImageVersion:
    name: str
    component: str
    runtime_version: str
    registry: str
    repository: str
    version: str
    full_tag: str
    category: str
    is_versioned: bool
    created_at: Optional[str]
    updated_at: Optional[str]
    size: Optional[int]
    digest: Optional[str]
    source: str
    version_type: str
    architectures: List[str] = field(default_factory=list)
    parsed_version: Optional[Version] = field(default=None, repr=False, compare=False)

    @property
    def image_path(self) -> str:
        return f"{self.registry}/{self.repository}/{self.name}"

    def to_dict(self) -> Dict[str, object]:
        return {
            "name": self.name,
            "component": self.component,
            "runtime_version": self.runtime_version,
            "registry": self.registry,
            "repository": self.repository,
            "version": self.version,
            "full_tag": self.full_tag,
            "image_path": self.image_path,
            "category": self.category,
            "is_versioned": self.is_versioned,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "size": self.size,
            "digest": self.digest,
            "source": self.source,
        }


class VersionParser:
    def __init__(self, config: Optional[CrawlConfig] = None) -> None:
        self.config = config or CrawlConfig()
        self._category_patterns: Dict[str, List[re.Pattern[str]]] = {
            category: [re.compile(pattern, re.IGNORECASE) for pattern in patterns]
            for category, patterns in self.config.categories.items()
        }
        self._numeric_re = re.compile(r"^\d+(?:[._-]\d+)*$")

    def parse_tags(self, tags: Iterable[TagInfo], pattern: Optional[str] = None) -> List[ImageVersion]:
        results: List[ImageVersion] = []
        seen: set[str] = set()

        for tag_info in tags:
            tag_value = tag_info.tag
            if not tag_value.lower().startswith("v"):
                continue
            if pattern and not self._matches_pattern(tag_info, pattern):
                continue

            category = tag_info.category or self._categorize(tag_info.image)
            version_type, parsed_version = self._classify_version(tag_value)
            image = ImageVersion(
                name=tag_info.image,
                component=tag_info.component,
                runtime_version=tag_info.runtime_version,
                registry=tag_info.registry,
                repository=tag_info.repository,
                version=tag_value,
                full_tag=tag_info.image_ref,
                category=category,
                is_versioned=True,
                created_at=tag_info.created_at,
                updated_at=tag_info.updated_at,
                size=tag_info.size,
                digest=tag_info.digest,
                source=tag_info.source,
                version_type=version_type,
                parsed_version=parsed_version,
            )
            key = f"{image.full_tag}:{image.digest or ''}"
            if key in seen:
                continue
            seen.add(key)
            results.append(image)

        results.sort(key=lambda img: (img.category, img.name, img.version))
        return results

    def summarize_by_category(self, versions: Iterable[ImageVersion]) -> Dict[str, Dict[str, int]]:
        summary: Dict[str, Dict[str, int]] = {}
        for image in versions:
            bucket = summary.setdefault(image.category, {"count": 0, "versioned": 0})
            bucket["count"] += 1
            if image.is_versioned:
                bucket["versioned"] += 1
        return summary

    def filter_latest_versions(self, versions: List[ImageVersion]) -> List[ImageVersion]:
        buckets: Dict[Tuple[str, str], Dict[str, Any]] = {}

        for image in versions:
            key = (image.category, image.name)
            version_key = self._version_value(image.version)
            bucket = buckets.get(key)

            if bucket is None or self._is_newer_version(version_key, bucket["version_key"]):
                buckets[key] = {"version_key": version_key, "images": [image]}
            elif self._is_same_version(version_key, bucket["version_key"]):
                bucket_images = cast(List[ImageVersion], bucket["images"])
                bucket_images.append(image)

        filtered: List[ImageVersion] = []
        for bucket in buckets.values():
            bucket_images = cast(List[ImageVersion], bucket["images"])
            bucket_images.sort(key=lambda img: (img.version.endswith("-cn"), img.version))
            filtered.extend(bucket_images)

        filtered.sort(key=lambda img: (img.category, img.name, img.version))
        return filtered

    # ------------------------------------------------------------------
    # Helpers

    def _matches_pattern(self, tag_info: TagInfo, pattern: str) -> bool:
        targets = [
            tag_info.tag,
            tag_info.image,
            tag_info.image_ref,
            f"{tag_info.image}:{tag_info.tag}",
        ]
        return any(fnmatch.fnmatch(target, pattern) for target in targets)

    def _categorize(self, value: str) -> str:
        for category, patterns in self._category_patterns.items():
            if any(pattern.search(value) for pattern in patterns):
                return category
        return self.config.default_category

    def _classify_version(self, version: str) -> Tuple[str, Optional[Version]]:
        lowered = version.lower()
        if lowered.startswith("v") and len(version) > 1 and version[1].isdigit():
            return self._attempt_version(version[1:], preferred="versioned")
        if lowered in {"latest", "stable", "edge"}:
            return "latest", None
        try:
            parsed = Version(version)
            return "semver", parsed
        except InvalidVersion:
            pass
        if self._numeric_re.match(version):
            return "numeric", None
        return "other", None

    def _attempt_version(self, candidate: str, preferred: str) -> Tuple[str, Optional[Version]]:
        try:
            parsed = Version(candidate)
            return preferred, parsed
        except InvalidVersion:
            return preferred, None

    def _version_value(self, version: str) -> Tuple[Optional[Version], str]:
        cleaned = version.lstrip("v").lower()
        if cleaned.endswith("-cn"):
            cleaned = cleaned[:-3]
        try:
            parsed = Version(cleaned)
        except InvalidVersion:
            parsed = None
        return parsed, cleaned

    @staticmethod
    def _is_newer_version(candidate: Tuple[Optional[Version], str], current: Tuple[Optional[Version], str]) -> bool:
        cand_parsed, cand_base = candidate
        curr_parsed, curr_base = current
        if cand_parsed is not None and curr_parsed is not None:
            return cand_parsed > curr_parsed
        if cand_parsed is not None and curr_parsed is None:
            return True
        if cand_parsed is None and curr_parsed is not None:
            return False
        return cand_base > curr_base

    @staticmethod
    def _is_same_version(candidate: Tuple[Optional[Version], str], current: Tuple[Optional[Version], str]) -> bool:
        cand_parsed, cand_base = candidate
        curr_parsed, curr_base = current
        if cand_parsed is not None and curr_parsed is not None:
            return cand_parsed == curr_parsed
        return cand_base == curr_base
