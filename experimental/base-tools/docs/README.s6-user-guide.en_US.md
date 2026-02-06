# S6 User Guide (Configure Your Own Services in Runtime)

## 1. What Is s6

`s6` is a lightweight process supervision and service management toolkit for Unix/Linux.
`s6-overlay` is the container-oriented integration of s6, providing `/init` as PID 1 and enabling robust multi-process runtime behavior in containers.

In this runtime, s6 mainly provides:

- Signal forwarding and graceful shutdown
- Child process reaping (avoid zombie processes)
- Service dependency and startup ordering
- Supervision and restart behavior for long-running services

## 2. s6 Overview (in This Runtime)

| Component/Path | Purpose | User edits? |
|---|---|---|
| `/init` | Container entrypoint, starts s6-overlay lifecycle | No (usually) |
| `/etc/s6-overlay/s6-rc.d/<service>` | Per-service definition (`type`, `run`, `finish`, dependencies) | Yes (for custom services) |
| `/etc/s6-overlay/s6-rc.d/user/contents.d` | User bundle list; decides what is compiled into the runtime graph | Yes |
| `S6_STAGE2_HOOK` + `/etc/s6-overlay-hook/pre-rc-init.d/services.conf` | Pre-compile environment-based service toggling | Yes (if env-specific behavior is needed) |
| `/usr/start` | One-shot startup scripts directory | Yes (for initialization tasks) |
| `/home/devbox/project/entrypoint.sh` | Project entry script, triggered by `entrypoint` service | Yes (app startup) |

## 3. Three Core Facts First

1. Service definitions live in: `/etc/s6-overlay/s6-rc.d`
2. Enabled services (user bundle) live in: `/etc/s6-overlay/s6-rc.d/user/contents.d`
3. s6-rc compilation happens early during container startup (`/init` stage)

So:

- After changing s6 definitions, you usually need a **container/DevBox restart**.
- `entrypoint.sh` is triggered by the `entrypoint` s6 service, after s6-rc compilation has already happened.

## 4. Which Mechanism to Use

- Only need to start your main app: use project `entrypoint.sh`
- Need one-time initialization: put scripts under `/usr/start`
- Need a supervised long-running process with restart behavior: create an s6 `longrun` service

## 5. Quick Example: Add a `my-api` Longrun Service

Run these commands inside the container (`devbox` user has sudo by default):

```bash
# 1) Create service directory
sudo mkdir -p /etc/s6-overlay/s6-rc.d/my-api/dependencies.d

# 2) Set service type
printf 'longrun\n' | sudo tee /etc/s6-overlay/s6-rc.d/my-api/type >/dev/null

# 3) Create run script (example: start project binary)
sudo tee /etc/s6-overlay/s6-rc.d/my-api/run >/dev/null <<'RUN'
#!/command/with-contenv bash
set -euo pipefail
cd /home/devbox/project
exec ./my-api
RUN
sudo chmod 700 /etc/s6-overlay/s6-rc.d/my-api/run

# 4) (Optional) depend on startup
sudo touch /etc/s6-overlay/s6-rc.d/my-api/dependencies.d/startup

# 5) Add to user bundle (required)
sudo touch /etc/s6-overlay/s6-rc.d/user/contents.d/my-api
```

Then restart DevBox/container and verify:

```bash
ls -la /etc/s6-overlay/s6-rc.d/my-api
ls -la /etc/s6-overlay/s6-rc.d/user/contents.d | grep my-api
ps -ef | grep my-api | grep -v grep
```

## 6. Environment-Based Toggle (development / production)

This runtime uses a pre-compile hook reading:

- `/etc/s6-overlay-hook/pre-rc-init.d/services.conf`

Format:

```text
service_name|development_enable|production_enable
```

Example: enable `my-api` only in development:

```text
my-api|1|0
```

Notes:

- Restart is required after changing `services.conf`.
- Services not listed in `services.conf` are treated as enabled by default (if present in user bundle).

## 7. Remove a Custom Service

```bash
sudo rm -f /etc/s6-overlay/s6-rc.d/user/contents.d/my-api
sudo rm -rf /etc/s6-overlay/s6-rc.d/my-api
```

Then restart DevBox/container.

## 8. FAQ

### Q1: I created s6 services in `entrypoint.sh`. Why did they not start now?

Because s6-rc compiles before `entrypoint.sh` runs. New definitions created there are applied on the **next restart**.

### Q2: I created a service directory, why is it still not running?

Common causes:

- Missing `user/contents.d/<service>`
- `run` is not executable (`chmod 700`)
- Final `exec` target is missing or not executable

### Q3: Can I use only s6 and skip `entrypoint.sh`?

Yes. You can fully model your app as longrun services. Just ensure:

- Required baseline services are preserved (for example startup, crond)
- You understand the dev/prod service matrix impact

## 9. Recommended Practice

- Start simple with `entrypoint.sh`, then split into dedicated longrun services.
- One longrun should manage one main process, with final `exec`.
- Keep one-time setup in `/usr/start`, not in longrun `run` scripts.
