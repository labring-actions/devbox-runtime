# Runtime README Example (s6-overlay Based)

> This document is a reusable README example for templates under `experimental/runtimes/*`.
> It is derived from the actual build and service wiring in `experimental/base-tools`.

## 1. Runtime Model

This runtime uses **s6-overlay v3** with container entrypoint:

```dockerfile
ENTRYPOINT ["/init"]
```

During base OS image build, `base-tools` performs:

- `install-s6.sh`: installs s6-overlay
- `configure-svc.sh`: generates/configures s6 service definitions
- Dockerfile sets `S6_STAGE2_HOOK=/etc/s6-overlay-hook/pre-rc-init.d/pre-rc-init.sh`

Related files:

- `experimental/images/operating-systems/*/*/Dockerfile`
- `experimental/images/operating-systems/*/*/build.sh`
- `experimental/base-tools/scripts/configure-svc.sh`

## 2. Boot Sequence (Important)

Startup flow:

1. `/init` starts s6-overlay.
2. `S6_STAGE2_HOOK` (`pre-rc-init.sh`) runs **before s6-rc compile** and toggles services by `DEVBOX_ENV`.
3. s6-rc compiles the service graph.
4. Enabled services are started.

`pre-rc-init.sh` reads `services.conf` and disables a service by:

- removing `/etc/s6-overlay/s6-rc.d/user/contents.d/<service>`
- removing `/etc/s6-overlay/s6-rc.d/<service>`

## 3. Default Services and Environment Matrix

Default `services.conf` (from `experimental/base-tools/scripts/svc/services.conf`):

| Service | development | production | Notes |
|---|---:|---:|---|
| `startup` | 1 | 1 | runs scripts under `/usr/start` |
| `entrypoint` | 1 | 1 | executes project `entrypoint.sh` |
| `crond` / `crond-log` | 1 | 1 | cron and logs |
| `sshd` / `sshd-log` | 1 | 0 | enabled only in development |

Additional note:

- `sdk-server` is always registered as an s6 service at build time, but at runtime it only starts when:
  - `DEVBOX_JWT_SECRET` is non-empty, and
  - `DEVBOX_ENV != production`.

## 4. Project Contract (for runtime users)

### 4.1 `entrypoint.sh`

Expected project path: `/home/devbox/project/entrypoint.sh`

The `entrypoint` s6 service executes it as user `devbox`:

```bash
./entrypoint.sh "${DEVBOX_ENV:-development}"
```

Recommended contract:

- First argument is runtime environment (`development` / `production`).
- Script branches behavior by that argument.
- If script is missing, startup continues (logged, but not fatal).

### 4.2 Startup Scripts in `/usr/start`

The `startup` oneshot service runs executable scripts under `/usr/start` in lexical order.

Requirements:

- Scripts should exit quickly.
- A failing script aborts the startup phase.

## 5. Custom s6 Service Example

If your runtime needs an additional long-running process `my-app`, create during image build:

```bash
# 1) service directory
mkdir -p /etc/s6-overlay/s6-rc.d/my-app/dependencies.d

# 2) service type
printf 'longrun\n' > /etc/s6-overlay/s6-rc.d/my-app/type

# 3) run script
cat >/etc/s6-overlay/s6-rc.d/my-app/run <<'RUN'
#!/command/with-contenv bash
set -euo pipefail
cd /home/devbox/project
exec ./my-app
RUN
chmod 700 /etc/s6-overlay/s6-rc.d/my-app/run

# 4) dependency (optional)
: > /etc/s6-overlay/s6-rc.d/my-app/dependencies.d/startup

# 5) add to user bundle
: > /etc/s6-overlay/s6-rc.d/user/contents.d/my-app
```

If the service should be environment-dependent, also update the hook-managed `services.conf`.

## 6. Reusable README Snippet

You can paste this sentence into each runtime README:

> This runtime is managed by s6-overlay. Container entrypoint is `/init`, and project `/home/devbox/project/entrypoint.sh` is executed by the `entrypoint` s6 service with `${DEVBOX_ENV}` as the first argument. Service enablement differs by environment via `S6_STAGE2_HOOK` + `services.conf` before s6-rc compilation.

## 7. Troubleshooting Commands

```bash
# inspect s6 service definitions
ls -la /etc/s6-overlay/s6-rc.d

# inspect enabled services in user bundle
ls -la /etc/s6-overlay/s6-rc.d/user/contents.d

# inspect environment
echo "$DEVBOX_ENV"

# inspect startup/entrypoint scripts
ls -la /usr/start
ls -la /home/devbox/project/entrypoint.sh
```
