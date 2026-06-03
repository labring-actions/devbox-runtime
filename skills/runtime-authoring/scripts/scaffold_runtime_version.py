#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path


DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[3]
KIND_ALIASES = {
    "os": "operating-systems",
    "operating-systems": "operating-systems",
    "lang": "languages",
    "languages": "languages",
    "fw": "frameworks",
    "frameworks": "frameworks",
}


def fail(message: str) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(1)


def normalize_kind(raw_kind: str) -> str:
    kind = KIND_ALIASES.get(raw_kind.strip())
    if not kind:
        fail("kind must be one of: operating-systems|languages|frameworks|os|lang|fw")
    return kind


def version_path(root: Path, prefix: str, kind: str, name: str, version: str) -> Path:
    return root / prefix / kind / Path(name) / version


def replace_version_in_text_files(target_dir: Path, source_version: str, target_version: str, dry_run: bool) -> list[Path]:
    changed_files: list[Path] = []
    for path in sorted(target_dir.rglob("*")):
        if not path.is_file():
            continue
        try:
            original = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        updated = original.replace(source_version, target_version)
        if updated == original:
            continue
        if not dry_run:
            path.write_text(updated, encoding="utf-8")
        changed_files.append(path)
    return changed_files


def scaffold_tree(source: Path, target: Path, dry_run: bool) -> None:
    if not source.exists():
        fail(f"source path does not exist: {source}")
    if target.exists():
        fail(f"target path already exists: {target}")
    if dry_run:
        return
    shutil.copytree(source, target)


def relative_to_root(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scaffold a new version for an existing runtime family in this repository."
    )
    parser.add_argument("kind", help="operating-systems | languages | frameworks (aliases: os | lang | fw)")
    parser.add_argument("name", help="Runtime family name, for example go or node.js")
    parser.add_argument("source_version", help="Existing version directory to copy from")
    parser.add_argument("target_version", help="New version directory to create")
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=DEFAULT_REPO_ROOT,
        help=f"Repository root (default: {DEFAULT_REPO_ROOT})",
    )
    parser.add_argument(
        "--skip-smoke-test",
        action="store_true",
        help="Do not copy tests/runtime-smoke even if a source smoke test exists",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print planned actions without creating files",
    )
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    kind = normalize_kind(args.kind)
    name = args.name.strip().strip("/")
    source_version = args.source_version.strip()
    target_version = args.target_version.strip()
    dry_run = bool(args.dry_run)

    if not name:
        fail("name cannot be empty")
    if not source_version:
        fail("source_version cannot be empty")
    if not target_version:
        fail("target_version cannot be empty")
    if source_version == target_version:
        fail("source_version and target_version must differ")

    trees = [
        ("base-images", True),
        ("runtime-images", True),
    ]
    if not args.skip_smoke_test:
        trees.append(("tests/runtime-smoke", False))

    created_dirs: list[Path] = []
    changed_files: list[Path] = []
    skipped_optional: list[Path] = []

    for prefix, required in trees:
        source_dir = version_path(repo_root, prefix, kind, name, source_version)
        target_dir = version_path(repo_root, prefix, kind, name, target_version)
        if not source_dir.exists():
            if required:
                fail(f"required source directory does not exist: {source_dir}")
            skipped_optional.append(source_dir)
            continue
        scaffold_tree(source_dir, target_dir, dry_run)
        created_dirs.append(target_dir)
        changed_files.extend(replace_version_in_text_files(target_dir, source_version, target_version, dry_run))

    if not created_dirs:
        fail("no directories were created")

    print("Scaffolded runtime version:")
    for path in created_dirs:
        print(f"- {relative_to_root(repo_root, path)}")

    if skipped_optional:
        print("Skipped optional source directories:")
        for path in skipped_optional:
            print(f"- {relative_to_root(repo_root, path)}")

    print(f"Updated text files: {len(changed_files)}")
    if changed_files:
        for path in changed_files:
            print(f"- {relative_to_root(repo_root, path)}")

    escaped_source_version = re.escape(source_version)
    print("Next steps:")
    print("- Review download URLs, checksums, image references, and project-template content for semantic changes.")
    print("- Search for stale source-version strings in the newly created directories:")
    print(
        "  rg -n --hidden "
        f"'{escaped_source_version}' "
        + " ".join(relative_to_root(repo_root, path) for path in created_dirs)
    )
    print("- Run plan-build for the new target before opening a PR.")
    if dry_run:
        print("Dry run only: no files were written.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
