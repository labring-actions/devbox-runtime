# Offline managed Skills

This image owns the Sealos Skill bundle; codex-gateway only supplies its existing binary. Network access to GitHub is needed during image build, never during Skill preparation.

The `skills` build stage fetches `SEALOS_SKILLS_REPOSITORY` at the full `SEALOS_SKILLS_REVISION` commit. The default source is `https://github.com/norberia/sealos-skills-next.git`, pinned to `bdd824cf2fd6c72896f8e201f32259cc8aed3f98`, not a floating runtime branch. This preserves the repository selected by the former Brain `DEPLOY_SKILL_SOURCE` setting. Change these build arguments for a reviewed preview revision. Do not put private repository credentials in build arguments.

The build reads the repository's canonical `plugins/sealos/skills` tree, not the top-level `skills` symlink aliases. It includes `use-sealos`, `sealos-deploy`, and `k8s-kaniko-job` with their resources. Repository overrides must provide the same plugin layout.

The image contains:

- `/opt/sealai/skill-bundle`: complete Skill resource trees and a schema-1 manifest (source commit, Skill names, file SHA-256).
- `/opt/sealai/skill-bundle.mjs`: build, verify and local preparation implementation using the existing Node runtime.
- `/usr/local/bin/sealai-prepare-skills`: fixed entry point for Brain, serialized with `flock` (10-second wait).

Run the entry point as the Devbox user after repository cloning. It prepares `/home/devbox/project/.agents/skills`, preserving unrelated Skills and `skills-lock.json`. It rejects symlinks instead of following repository-controlled destinations. Bundled names are refreshed from the image; staging and backup protect against caught replacement errors. A hard process kill between renames can leave a backup directory; do not delete it blindly. This helper is not a security boundary against concurrent malicious filesystem mutation by the workspace owner.

Success prints only schema, status, revision, bundle digest and Skill count as JSON. Failure prints a fixed error code, never file contents or raw exceptions. Missing or corrupt bundles fail closed. There is no npx/download fallback. Brain applies a 30-second execution cap.

## Verification

From the repository root:

```sh
node --test base-images/frameworks/sandbox/v1/skill-bundle.test.mjs
```

The existing Runtime Smoke workflow can run `tests/runtime-smoke/frameworks/sandbox/v1/smoke.sh` in the final sandbox image. For an offline acceptance check, run that script in a disposable image container with `--network none` as the `devbox` user. The real Devbox check is separate: clone a repository first, prepare as the actual user, and exercise Chat loadSkill/loadSkillResource and a GitHub Deployment Task.

## Rollout

1. Build and publish the sandbox/v1 base image with this bundle, then its runtime image if that is the deployment target. Use the existing runtime build pipeline; do not change the Gateway image for this feature.
2. Inspect the built image's manifest and run the offline smoke check. Retain the source revision and immutable image digest in release evidence.
3. Finish active/blocked Brain Deployment Tasks. Set Brain's `DEVBOX_RUNTIME_IMAGE` to the verified immutable sandbox image and remove nonempty `DEPLOY_SKILL_SOURCE` overrides while deploying the matching Brain change.
4. Confirm fresh Chat and GitHub runtimes prepare the same revision. Old Chat runtimes are not deleted; their existing lifecycle handles retention.

Rollback restores the previous Brain/runtime image pair. Never compensate for a broken image by re-enabling a runtime internet installer. Image registry availability is still required to start a new Devbox; this change removes only Skill-install network dependencies.
