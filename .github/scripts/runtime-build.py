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
INTERNAL_FROM_RE = re.compile(r"^FROM \$\{REGISTRY\}/\$\{(?:REPO|TOOLING_REPO)\}/([^:\s]+):")


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


def parse_json_list(raw_json: str, label: str) -> list[object]:
    if not raw_json or not raw_json.strip():
        return []
    try:
        parsed = json.loads(raw_json)
    except json.JSONDecodeError as exc:
        fail(f"invalid {label}: {exc}")
    if not isinstance(parsed, list):
        fail(f"{label} must be a JSON array")
    return parsed


def parse_string_list(raw_json: str, label: str) -> list[str]:
    items = parse_json_list(raw_json, label)
    values: list[str] = []
    for index, item in enumerate(items):
        if not isinstance(item, str):
            fail(f"{label}[{index}] must be a string")
        values.append(item)
    return values


def parse_l10n_matrix(raw_json: str) -> list[dict[str, str]]:
    items = parse_json_list(raw_json, "l10n_matrix")
    values: list[dict[str, str]] = []
    for index, item in enumerate(items):
        if not isinstance(item, dict):
            fail(f"l10n_matrix[{index}] must be an object")
        display = str(item.get("display", "")).strip()
        normalized = str(item.get("normalized", "")).strip()
        if not display or not normalized:
            fail(f"l10n_matrix[{index}] must include non-empty display and normalized")
        values.append({"display": display, "normalized": normalized})
    return values


def markdown_code(value: str) -> str:
    return f"`{value}`"


def build_markdown_table(headers: list[str], rows: list[list[str]]) -> str:
    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join(["---"] * len(headers)) + " |",
    ]
    for row in rows:
        lines.append("| " + " | ".join(row) + " |")
    return "\n".join(lines)


def image_name_from_dockerfile(dockerfile: str) -> str:
    dockerfile_path = Path(dockerfile)
    return f"{dockerfile_path.parent.parent.name}-{dockerfile_path.parent.name}"


def image_kind_from_dockerfile(dockerfile: str) -> str:
    dockerfile_path = Path(dockerfile)
    parts = dockerfile_path.parts
    if len(parts) < 4:
        fail(f"unsupported dockerfile path '{dockerfile}'")
    return parts[1]


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
            if dep in {"base-tools", "tooling"}:
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
            "os_image_packages": json.dumps(os_images, separators=(",", ":")),
            "language_image_packages": json.dumps(language_images, separators=(",", ":")),
            "framework_image_packages": json.dumps(framework_images, separators=(",", ":")),
            "runtime_packages": json.dumps(sorted(set(runtime_targets)), separators=(",", ":")),
            "build_tools": "true" if tools_required else "false",
            "has_os_images": "true" if os_images else "false",
            "has_language_images": "true" if language_images else "false",
            "has_framework_images": "true" if framework_images else "false",
            "has_runtimes": "true" if runtime_targets else "false",
        }
    )

    return 0


def image_repository(owner: str, repo_type: str, dockerfile: str = "") -> str:
    if repo_type == "tooling":
        return f"ghcr.io/{owner}/devbox-tooling/tooling"
    if not dockerfile:
        fail(f"dockerfile is required for repo_type '{repo_type}'")

    image_name = image_name_from_dockerfile(dockerfile)
    if repo_type == "base-images":
        return f"ghcr.io/{owner}/devbox-base-images/{image_name}"
    if repo_type == "runtime-images":
        return f"ghcr.io/{owner}/devbox-runtime-images/{image_name}"
    fail(f"unsupported repo_type '{repo_type}'")


def render_arch_images(base_ref: str, tag: str, arch_matrix: list[str]) -> str:
    return "<br>".join(markdown_code(f"{base_ref}:{tag}-{arch}") for arch in arch_matrix)


