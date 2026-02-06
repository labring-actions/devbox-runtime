# Nginx 1.22.1 Runtime Template

This template provides a static-site runtime powered by **Nginx 1.22.1**.

## Runtime Summary

- Framework/runtime version: `Nginx 1.22.1`
- Base runtime image: `nginx-1.22.1`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080` (configured in project `nginx.conf`)

## Template Files

- `index.html`: default static homepage
- `nginx.conf`: project-level server block (listens on `8080`)
- `entrypoint.sh`: validates config and starts nginx in foreground

## Run in DevBox

Run commands from `/home/devbox/project`.

### Start service

```bash
bash entrypoint.sh
```

Behavior:
- Runs `nginx -t` to validate configuration.
- Starts Nginx with `daemon off` mode.

### Production mode argument

```bash
bash entrypoint.sh production
```

Behavior:
- The script behavior is identical; extra argument is ignored.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

## Customization

- Modify `index.html` for static content.
- Update `nginx.conf` to add reverse proxy, cache, gzip, or routing rules.
- Keep listen port in `nginx.conf` aligned with exposed container port.
