# Operating System Runtime Guide

Use for `type=operating-system`.

## Structure

Inspect a nearby OS runtime and create the corresponding layers as required:

```text
base-images/operating-systems/<name>/<version>/
runtime-images/operating-systems/<name>/<version>/
tests/runtime-smoke/operating-systems/<name>/<version>/smoke.sh
```

The final runtime must include `project-template/README.en_US.md`, `project-template/README.zh_CN.md`, and a `project-template/entrypoint.sh` for the standard non-sandbox contract. Confirm any exception from an explicitly registered conformance branch before creating files.

## Required decisions

Determine and document:

- the official OS image or package source and exact release;
- amd64/arm64 support and any package availability differences;
- default shell, user, home, workdir, locale, timezone, and common utilities;
- SSH or other services required by the repository's OS contract;
- how the project entrypoint is invoked and how it stays alive for the smoke test.

Do not assume a distribution's package manager, init system, or architecture support from its name.

## Verification focus

The smoke test should prove the OS identity, required `devbox` user and project directory, required common commands, template files, and entrypoint behavior. Add only assertions supported by the runtime contract; do not copy language-specific checks into an OS runtime.
