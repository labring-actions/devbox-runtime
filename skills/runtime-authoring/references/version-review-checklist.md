# Version Review Checklist

Use this checklist after scaffolding a new version or when hand-authoring a new runtime family.

## Always check these paths together

- `base-images/<kind>/<name>/<version>/`
- `runtime-images/<kind>/<name>/<version>/`
- `tests/runtime-smoke/<kind>/<name>/<version>/` when smoke coverage exists

## Files that usually need manual review

- base `Dockerfile`
  - parent image
  - ARG names and image version variables
- base `build.sh`
  - download URL
  - pinned version string
  - architecture mapping
  - checksum or archive name if applicable
- runtime `Dockerfile`
  - `FROM` image reference
  - copied config or template directories
- runtime `build.sh`
  - project-template installation
  - permissions and ownership
  - docs fallback logic
- `project-template/README.en_US.md`
- `project-template/README.zh_CN.md`
- `project-template/entrypoint.sh`
- extra config files such as `nginx.conf`
- `tests/runtime-smoke/.../smoke.sh`
  - version assertion
  - expected template files
  - process startup behavior

## Useful searches

Search for stale source-version strings in the newly created directories:

```bash
rg -n --hidden '1\.23\.0' \
  base-images/languages/go/1.24.0 \
  runtime-images/languages/go/1.24.0 \
  tests/runtime-smoke/languages/go/1.24.0
```

Search for old image references or family-specific labels:

```bash
rg -n --hidden 'go-1\.23\.0|Go 1\.23\.0' \
  runtime-images/languages/go/1.24.0 \
  tests/runtime-smoke/languages/go/1.24.0
```

## Planning validation

Check that CI planning resolves the new runtime and any prerequisite base image:

```bash
python3 .github/scripts/runtime-build.py plan-build \
  --target-kind languages \
  --target-name go/1.24.0 \
  --target-build-type runtime-images \
  --include-prerequisites true
```

If you are touching CI behavior or release expectations, read `docs/build-workflows.md`.

## Go example

For a Go version bump, these files usually need version edits:

- `base-images/languages/go/<version>/build.sh`
- `runtime-images/languages/go/<version>/Dockerfile`
- `runtime-images/languages/go/<version>/project-template/README.en_US.md`
- `runtime-images/languages/go/<version>/project-template/README.zh_CN.md`
- `tests/runtime-smoke/languages/go/<version>/smoke.sh`

Typical string changes:

- `1.23.0` -> `1.24.0`
- `go-1.23.0` -> `go-1.24.0`
- `go1.23.0` -> `go1.24.0`
