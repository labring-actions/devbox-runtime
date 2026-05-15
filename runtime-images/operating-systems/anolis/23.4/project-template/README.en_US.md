# AnolisOS 23.4 Runtime Template

This template provides a minimal **operating-system runtime** based on Anolis OS 23.4.
Use it when you need a localized Linux base and full control of your language, framework, or application stack.

## Runtime Summary

- OS version: `Anolis OS 23.4`
- Base runtime image: `anolis-23.4`
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
- Uses `PORT` environment variable when provided, defaults to `8080`.
- Serves files from `/home/devbox/project/www`.
- Prefers `busybox httpd` and falls back to `python3 -m http.server` when that applet is unavailable.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Replace `entrypoint.sh` with your own process startup script.
- Use `dnf` or `yum` to install application dependencies in this AnolisOS base.
- Align container exposed ports with your service port.
