---
name: runtime-authoring
description: Use when creating a new DevBox runtime in this repository or adding a new version to an existing runtime family such as Go 1.24 or 1.25. Helps scaffold matching base-images, runtime-images, and tests/runtime-smoke directories, update versioned strings, and validate the result against this repo's CI conventions.
---

# Runtime Authoring

Use this skill for work under `base-images/`, `runtime-images/`, and `tests/runtime-smoke/`.

## Choose the path

- Existing runtime family, new version:
  use `scripts/scaffold_runtime_version.py` first. This is the fast path for requests like "add Go 1.24" or "add Node.js 24".
- Brand-new runtime family:
  do not blindly rename another family. Pick the closest sibling as a reference, then create the new base/runtime/smoke-test directories manually.

## Repo conventions

- Runtime definitions usually live in matching directory triplets:
  - `base-images/<kind>/<name>/<version>/`
  - `runtime-images/<kind>/<name>/<version>/`
  - `tests/runtime-smoke/<kind>/<name>/<version>/` when smoke coverage exists
- Valid `<kind>` folders are `operating-systems`, `languages`, and `frameworks`.
- CI auto-discovers Dockerfiles. There is usually no central registry list to update after adding a runtime directory.
- Copy the entire version directory tree, not just `Dockerfile` and `build.sh`. Many runtimes also ship `project-template/`, localized `README.*.md`, config files, or extra assets.

## Existing family to new version

1. Pick the closest source version from the same family.
2. Run the scaffold script from the repo root:

```bash
python3 skills/runtime-authoring/scripts/scaffold_runtime_version.py languages go 1.23.0 1.24.0
```

3. Review the new directories carefully. The script only replaces the raw version string; it does not understand semantic changes in package names, download URLs, checksums, entrypoints, or template content.
4. Search the newly created paths for stale source-version strings and family-specific text that still needs manual cleanup.
5. Inspect the nearest existing version diff to see what else changed between releases.
6. Validate the planning logic:

```bash
python3 .github/scripts/runtime-build.py plan-build \
  --target-kind languages \
  --target-name go/1.24.0 \
  --target-build-type runtime-images \
  --include-prerequisites true
```

7. If the runtime has smoke coverage, make sure `tests/runtime-smoke/.../smoke.sh` asserts the new version and still matches the project template layout.

## Brand-new runtime family

1. Pick the correct kind: `operating-systems`, `languages`, or `frameworks`.
2. Choose the closest sibling runtime from the same kind as a reference implementation.
3. Create all matching directories together:
  - `base-images/...`
  - `runtime-images/...`
  - `tests/runtime-smoke/...` if the runtime should be smoke-tested
4. Update these files first:
  - base `Dockerfile`: parent image and labels
  - base `build.sh`: install steps, download URLs, version pins, architecture handling
  - runtime `Dockerfile`: `FROM` image name, project-template copy, workdir
  - runtime `build.sh`: template placement, ownership, docs copy behavior
  - `project-template/*`: localized READMEs, example source, entrypoint
  - `smoke.sh`: version assertion, template file checks, startup behavior
5. Prefer following the nearest existing runtime's shape instead of inventing a new layout.
6. Read `../../docs/build-workflows.md` if you need to confirm how CI discovers and publishes the new runtime.

## Detailed checklist

Read `references/version-review-checklist.md` when you need the file-level review checklist, search commands, or a Go version-bump example.

## Output expectations

When using this skill, finish with:

- the directories created or changed
- anything still requiring a human decision, such as upstream URL changes, template differences, or missing smoke coverage
- the validation you ran locally versus what still needs CI
