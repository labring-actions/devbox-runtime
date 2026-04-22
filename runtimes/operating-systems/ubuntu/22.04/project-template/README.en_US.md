# Ubuntu 22.04 Runtime Template

This template provides a minimal **operating-system runtime** based on Ubuntu 22.04.
Use it when you need a general-purpose Ubuntu environment and full control of your software stack.

## Runtime Summary

- OS version: `Ubuntu 22.04`
- Base runtime image: `ubuntu-22.04`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `entrypoint.sh`: creates a static `index.html` and starts `busybox httpd`

## Run in DevBox

Run commands from `/home/devbox/project`.

```bash
bash entrypoint.sh
```

Behavior:
- Uses `PORT` environment variable when provided, defaults to `8080`.
- Serves files from `/home/devbox/project/www`.

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
- Install your required runtime/toolchain directly in this Ubuntu base.
- Align container exposed ports with your service port.