def render_package_section(
    title: str,
    packages: list[str],
    repo_type: str,
    owner: str,
    tag: str,
    l10n_matrix: list[dict[str, str]],
    arch_matrix: list[str],
) -> str:
    if not packages:
        return ""

    rows: list[list[str]] = []
    for dockerfile in packages:
        image_ref = image_repository(owner, repo_type, dockerfile)
        image_name = image_name_from_dockerfile(dockerfile)
        for l10n in l10n_matrix:
            manifest_tag = f"{tag}-{l10n['normalized']}"
            rows.append(
                [
                    markdown_code(image_name),
                    markdown_code(dockerfile),
                    markdown_code(l10n["display"]),
                    markdown_code(f"{image_ref}:{manifest_tag}"),
                    render_arch_images(image_ref, manifest_tag, arch_matrix),
                ]
            )

    header = f"### {title} ({len(rows)} manifest tags)"
    table = build_markdown_table(
        ["Image", "Dockerfile", "L10N", "Manifest", "Per-Arch Images"],
        rows,
    )
    return "\n".join([header, table, ""])


def render_tooling_section(owner: str, tools_version: str, arch_matrix: list[str]) -> str:
    base_ref = image_repository(owner, "tooling")
    rows = [
        [
            markdown_code("tooling"),
            markdown_code("tooling/Dockerfile"),
            markdown_code(f"{base_ref}:{tools_version}"),
            render_arch_images(base_ref, tools_version, arch_matrix),
        ]
    ]
    header = "### Tooling (1 manifest tag)"
    table = build_markdown_table(
        ["Image", "Dockerfile", "Manifest", "Per-Arch Images"],
        rows,
    )
    return "\n".join([header, table, ""])


def split_packages_by_kind(packages: list[str]) -> dict[str, list[str]]:
    grouped = {
        "operating-systems": [],
        "languages": [],
        "frameworks": [],
    }
    for dockerfile in packages:
        kind = image_kind_from_dockerfile(dockerfile)
        if kind not in grouped:
            fail(f"unsupported image kind '{kind}' in '{dockerfile}'")
        grouped[kind].append(dockerfile)
    return grouped


def render_resolved_inputs(
    target: str,
    profile: str,
    include_prerequisites: bool,
    tag: str,
    l10n: str,
    arch: str,
) -> str:
    return "\n".join(
        [
            "## Resolved Inputs",
            f"- target: `{target}`",
            f"- profile: `{profile}`",
            f"- include_prerequisites: `{'true' if include_prerequisites else 'false'}`",
            f"- tag: `{tag}`",
            f"- l10n: `{l10n}`",
            f"- arch: `{arch}`",
            "",
        ]
    )


def render_build_plan(build_tools: bool, planned_image_count: int, runtime_count: int) -> str:
    return "\n".join(
        [
            "## Build Plan",
            f"- build_tools: `{'true' if build_tools else 'false'}`",
            f"- image_packages: `{planned_image_count}`",
            f"- runtime_packages: `{runtime_count}`",
            "",
        ]
    )


