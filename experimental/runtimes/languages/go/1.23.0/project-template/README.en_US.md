# Go 1.23.0 Runtime Template

This template provides a minimal Go HTTP service for DevBox runtime **Go 1.23.0**.

## Runtime Summary

- Language version: `Go 1.23.0`
- Base runtime image: `go-1.23.0`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `main.go`: HTTP server using `net/http`
- `entrypoint.sh`: mode-aware startup script

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Runs `go run main.go` for fast iteration.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Builds binary: `go build -o hello_world main.go`
- Runs binary: `./hello_world`

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Add handlers/routes in `main.go`.
- Replace the single-file layout with a standard module structure when scaling.
- Keep the entrypoint build target aligned with your binary name.
