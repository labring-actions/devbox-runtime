# Debian 12.6 Runtime Template

This template provides a minimal **operating-system runtime** based on Debian 12.6.
It is useful when you want a clean Linux environment first, then install your own stack.

## Runtime Summary

- OS version: `Debian 12.6`
- Base runtime image: `debian-12.6`
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

- Replace `entrypoint.sh` with your own bootstrap logic.
- Install language/framework dependencies on top of this base runtime.
- Keep your service listening port consistent with DevBox exposed port.
