# Alpine 3.22 Runtime Template

This template provides a minimal **operating-system runtime** based on Alpine Linux 3.22.
Use it when you want a compact Linux environment and full control of your language, framework, or application stack.

## Runtime Summary

- OS version: `Alpine Linux 3.22`
- Base runtime image: `alpine-3.22`
- Package manager: `apk`
- C library: `musl`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `entrypoint.sh`: creates a static `index.html` and starts a lightweight HTTP server

## Run in DevBox

Run commands from `/home/devbox/project`.

```bash
bash entrypoint.sh
```

Behavior:

- Uses the `PORT` environment variable when provided, and defaults to `8080`.
- Serves files from `/home/devbox/project/www`.
- Prefers BusyBox `httpd` and falls back to `python3 -m http.server` when that applet is unavailable.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Package Management

Install application dependencies with `apk`:

```bash
sudo apk add --no-cache file
```

## Compatibility

Alpine uses musl instead of the glibc used by Debian, Ubuntu, and Fedora. The image includes `gcompat`, `libgcc`, and `libstdc++` for practical compatibility, but these packages do not make every glibc-only binary or native extension compatible. Validate third-party development tools against Alpine before relying on them.

## Customization

- Replace `entrypoint.sh` with your own process startup script.
- Use `apk` to install application dependencies.
- Align container exposed ports with your service port.
