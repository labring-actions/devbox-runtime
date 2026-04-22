#!/usr/bin/env python3

import argparse
import json
import os
import re
import sys
from pathlib import Path


ROOT = Path.cwd()
BASE_IMAGES_ROOT = ROOT / "base-images"
RUNTIME_IMAGES_ROOT = ROOT / "runtime-images"
INTERNAL_FROM_RE = re.compile(r"^FROM \$\{REGISTRY\}/\$\{REPO\}/([^:\s]+):")


def fail(message: str) -> None:
    print(f"Error: {message}", file=sys.stderr)
    raise SystemExit(1)


def normalize_bool(value: object) -> bool:
    text = str(value).strip().lower()
    if text in {"1", "true", "yes", "on"}:
        return True
    if text in {"0", "false", "no", "off", ""}:
        return False
    fail(f"unsupported boolean value '{value}'")


def relative_posix(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def find_dockerfiles(root: Path) -> list[str]:
    if not root.exists():
        return []
    return sorted(relative_posix(path) for path in root.rglob("Dockerfile"))


def select_dockerfiles(build_root: str, kind: str, name: str) -> list[str]:
    target_root = ROOT / build_root / kind
    if name:
        target_root = target_root / name
    if not target_root.exists():
        fail(f"target path '{relative_posix(target_root)}' does not exist")
    return find_dockerfiles(target_root)


def write_outputs(values: dict[str, str]) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    lines = [f"{key}={value}" for key, value in values.items()]
    if output_path:
        with open(output_path, "a", encoding="utf-8") as handle:
            handle.write("\n".join(lines))
            handle.write("\n")
    else:
        print("\n".join(lines))


def append_summary(text: str) -> None:
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as handle:
            handle.write(text)
            if not text.endswith("\n"):
                handle.write("\n")
    else:
        print(text)


def image_name_from_dockerfile(dockerfile: str) -> str:
    dockerfile_path = Path(dockerfile)
    return f"{dockerfile_path.parent.parent.name}-{dockerfile_path.parent.name}"


def build_image_map() -> dict[str, str]:
    image_map: dict[str, str] = {}
    for dockerfile in find_dockerfiles(BASE_IMAGES_ROOT):
        image_map[image_name_from_dockerfile(dockerfile)] = dockerfile
    return image_map


def list_internal_dependencies(dockerfile: str) -> list[str]:
    deps: list[str] = []
    with open(ROOT / dockerfile, "r", encoding="utf-8") as handle:
        for line in handle:
            match = INTERNAL_FROM_RE.match(line.strip())
            if match:
                deps.append(match.group(1))
    return deps


def parse_target(target: str) -> tuple[str, str, str]:
    if target == "all":
        return "all", "", "all"

    build_prefix, sep, rest = target.partition("/")
    if build_prefix not in {"image", "runtime"} or not sep or not rest.strip():
        fail(
            "target must be one of: all|image/os/<path>|image/lang/<path>|image/fw/<path>|"
            "runtime/os/<path>|runtime/lang/<path>|runtime/fw/<path>"
        )

    kind_prefix, kind_sep, name = rest.partition("/")
    if kind_prefix not in {"os", "lang", "fw"} or not kind_sep or not name.strip():
        fail("target must include kind and path, for example image/fw/sandbox/v1")

    kind_map = {
        "os": "operating-systems",
        "lang": "languages",
        "fw": "frameworks",
    }
    build_type = "base-images" if build_prefix == "image" else "runtime-images"
    return kind_map[kind_prefix], name.strip("/"), build_type


def parse_overrides(raw_json: str) -> dict[str, str]:
    if not raw_json or not raw_json.strip():
        return {}
    try:
        parsed = json.loads(raw_json)
    except json.JSONDecodeError as exc:
        fail(f"invalid overrides_json: {exc}")
    if not isinstance(parsed, dict):
        fail("overrides_json must be a JSON object")

    out: dict[str, str] = {}
    for key in {"tools", "os", "framework", "node", "runtime"}:
        value = parsed.get(key)
        if value is None:
            continue
        text = str(value).strip()
        if not text:
            fail(f"overrides_json.{key} cannot be empty")
        out[key] = text
    return out


def resolve_images_with_dependencies(seed_images: list[str]) -> tuple[list[str], bool]:
    image_map = build_image_map()
    selected: set[str] = set()
    tools_required = False

    def visit(dockerfile: str) -> None:
        nonlocal tools_required
        if dockerfile in selected:
            return
        selected.add(dockerfile)
        for dep in list_internal_dependencies(dockerfile):
            if dep == "base-tools":
                tools_required = True
                continue
            dep_dockerfile = image_map.get(dep)
            if not dep_dockerfile:
                fail(f"could not resolve dependency '{dep}' referenced by {dockerfile}")
            visit(dep_dockerfile)

    for item in seed_images:
        visit(item)
    return sorted(selected), tools_required


def handle_resolve_dispatch(args: argparse.Namespace) -> int:
    release_tag = args.release_tag.strip()
    if not release_tag:
        fail("release_tag cannot be empty")

    target_kind, target_name, target_build_type = parse_target(args.target)
    profile = args.profile.strip()
    if profile not in {"quick", "full", "release"}:
        fail("profile must be quick|full|release")

    include_prerequisites = profile in {"full", "release"}
    l10n = "both" if profile == "release" else args.l10n
    arch = "both" if profile == "release" else args.arch
    if l10n not in {"en_US", "zh_CN", "both"}:
        fail("l10n must be en_US|zh_CN|both")
    if arch not in {"amd64", "arm64", "both"}:
        fail("arch must be amd64|arm64|both")

    overrides = parse_overrides(args.overrides_json)
    tools_version = overrides.get("tools", release_tag)
    os_version = overrides.get("os", release_tag)
    framework_image_version = overrides.get("framework", release_tag)
    node_image_version = overrides.get("node", release_tag)
    runtime_image_version = overrides.get("runtime", node_image_version)

    write_outputs(
        {
            "tag": release_tag,
            "target_kind": target_kind,
            "target_name": target_name,
            "target_build_type": target_build_type,
            "include_prerequisites": "true" if include_prerequisites else "false",
            "tools_version": tools_version,
            "os_version": os_version,
            "framework_image_version": framework_image_version,
            "node_image_version": node_image_version,
            "runtime_image_version": runtime_image_version,
            "l10n": l10n,
            "arch": arch,
        }
    )

    append_summary(
        "\n".join(
            [
                "## Resolved Inputs",
                f"- target: `{args.target}`",
                f"- profile: `{profile}`",
                f"- include_prerequisites: `{'true' if include_prerequisites else 'false'}`",
                f"- tag: `{release_tag}`",
                f"- l10n: `{l10n}`",
                f"- arch: `{arch}`",
            ]
        )
        + "\n"
    )
    return 0


def handle_plan_build(args: argparse.Namespace) -> int:
    target_kind = args.target_kind
    target_name = args.target_name
    target_build_type = args.target_build_type
    include_prerequisites = normalize_bool(args.include_prerequisites)

    image_targets: list[str] = []
    runtime_targets: list[str] = []

    if target_kind == "all":
        if target_build_type in {"base-images", "all"}:
            image_targets = find_dockerfiles(BASE_IMAGES_ROOT)
        if target_build_type in {"runtime-images", "all"}:
            runtime_targets = find_dockerfiles(RUNTIME_IMAGES_ROOT)
    else:
        if target_build_type in {"base-images", "all"}:
            image_targets = select_dockerfiles("base-images", target_kind, target_name)
        if target_build_type in {"runtime-images", "all"}:
            runtime_targets = select_dockerfiles("runtime-images", target_kind, target_name)

    dep_seed_images: list[str] = list(image_targets)
    if include_prerequisites:
        if target_kind == "all" and target_build_type in {"runtime-images", "all"}:
            dep_seed_images.extend(find_dockerfiles(BASE_IMAGES_ROOT))
        elif runtime_targets and target_kind != "all":
            dep_seed_images.extend(select_dockerfiles("base-images", target_kind, target_name))

    planned_images: list[str]
    tools_required = False
    if include_prerequisites:
        planned_images, tools_required = resolve_images_with_dependencies(dep_seed_images)
    else:
        planned_images = sorted(set(image_targets))

    os_images = [pkg for pkg in planned_images if "base-images/operating-systems/" in pkg]
    language_images = [pkg for pkg in planned_images if "base-images/languages/" in pkg]
    framework_images = [pkg for pkg in planned_images if "base-images/frameworks/" in pkg]

    write_outputs(
        {
            "image_packages": json.dumps(planned_images, separators=(",", ":")),
            "os_image_packages": json.dumps(os_images, separators=(",", ":")),
            "language_image_packages": json.dumps(language_images, separators=(",", ":")),
            "framework_image_packages": json.dumps(framework_images, separators=(",", ":")),
            "runtime_packages": json.dumps(sorted(set(runtime_targets)), separators=(",", ":")),
            "build_tools": "true" if tools_required else "false",
            "has_images": "true" if planned_images else "false",
            "has_os_images": "true" if os_images else "false",
            "has_language_images": "true" if language_images else "false",
            "has_framework_images": "true" if framework_images else "false",
            "has_runtimes": "true" if runtime_targets else "false",
        }
    )

    append_summary(
        "\n".join(
            [
                "## Build Plan",
                f"- build_tools: `{'true' if tools_required else 'false'}`",
                f"- image_packages: `{len(planned_images)}`",
                f"- runtime_packages: `{len(runtime_targets)}`",
            ]
        )
        + "\n"
    )
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Helpers for the runtime image build workflow.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    resolve_dispatch = subparsers.add_parser("resolve-dispatch", help="Resolve simplified dispatch inputs.")
    resolve_dispatch.add_argument("--release-tag", required=True)
    resolve_dispatch.add_argument("--target", required=True)
    resolve_dispatch.add_argument("--profile", required=True)
    resolve_dispatch.add_argument("--l10n", required=True)
    resolve_dispatch.add_argument("--arch", required=True)
    resolve_dispatch.add_argument("--overrides-json", default="")
    resolve_dispatch.set_defaults(handler=handle_resolve_dispatch)

    plan_build = subparsers.add_parser("plan-build", help="Resolve image/runtime package lists.")
    plan_build.add_argument("--target-kind", required=True)
    plan_build.add_argument("--target-name", default="")
    plan_build.add_argument("--target-build-type", required=True)
    plan_build.add_argument("--include-prerequisites", default="true")
    plan_build.set_defaults(handler=handle_plan_build)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return int(args.handler(args))


if __name__ == "__main__":
    raise SystemExit(main())
