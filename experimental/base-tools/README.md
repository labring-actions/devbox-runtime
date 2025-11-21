# base-tools installation scripts

These helper scripts under `base-tools/scripts/` install small utilities used by the images (s6-overlay, cron runner, ssh proxy, etc.).

Environment variables

- `ARCH` (required): the target architecture name used to choose the correct upstream release artifact. The scripts expect a handful of common values and will normalize them before downloading.
  - Supported input values: `x86_64`, `amd64`, `aarch64`, `arm64`, `armv7`, `armhf`
  - Normalized download artifact names:
    - `x86_64` or `amd64` -> `amd64` (or `x86_64` for s6-overlay where appropriate)
    - `aarch64` or `arm64` -> `arm64`
    - `armv7` or `armhf` -> `armv7`
  - If an unsupported value is provided the script exits with a message like: `Unsupported ARCH: <value>`

- Script-specific version variables (optional — each script provides a sensible default):
  - `S6_OVERLAY_VERSION` — default shown in `install-s6.sh` (e.g. `3.2.1.0`)
  - `SUPERCRONIC_VERSION` — default shown in `install-crond.sh` (e.g. `v0.1.15`)
  - `SSHPROXY_VERSION` — default shown in `install-sshproxy.sh` (e.g. `v0.1.15`)

Usage examples

- Run one of the install scripts directly (sets `ARCH` inline):

```bash
ARCH=x86_64 bash base-tools/scripts/install-crond.sh  
ARCH=arm64 bash base-tools/scripts/install-s6.sh  
ARCH=amd64 SSHPROXY_VERSION=v0.1.15 bash base-tools/scripts/install-sshproxy.sh
```

- In a Dockerfile you can pass `ARCH` as a build-arg or environment variable:

```dockerfile
ARG ARCH=amd64
ENV ARCH=${ARCH}
COPY scripts/ /opt/base-tools/
RUN bash /opt/base-tools/install-s6.sh
```

Notes

- The scripts normalize common synonyms (for example `x86_64` and `amd64`) so callers can use whichever convention they prefer.
- If you edit or add install scripts, document any new environment variables here and provide defaults in the script.

If you want, I can also run `shellcheck` against the scripts or add CI checks to validate `ARCH` values automatically.