def handle_append_workflow_summary(args: argparse.Namespace) -> int:
    owner = args.ghcr_owner.strip()
    target = args.target.strip()
    profile = args.profile.strip()
    tag = args.tag.strip()
    l10n = args.l10n.strip()
    arch = args.arch.strip()
    tools_version = args.tools_version.strip()
    if not owner:
        fail("ghcr_owner cannot be empty")
    if not target:
        fail("target cannot be empty")
    if not profile:
        fail("profile cannot be empty")
    if not tag:
        fail("tag cannot be empty")
    if not l10n:
        fail("l10n cannot be empty")
    if not arch:
        fail("arch cannot be empty")

    build_tools = normalize_bool(args.build_tools)
    include_prerequisites = normalize_bool(args.include_prerequisites)
    aliyun_enabled = normalize_bool(args.aliyun_enabled)
    l10n_matrix = parse_l10n_matrix(args.l10n_matrix)
    arch_matrix = parse_string_list(args.arch_matrix, "arch_matrix")
    os_image_packages = parse_string_list(args.os_image_packages, "os_image_packages")
    language_image_packages = parse_string_list(args.language_image_packages, "language_image_packages")
    framework_image_packages = parse_string_list(args.framework_image_packages, "framework_image_packages")
    runtime_packages = parse_string_list(args.runtime_packages, "runtime_packages")

    if build_tools and not tools_version:
        fail("tools_version cannot be empty when build_tools=true")
    if not arch_matrix:
        fail("arch_matrix cannot be empty")
    if (os_image_packages or language_image_packages or framework_image_packages or runtime_packages) and not l10n_matrix:
        fail("l10n_matrix cannot be empty when packages are planned")

    runtime_groups = split_packages_by_kind(runtime_packages)
    planned_image_count = len(os_image_packages) + len(language_image_packages) + len(framework_image_packages)

    sections = [
        render_resolved_inputs(target, profile, include_prerequisites, tag, l10n, arch),
        render_build_plan(build_tools, planned_image_count, len(runtime_packages)),
        "## Planned Image List",
        "GHCR image references are listed below.",
        f"Aliyun mirror enabled: `{'true' if aliyun_enabled else 'false'}`",
        "",
    ]

    if build_tools:
        sections.append(render_tooling_section(owner, tools_version, arch_matrix))
    sections.append(
        render_package_section(
            "Base Operating System Images",
            os_image_packages,
            "base-images",
            owner,
            tag,
            l10n_matrix,
            arch_matrix,
        )
    )
    sections.append(
        render_package_section(
            "Base Language Images",
            language_image_packages,
            "base-images",
            owner,
            tag,
            l10n_matrix,
            arch_matrix,
        )
    )
    sections.append(
        render_package_section(
            "Base Framework Images",
            framework_image_packages,
            "base-images",
            owner,
            tag,
            l10n_matrix,
            arch_matrix,
        )
    )
    sections.append(
        render_package_section(
            "Runtime Operating System Images",
            runtime_groups["operating-systems"],
            "runtime-images",
            owner,
            tag,
            l10n_matrix,
            arch_matrix,
        )
    )
    sections.append(
        render_package_section(
            "Runtime Language Images",
            runtime_groups["languages"],
            "runtime-images",
            owner,
            tag,
            l10n_matrix,
            arch_matrix,
        )
    )
    sections.append(
        render_package_section(
            "Runtime Framework Images",
            runtime_groups["frameworks"],
            "runtime-images",
            owner,
            tag,
            l10n_matrix,
            arch_matrix,
        )
    )

    rendered = "\n".join(section for section in sections if section)
    append_summary(rendered + "\n")
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

    append_workflow_summary = subparsers.add_parser("append-workflow-summary", help="Append the workflow summary to the current job summary.")
    append_workflow_summary.add_argument("--ghcr-owner", required=True)
    append_workflow_summary.add_argument("--target", required=True)
    append_workflow_summary.add_argument("--profile", required=True)
    append_workflow_summary.add_argument("--include-prerequisites", default="false")
    append_workflow_summary.add_argument("--tag", required=True)
    append_workflow_summary.add_argument("--l10n", required=True)
    append_workflow_summary.add_argument("--arch", required=True)
    append_workflow_summary.add_argument("--tools-version", default="")
    append_workflow_summary.add_argument("--build-tools", default="false")
    append_workflow_summary.add_argument("--aliyun-enabled", default="false")
    append_workflow_summary.add_argument("--os-image-packages", default="[]")
    append_workflow_summary.add_argument("--language-image-packages", default="[]")
    append_workflow_summary.add_argument("--framework-image-packages", default="[]")
    append_workflow_summary.add_argument("--runtime-packages", default="[]")
    append_workflow_summary.add_argument("--l10n-matrix", default="[]")
    append_workflow_summary.add_argument("--arch-matrix", default="[]")
    append_workflow_summary.set_defaults(handler=handle_append_workflow_summary)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return int(args.handler(args))


if __name__ == "__main__":
    raise SystemExit(main())
