# Create Runtime Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add and validate a repository-local `create-runtime` skill that creates complete OS, language, and framework runtime contributions without guessing or silently falling back.

**Architecture:** Keep the skill instructions small and route type-specific details into three reference files. Use one dependency-free Python validator for deterministic input/path checks; leave Dockerfile, installation-source, and startup decisions to the agent guided by repository examples and official evidence. Test the validator with Python's standard library and validate the skill package with the bundled skill validator plus repository checks.

**Tech Stack:** Markdown Agent Skill, Python 3 standard library, Bash, existing repository conformance tooling.

**Spec:** `docs/superpowers/specs/create-runtime-skill.md`

## Global Constraints

- Base the branch on `labring/main` at the refreshed remote commit.
- Supported types are exactly `operating-system`, `language`, and `framework`.
- Never overwrite an existing target.
- Never add unconfirmed fallback behavior.
- Do not create speculative runtime files or modify unrelated CI/workflows.
- Use the repository's existing runtime conformance and smoke-test conventions.

### Task 1: Add failing validator tests

**Files:**
- Create: `tests/skills/create-runtime/test_validate_runtime_input.py`
- Reference: `.agents/skills/create-runtime/scripts/validate-runtime-input.py`

**Interfaces:**
- The test invokes the validator as a subprocess with `--repo-root`, `--type`, `--name`, and `--version`.
- Successful output is JSON containing the normalized plural `kind`, the target runtime path, and the smoke-test path.
- Invalid input exits non-zero and writes a concise error to stderr.

- [ ] Write tests for valid normalization, traversal rejection, invalid type rejection, and duplicate target rejection.
- [ ] Run `python3 -m unittest discover -s tests/skills/create-runtime -v` and confirm it fails because the validator does not exist.

### Task 2: Implement the minimal validator

**Files:**
- Create: `.agents/skills/create-runtime/scripts/validate-runtime-input.py`

**Interfaces:**
- CLI accepts `--repo-root`, `--type`, `--name`, `--version`.
- Emits one JSON object on stdout for valid input.
- Exits `1` for invalid input, unsafe path components, or an existing target.

- [ ] Implement strict type mapping and component validation.
- [ ] Resolve paths beneath the supplied repository root and reject path escape.
- [ ] Check the runtime directory and its Dockerfile for collisions.
- [ ] Run the focused test suite and confirm it passes.

### Task 3: Write the skill package and references

**Files:**
- Create: `.agents/skills/create-runtime/SKILL.md`
- Create: `.agents/skills/create-runtime/references/common-runtime-contract.md`
- Create: `.agents/skills/create-runtime/references/operating-systems.md`
- Create: `.agents/skills/create-runtime/references/languages.md`
- Create: `.agents/skills/create-runtime/references/frameworks.md`

**Interfaces:**
- `SKILL.md` is the only discovery entrypoint.
- It invokes the validator before mutation and loads only the reference for the selected type.
- It instructs the agent to stop on unknown facts and to run existing conformance/smoke checks.

- [ ] Write the smallest workflow that covers the approved design.
- [ ] Add repository-specific commands and structural rules to references.
- [ ] Include one concise example for creating a language runtime.
- [ ] Ensure all user-facing wording describes outcomes for runtime contributors, not internal implementation details.

### Task 4: Add skill pressure scenarios and validate the package

**Files:**
- Create: `tests/skills/create-runtime/pressure-scenarios.md`

- [ ] Document no-guidance baseline risks for duplicate targets, ambiguous sources, missing inputs, and requested fallback behavior.
- [ ] Run the bundled `quick_validate.py` against `.agents/skills/create-runtime`.
- [ ] Run the validator tests again and inspect stdout/stderr behavior.

### Task 5: Run repository-level verification

**Files:**
- No source changes expected.

- [ ] Run the runtime conformance planner against representative existing runtimes.
- [ ] Run shell syntax checks for any skill scripts.
- [ ] Run the available repository test command for the new validator and skill package.
- [ ] Review the diff for unrelated changes and confirm user-owned `.DS_Store` and `tmp/` remain untouched.

### Task 6: Review and commit

- [ ] Re-read the specification and check every requirement against the final files.
- [ ] Request a focused code review of the branch diff.
- [ ] Fix critical or important findings and rerun verification.
- [ ] Commit the completed skill on `feat/create-runtime-skill` with a focused message.
- [ ] Do not push or publish without a separate user request.
