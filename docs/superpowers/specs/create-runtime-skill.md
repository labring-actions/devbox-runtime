# Create Runtime Skill Specification

## Goal

Add a repository-local Agent Skill at `.agents/skills/create-runtime/` that guides Codex to create a complete, reviewable DevBox runtime for an operating system, language, or framework. A completed runtime includes the image definitions, project template, smoke test, documentation, and repository conformance verification required by the selected runtime type.

## User Contract

The skill accepts three required values:

- `type`: `operating-system`, `language`, or `framework`
- `name`: the runtime directory name, such as `fedora`, `python`, or `nest.js`
- `version`: the runtime directory version, such as `44`, `3.13`, or `v12`

The skill must map singular input types to repository directory names:

- `operating-system` -> `operating-systems`
- `language` -> `languages`
- `framework` -> `frameworks`

The skill must reject missing, malformed, unsafe, or duplicate runtime and smoke-test targets before creating files. An existing base-image directory may be reused only after its compatibility is verified.

## Required Behavior

1. Inspect the repository and select the closest existing runtime of the same type as a structural reference.
2. Determine the official source, exact version, supported architectures, base image, process model, port, and project startup behavior from reliable project or official documentation.
3. Stop and ask the user when a required fact is unknown or ambiguous. The skill must not guess.
4. Do not add fallback behavior without explicit user confirmation. In particular, do not silently substitute `latest`, an unverified mirror, an alternate base image, a reduced architecture set, a missing smoke test, or a weaker validation command.
5. Create only the files justified by the selected runtime type and its actual architecture. Do not create placeholder files that make an incomplete runtime appear complete.
6. Run static checks, the repository runtime conformance check, and the selected runtime smoke test when the environment supports them. Report checks that cannot run instead of hiding them.
7. Never overwrite an existing runtime target.

## Runtime Layout Contract

Every runtime image must have a `Dockerfile` under `runtime-images/<kind>/<name>/<version>/`. The runtime directory may also contain `build.sh`, `project-template/`, configuration files, and localized README files as required by its behavior.

A runtime with a project template must provide both `README.en_US.md` and `README.zh_CN.md`, an executable `entrypoint.sh` when the image contract requires a project entrypoint, and a smoke test at the matching path under `tests/runtime-smoke/<kind>/<name>/<version>/smoke.sh`.

If a runtime depends on a new base image, the skill must create the corresponding `base-images/<kind>/<name>/<version>/` definition and ensure the runtime Dockerfile references the exact generated image name and version convention used by this repository.

The skill must use the existing repository conformance tooling rather than inventing a competing conformance implementation. The planner only creates a CI matrix; the runtime must also be registered with runtime-specific assertions in `tests/runtime-conformance/run.sh` and documented in `tests/runtime-conformance/README.md`:

- `.github/scripts/runtime-conformance.py`
- `tests/runtime-conformance/run.sh`
- `tests/runtime-conformance/README.md`

## Skill Package

The skill package contains:

- `SKILL.md`: discovery description, workflow, stopping rules, type routing, and verification checklist.
- `references/common-runtime-contract.md`: shared repository conventions and commands.
- `references/operating-systems.md`: OS-specific file and behavior requirements.
- `references/languages.md`: language-specific file and behavior requirements.
- `references/frameworks.md`: framework-specific dependency and startup requirements.
- `scripts/validate-runtime-input.py`: deterministic input, path-safety, and duplicate-target validation. It must not generate Dockerfiles or make source-selection decisions.

## Non-Goals

- Do not create a generic runtime generator that guesses installation or startup behavior.
- Do not change existing runtime implementations while creating a new one unless the new runtime requires a documented shared fix.
- Do not modify CI workflows to accommodate a single runtime.
- Do not publish images, push branches, or open pull requests automatically.
