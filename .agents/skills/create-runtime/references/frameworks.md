# Framework Runtime Guide

Use for `type=framework`.

## Structure

Create the matching framework paths:

```text
base-images/frameworks/<name>/<version>/       # only when a new base is needed
runtime-images/frameworks/<name>/<version>/
tests/runtime-smoke/frameworks/<name>/<version>/smoke.sh
```

Framework runtimes commonly consume an existing language runtime. The standard contract requires `project-template/README.en_US.md`, `project-template/README.zh_CN.md`, and a `project-template/entrypoint.sh` unless the framework is an explicitly registered sandbox exception. Reuse an existing language image only after confirming the exact image name, tag, architecture support, and build contract.

## Required decisions

Determine and document:

- the framework's exact version and supported language/runtime versions;
- the package manager and lockfile strategy;
- dependency installation and production build commands;
- default port and bind address;
- production entrypoint and process lifetime;
- environment variables required by the framework;
- whether the project template is a minimal runnable service or a static/configuration template.

Do not copy a neighboring framework's dependency or startup command unless the framework's own documentation and template support it.

## Verification focus

The smoke test should install or build the minimal template as the image does, start the documented production process, and verify the expected service behavior. Check that the runtime image references a real language/base image and that its version convention matches the repository's image naming rules.
