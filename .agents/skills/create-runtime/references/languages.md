# Language Runtime Guide

Use for `type=language`.

## Structure

Create the matching language paths:

```text
base-images/languages/<name>/<version>/       # only when a new base is needed
runtime-images/languages/<name>/<version>/
tests/runtime-smoke/languages/<name>/<version>/smoke.sh
```

For the standard runtime contract used by this repository, include `project-template/README.en_US.md`, `project-template/README.zh_CN.md`, and a `project-template/entrypoint.sh` unless the runtime is an explicitly documented sandbox exception. The entrypoint or startup file must match the language's actual execution model.

## Required decisions

Determine and document:

- the exact compiler/interpreter distribution and version;
- official download or package source and verification data;
- architecture support;
- required compiler, package manager, runtime, and environment variables;
- whether the template compiles before running, installs dependencies, or runs directly;
- the process port and how the smoke test observes it.

Do not use an interpreted-language startup command for a compiled language, or infer package-manager behavior from another language.

## Verification focus

The smoke test should verify the exact toolchain version or a stable version constraint, compile/install the minimal template when required, start the documented service, and check the expected response or process behavior. Keep the test deterministic and aligned with the README.
