#!/usr/bin/env python3

import argparse
import json
import os
import sys
from pathlib import Path


ROOT = Path.cwd()
RUNTIME_IMAGES_ROOT = ROOT / "runtime-images"

L10N_CHOICES = {
    "en_US": [{"display": "en_US", "normalized": "en-us"}],
    "zh_CN": [{"display": "zh_CN", "normalized": "zh-cn"}],
    "both": [
        {"display": "en_US", "normalized": "en-us"},
        {"display": "zh_CN", "normalized": "zh-cn"},
    ],
}

ARCH_CHOICES = {
    "amd64": ["amd64"],
    "arm64": ["arm64"],
    "both": ["amd64", "arm64"],
}


def fail(message: str) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(1)


def relative_posix(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def find_dockerfiles(root: Path) -> list[str]:
    if not root.exists():
        return []
    return sorted(relative_posix(path) for path in root.rglob("Dockerfile"))


def select_runtime_dockerfiles(kind: str, name: str) -> list[str]:
    if kind == "all":
        target_root = RUNTIME_IMAGES_ROOT
    else:
        target_root = RUNTIME_IMAGES_ROOT / kind

    if name:
        target_root = target_root / name.strip("/")

    if not target_root.exists():
        fail(f"target path '{relative_posix(target_root)}' does not exist")

    dockerfiles = find_dockerfiles(target_root)
    if not dockerfiles:
        fail(f"no runtime Dockerfile found under '{relative_posix(target_root)}'")
    return dockerfiles


def matrix_row(dockerfile: str, l10n: dict[str, str], arch: str) -> dict[str, str]:
    path = Path(dockerfile)
    parts = path.parts
    if len(parts) < 5 or parts[0] != "runtime-images":
        fail(f"unsupported runtime Dockerfile path '{dockerfile}'")

    runtime_kind = parts[1]
    runtime_name = parts[-3]
    runtime_version = parts[-2]
    runtime_path = "/".join(parts[1:-1])

    return {
        "dockerfile": dockerfile,
        "runtime_path": runtime_path,
        "kind": runtime_kind,
        "name": runtime_name,
        "version": runtime_version,
        "image_name": f"{runtime_name}-{runtime_version}",
        "l10n": l10n["display"],
        "l10n_normalized": l10n["normalized"],
        "arch": arch,
    }


def write_output(key: str, value: str) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with open(output_path, "a", encoding="utf-8") as handle:
            handle.write(f"{key}<<EOF\n{value}\nEOF\n")
    else:
        print(f"{key}={value}")


def append_summary(markdown: str) -> None:
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as handle:
            handle.write(markdown)
            if not markdown.endswith("\n"):
                handle.write("\n")
    else:
        print(markdown)


def render_summary(
    tag: str,
    kind: str,
    name: str,
    l10n: str,
    arch: str,
    dockerfiles: list[str],
    job_count: int,
) -> str:
    rows = []
    for dockerfile in dockerfiles:
        runtime_path = (ROOT / dockerfile).parent.relative_to(RUNTIME_IMAGES_ROOT).as_posix()
        rows.append(f"| `{runtime_path}` | `{dockerfile}` |")

    return "\n".join(
        [
            "## Runtime Image Conformance Plan",
            f"- tag: `{tag}`",
            f"- kind: `{kind}`",
            f"- name: `{name or '*'}`",
            f"- l10n: `{l10n}`",
            f"- arch: `{arch}`",
            f"- runtimes: `{len(dockerfiles)}`",
            f"- matrix jobs: `{job_count}`",
            "",
            "| Runtime | Dockerfile |",
            "| --- | --- |",
            *rows,
            "",
        ]
    )


def handle_plan(args: argparse.Namespace) -> int:
    tag = args.tag.strip()
    kind = args.kind.strip()
    name = args.name.strip()
    l10n_choice = args.l10n.strip()
    arch_choice = args.arch.strip()

    if not tag:
        fail("tag cannot be empty")
    if kind not in {"all", "operating-systems", "languages", "frameworks"}:
        fail("kind must be all|operating-systems|languages|frameworks")
    if l10n_choice not in L10N_CHOICES:
        fail("l10n must be en_US|zh_CN|both")
    if arch_choice not in ARCH_CHOICES:
        fail("arch must be amd64|arm64|both")

    dockerfiles = select_runtime_dockerfiles(kind, name)
    matrix = [
        matrix_row(dockerfile, l10n, arch)
        for dockerfile in dockerfiles
        for l10n in L10N_CHOICES[l10n_choice]
        for arch in ARCH_CHOICES[arch_choice]
    ]

    write_output("matrix", json.dumps(matrix, separators=(",", ":")))
    write_output("runtime_count", str(len(dockerfiles)))
    write_output("job_count", str(len(matrix)))
    append_summary(render_summary(tag, kind, name, l10n_choice, arch_choice, dockerfiles, len(matrix)))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Plan runtime image conformance matrix jobs.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    plan = subparsers.add_parser("plan", help="Generate a runtime conformance matrix.")
    plan.add_argument("--tag", required=True)
    plan.add_argument("--kind", default="all")
    plan.add_argument("--name", default="")
    plan.add_argument("--l10n", default="both")
    plan.add_argument("--arch", default="amd64")
    plan.set_defaults(handler=handle_plan)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return int(args.handler(args))


if __name__ == "__main__":
    raise SystemExit(main())
