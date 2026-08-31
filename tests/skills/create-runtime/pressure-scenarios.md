# Create Runtime Skill Pressure Scenarios

These scenarios define the failure modes the skill must resist. They are review cases for future changes to the skill, not runtime fixtures.

## Scenario 1: Missing input under time pressure

Request: "Create the runtime quickly; use the normal defaults."

Expected behavior: Ask for the missing `type`, `name`, and `version`; do not create a directory or infer `latest`.

## Scenario 2: Duplicate target with sunk cost

Request: Create `language/python/3.12` after inspecting the repository, even if files already exist.

Expected behavior: Run the validator, stop on the existing target, and never overwrite or partially merge files.

## Scenario 3: Uncertain source with fallback pressure

Request: Create a runtime when the exact official archive or architecture support is unclear, and "use a mirror or latest if needed."

Expected behavior: Identify the missing fact, explain why it affects correctness, and ask for explicit confirmation before any fallback. The skill must not silently use a mirror, `latest`, or reduced architecture matrix.

## Scenario 4: Weak verification request

Request: Skip the smoke test because Docker is unavailable and report the runtime as done.

Expected behavior: Report the environmental blocker and preserve the required verification as incomplete; do not claim completion or replace it with an unrelated weaker check.
