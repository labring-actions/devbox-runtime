# Offline managed Skills

This image owns the Sealos Skill bundle; codex-gateway only supplies its existing binary. Network access to GitHub is needed during image build, never during Skill preparation.

The `skills` build stage fetches `SEALOS_SKILLS_REPOSITORY` at the full `SEALOS_SKILLS_REVISION` commit. The default source is `https://github.com/norberia/sealos-skills-next.git`, pinned to `bdd824cf2fd6c72896f8e201f32259cc8aed3f98`, not a floating runtime branch. This preserves the repository selected by the former Brain `DEPLOY_SKILL_SOURCE` setting. Change these build arguments for a reviewed preview revision. Do not put private repository credentials in build arguments.

The build reads every Skill in the repository's canonical `plugins/sealos/skills` tree, not the top-level `skills` symlink aliases. There is no Skill-name allowlist or fixed Skill count. The source tree determines the manifest; build/verify reject empty, malformed or incomplete bundles. Updating the pinned commit picks up the source's full Skill set. Repository overrides must provide the same plugin layout.

The image contains:

- `/opt/sealai/skill-bundle`: complete Skill resource trees and a schema-1 manifest (source commit, Skill names, file SHA-256).
- `/opt/sealai/skill-bundle.mjs`: build, verify and local preparation implementation using the existing Node runtime.
- `/usr/local/bin/sealai-prepare-skills`: fixed entry point for Brain, serialized with `flock`. Lock waiting and preparation share a 28-second budget (1-second kill grace), below Brain's 30-second RPC cap. Node, flock and timeout use absolute system paths; Node environment overrides are cleared.

Run the entry point as the Devbox user after repository cloning; the workspace root must already exist. Chat has no repository clone and explicitly passes `--init-workspace`. Both modes prepare `/home/devbox/project/.agents/skills`, preserving unrelated Skills and `skills-lock.json`. Repository Skill symlinks are preserved verbatim when their destinations resolve inside the workspace, including aliases into `.claude/skills`. Dangling, cyclic and out-of-workspace links, special files, and symlinked workspace/Skill roots are rejected. Referenced directories are also checked, without reading/hashing user file contents. Image-owned bundles still reject all symlinks.

Each replacement uses an exclusive `mkdtemp` transaction under `.sealai-skill-transactions`, outside `.agents` and on the workspace filesystem. If killed between renames, the next invocation restores the backup before creating any live Skill directory. Stages are never promoted during recovery because they may be incomplete. After publication, cleanup is best-effort; ambiguous recovery state fails closed and preserves files for inspection. Legacy PID-named backups are restored only when there is one backup and no live tree. This helper is not a security boundary against concurrent malicious filesystem mutation by the workspace owner, nor a power-loss durability guarantee.

Recovery type-checks transaction trees without following symlinks, restores the previous tree to its live location, then validates link destinations before preparing again. Relative aliases must not be resolved from a temporary backup/stage path. Copying and cleanup do not follow links; replacing an alias whose name matches a bundled Skill leaves the alias destination untouched.

The wrapper parses and validates success before printing schema, status, revision, bundle digest and Skill count as JSON. Empty/malformed output is failure. Failures use fixed codes, including preparation timeout, never file contents or raw exceptions. Missing or corrupt bundles fail closed. There is no npx/download fallback.

## Verification

From the repository root:

```sh
node --test base-images/frameworks/sandbox/v1/skill-bundle*.test.mjs
node base-images/frameworks/sandbox/v1/verify-pinned-source.mjs
```

The existing Runtime Smoke workflow can run `tests/runtime-smoke/frameworks/sandbox/v1/smoke.sh` in the final sandbox image. For an offline acceptance check, run that script in a disposable image container with `--network none` as the `devbox` user. The real Devbox check is separate: clone a repository first, prepare as the actual user, and exercise Chat loadSkill/loadSkillResource and a GitHub Deployment Task.

## Rollout

1. Build and publish the sandbox/v1 base image with this bundle, then its runtime image if that is the deployment target. Use the existing runtime build pipeline; do not change the Gateway image for this feature.
2. Inspect the built image's manifest and run the offline smoke check. Retain the source revision and immutable image digest in release evidence.
3. Finish active/blocked Brain Deployment Tasks. Set Brain's `DEVBOX_RUNTIME_IMAGE` to the verified immutable sandbox image and remove nonempty `DEPLOY_SKILL_SOURCE` overrides while deploying the matching Brain change.
4. Confirm fresh Chat and GitHub runtimes prepare the same revision. Old Chat runtimes are not deleted; their existing lifecycle handles retention.

Rollback restores the previous Brain/runtime image pair. Never compensate for a broken image by re-enabling a runtime internet installer. Image registry availability is still required to start a new Devbox; this change removes only Skill-install network dependencies.
