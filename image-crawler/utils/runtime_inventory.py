"""Helpers for discovering runtime images from the repo structure."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import List

CATEGORY_MAP = {
    "languages": "language",
    "frameworks": "framework",
    "services": "service",
    "operating-systems": "os",
}


@dataclass
class RuntimeImage:
    category: str
    component: str
    variant: str
    image_name: str
    dockerfile: Path

    @property
    def normalized_category(self) -> str:
        return CATEGORY_MAP.get(self.category, self.category)


def discover_runtime_images(root: Path) -> List[RuntimeImage]:
    if not root.exists():
        raise FileNotFoundError(f"Runtime directory not found: {root}")

    images: List[RuntimeImage] = []
    for dockerfile in root.rglob("Dockerfile"):
        if not dockerfile.is_file():
            continue
        rel = dockerfile.relative_to(root)
        parts = rel.parts
        if len(parts) < 3:
            continue
        category = parts[0]
        component = parts[-3]
        variant = parts[-2]
        image_name = f"{component}-{variant}"
        images.append(RuntimeImage(category=category, component=component, variant=variant, image_name=image_name, dockerfile=dockerfile))

    images.sort(key=lambda img: (img.normalized_category, img.image_name))
    return images
