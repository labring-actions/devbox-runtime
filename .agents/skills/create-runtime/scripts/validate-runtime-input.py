#!/usr/bin/env python3
"""Validate create-runtime skill input and resolve its repository targets."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


TYPE_TO_KIND = {
    "operating-system": "operating-systems",
    "language": "languages",
    "framework": "frameworks",
}
COMPONENT_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._+-]*$")


def fail(message: str) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(1)


def parse_component(label: str, value: str) -> str:
    component = value.strip()
    if not component:
        fail(f"{label} cannot be empty")
    if component in {".", ".."} or "/" in component or "\\" in component:
        fail(f"{label} must be a single path component")
    if "\x00" in component or not COMPONENT_PATTERN.fullmatch(component):
        fail(f"{label} contains unsupported characters")
    return component


def ensure_within(root: Path, target: Path) -> None:
    try:
        target.relative_to(root)
    except ValueError:
        fail(f"resolved target escapes repository root: {target}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Validate create-runtime inputs without creating files"
    )
    parser.add_argument("--repo-root", required=True, type=Path)
    parser.add_argument("--type", required=True, dest="runtime_type")
    parser.add_argument("--name", required=True)
    parser.add_argument("--version", required=True)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    repo_root = args.repo_root.expanduser().resolve()
    if not repo_root.is_dir():
        fail(f"repository root does not exist: {repo_root}")

    try:
        kind = TYPE_TO_KIND[args.runtime_type.strip()]
    except KeyError:
        fail("type must be one of: " + ", ".join(TYPE_TO_KIND.keys()))

    name = parse_component("name", args.name)
    version = parse_component("version", args.version)

    runtime_dir = repo_root / "runtime-images" / kind / name / version
    base_dir = repo_root / "base-images" / kind / name / version
    smoke_test = (
        repo_root
        / "tests"
        / "runtime-smoke"
        / kind
        / name
        / version
        / "smoke.sh"
    )
    for target in (runtime_dir, base_dir, smoke_test):
        ensure_within(repo_root, target.resolve())

    if runtime_dir.exists():
        fail(f"runtime target already exists: {runtime_dir.relative_to(repo_root)}")
    if smoke_test.exists():
        fail(
            "smoke test target already exists: "
            f"{smoke_test.relative_to(repo_root)}"
        )

    payload = {
        "type": args.runtime_type.strip(),
        "kind": kind,
        "name": name,
        "version": version,
        "runtime_path": runtime_dir.relative_to(repo_root).as_posix(),
        "base_path": base_dir.relative_to(repo_root).as_posix(),
        "smoke_test_path": smoke_test.relative_to(repo_root).as_posix(),
    }
    print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
