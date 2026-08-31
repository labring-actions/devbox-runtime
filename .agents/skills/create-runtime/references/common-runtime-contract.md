# Common Runtime Contract

Use this guide for every new runtime.

## Repository layout

- `tooling/`: shared build tools and scripts.
- `base-images/`: reusable base image definitions.
- `runtime-images/`: final images exposed as DevBox runtimes.
- `tests/runtime-smoke/`: smoke tests aligned with runtime image paths.
- `tests/runtime-conformance/`: repository-wide runtime checks.
- `docs/`: contributor and runtime behavior documentation.

A runtime Dockerfile belongs at:

```text
runtime-images/<kind>/<name>/<version>/Dockerfile
```

where `<kind>` is exactly `operating-systems`, `languages`, or `frameworks`.

## Inspect before editing

Use an existing runtime of the same kind as a structural reference. Check its:

- Dockerfile ARG and image naming conventions;
- `build.sh` ownership, locale, template, and dependency behavior;
- project-template files and localized README names;
- entrypoint protocol and default working directory;
- matching smoke test assertions;
- base image dependency, if any.

Copy structure only. Re-derive source URLs, checksums, versions, commands, ports, and package lists for the new runtime.

## Files and scripts

- Preserve executable mode for `build.sh` and `smoke.sh` when neighboring runtimes do. The conformance runner requires `project-template/entrypoint.sh` to exist and invokes it with `bash`; source executable mode is not itself a conformance requirement.
- Keep shell scripts strict (`set -euo pipefail` where compatible) and quote variables.
- Keep user-facing documentation in both `README.en_US.md` and `README.zh_CN.md` when the runtime has a project template.
- Make the template's documented commands match the actual entrypoint and build behavior.
- Do not add placeholder files to satisfy a path check.

## Verification

Use the repository's planner to verify that the target is discoverable and to inspect its CI matrix:

```bash
python3 .github/scripts/runtime-conformance.py plan \
  --tag <tag> \
  --kind <operating-systems|languages|frameworks> \
  --name <name>/<version> \
  --l10n both \
  --arch both
```

The planner does **not** execute conformance. Before claiming conformance support, add the new runtime's exact relative path to the appropriate `case` branch in `tests/runtime-conformance/run.sh`, implement the runtime-specific assertions there, and update `tests/runtime-conformance/README.md`. The runner fails unregistered runtimes intentionally.

The supported published-image execution path is the `runtime-image-conformance.yaml` workflow: it pulls each already-published architecture/l10n image, mounts the repository at `/repo`, and runs. It does not build a new image.

```bash
bash /repo/tests/runtime-conformance/run.sh
```

For a not-yet-published runtime, build the image locally first, then run that same command inside the built runtime image with `RUNTIME_PATH`, `RUNTIME_DOCKERFILE`, `RUNTIME_IMAGE`, `L10N`, `CONFORMANCE_ARCH`, and `REPO_ROOT=/repo` set as the workflow does. The matching `tests/runtime-smoke/<kind>/<name>/<version>/smoke.sh` is also required by the smoke workflow and must be executed in the image as `devbox`. If Docker, registry access, or a required tool is unavailable, report the exact blocker; do not weaken the check silently.

## Scope boundary

Do not change CI workflows, shared tooling, or existing runtime files to hide a new runtime's failure. If a shared fix is genuinely required, stop and present that separate change explicitly.
