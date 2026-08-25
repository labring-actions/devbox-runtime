---
name: create-runtime
description: Use when a user asks to add a new DevBox runtime image for an operating system, language, or framework, including its base image, project template, smoke test, and conformance validation.
---

# Create a DevBox Runtime

Create a complete runtime contribution, not just an empty directory. The result must be explainable from the repository's existing conventions and verified by the repository's own checks.

## Required input

Obtain these three values:

- `type`: `operating-system`, `language`, or `framework`
- `name`: the runtime directory name
- `version`: the runtime directory version

If any value is missing, ask for it before touching files. Run the input validator before creating a target:

```bash
python3 .agents/skills/create-runtime/scripts/validate-runtime-input.py \
  --repo-root . \
  --type <type> \
  --name <name> \
  --version <version>
```

Do not continue if the validator fails. It protects against malformed names, path traversal, and overwriting an existing runtime.

## Workflow

1. Read [references/common-runtime-contract.md](references/common-runtime-contract.md).
2. Read exactly one type guide:
   - OS: [references/operating-systems.md](references/operating-systems.md)
   - language: [references/languages.md](references/languages.md)
   - framework: [references/frameworks.md](references/frameworks.md)
3. Inspect at least one nearby runtime of the same type. Prefer the closest runtime by base image, process model, and template shape; do not copy its version-specific facts.
4. Establish the facts that determine the implementation:
   - official source and exact version;
   - supported architectures;
   - required base image and its existing image/version convention;
   - installed tools and environment variables;
   - process, entrypoint, port, and health behavior;
   - project template commands and expected user-facing documentation.
5. If a required fact is unavailable or ambiguous, stop and ask a focused question. Do not guess.
6. Create the base image only when the new runtime needs one that is not already available. Create the runtime image, project template, localized documentation, and smoke test required by the selected type guide.
7. Register the exact runtime path in `tests/runtime-conformance/run.sh` and document its runtime-specific checks in `tests/runtime-conformance/README.md`; the conformance runner intentionally rejects unregistered paths.
8. Keep changes scoped to the new runtime. Do not modify existing runtimes, CI workflows, or shared tooling unless the new runtime requires a separately justified shared change.
9. Run the checks in the common contract and the selected type guide. Report every check that was skipped and why.

## No fallback without confirmation

Never silently:

- replace an exact version with `latest`;
- use an unverified mirror, package source, or base image;
- reduce architecture coverage because the current machine differs;
- omit a project template, localized README, or smoke test;
- replace a failed build or test with a weaker check;
- copy a neighboring runtime's behavior when its assumptions do not apply.

If the only way forward is a fallback, describe the trigger, the proposed behavior, and its impact, then wait for explicit user confirmation.

## Completion criteria

Before reporting completion, show evidence for:

- the validator accepted the target;
- all required files exist and executable scripts have the right mode;
- Dockerfiles and shell scripts pass available static checks;
- runtime conformance passes for the new target;
- the runtime path is registered in the conformance runner with assertions appropriate to its type;
- the matching smoke test passes, or its environmental blocker is reported precisely;
- no unrelated files were changed.

The skill creates repository files only. It does not publish images, push branches, or open pull requests unless the user separately asks for those actions.

## Example

For a new Python runtime, use `type=language`, `name=python`, and the requested exact `version`; inspect an existing Python runtime, add the matching base/runtime/template/smoke files, then run the validator and the repository's Python runtime checks. Do not derive installation details from the example's version.
