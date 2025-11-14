"""Console + file output helpers for the image crawler."""

from __future__ import annotations

import csv
import json
import os
from datetime import datetime
from typing import Any, Dict, Iterable, List, Optional

from colorama import Fore, Style, init

from utils.version_parser import ImageVersion


class OutputFormatter:
    def __init__(self, enable_color: bool = True) -> None:
        self.enable_color = enable_color
        init(autoreset=True)
        self.color_map = {
            "versioned": Fore.GREEN + Style.BRIGHT,
            "semver": Fore.CYAN + Style.BRIGHT,
            "latest": Fore.YELLOW + Style.BRIGHT,
            "numeric": Fore.BLUE,
            "other": Fore.WHITE,
        }
        self.icons = {
            "versioned": "✅",
            "semver": "🆕",
            "latest": "⚡",
            "numeric": "📦",
            "other": "•",
        }

    async def output_console(self, versions: Iterable[ImageVersion], metadata: Dict[str, Any]) -> None:
        versions_list = list(versions)
        header = "🔍 DevBox Runtime 镜像版本爬取结果"
        divider = "=" * max(len(header), 40)
        print(header)
        print(divider)
        print()
        print("📊 统计信息:")
        print(f"总镜像数: {metadata.get('total_count', len(versions_list))}")
        categories = metadata.get("categories", {})
        for category in sorted(categories):
            bucket = categories[category]
            count = bucket.get("count", 0)
            versioned = bucket.get("versioned", 0)
            print(f"- {category}: {count} (其中 v 开头版本: {versioned})")
        print()
        print("📋 镜像版本列表 (按类别、名称排序，展示 类别 | 名称 | 版本 | 镜像全路径):")
        for image in versions_list:
            icon = self.icons.get(image.version_type, self.icons["other"])
            label = self._apply_color(image.version, image.version_type)
            line = (
                f"{icon} "
                f"{image.category:<10} "
                f"{image.name:<30} "
                f"{label:<12} "
                f"{image.full_tag}"
            )
            print(line)

    async def output_json(self, versions: Iterable[ImageVersion], metadata: Dict[str, Any], filename: str) -> None:
        directory = os.path.dirname(filename) or "."
        os.makedirs(directory, exist_ok=True)
        payload = {
            "metadata": metadata,
            "images": [image.to_dict() for image in versions],
        }
        with open(filename, "w", encoding="utf-8") as fp:
            json.dump(payload, fp, indent=2, ensure_ascii=False)

    async def output_csv(self, versions: Iterable[ImageVersion], filename: str) -> None:
        directory = os.path.dirname(filename) or "."
        os.makedirs(directory, exist_ok=True)
        fieldnames = [
            "category",
            "name",
            "component",
            "runtime_version",
            "version",
            "full_tag",
            "image_path",
            "registry",
            "repository",
            "is_versioned",
            "created_at",
            "updated_at",
            "size",
            "digest",
            "source",
        ]
        with open(filename, "w", encoding="utf-8", newline="") as fp:
            writer = csv.DictWriter(fp, fieldnames=fieldnames)
            writer.writeheader()
            for image in versions:
                writer.writerow(image.to_dict())

    def build_metadata(self, versions: Iterable[ImageVersion], crawl_time: Optional[datetime] = None) -> Dict[str, Any]:
        versions_list = list(versions)
        categories: Dict[str, Dict[str, int]] = {}
        for image in versions_list:
            bucket = categories.setdefault(image.category, {"count": 0, "versioned": 0})
            bucket["count"] += 1
            if image.is_versioned:
                bucket["versioned"] += 1
        timestamp = (crawl_time or datetime.utcnow()).replace(microsecond=0).isoformat() + "Z"
        return {
            "total_count": len(versions_list),
            "categories": categories,
            "crawl_time": timestamp,
        }

    def _apply_color(self, value: str, version_type: str) -> str:
        if not self.enable_color:
            return value
        color = self.color_map.get(version_type, self.color_map["other"])
        return f"{color}{value}{Style.RESET_ALL}"
