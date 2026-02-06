# C GCC 12.2.0 Runtime Template

This template provides a minimal C HTTP service for DevBox runtime **GCC 12.2.0 (C)**.

## Runtime Summary

- Compiler version: `gcc 12.2.0`
- Base runtime image: `c-gcc-12.2.0`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080` (overridable by `PORT` in code)

## Template Files

- `hello_world.c`: socket-based HTTP server with graceful shutdown
- `entrypoint.sh`: mode-aware compile-and-run script

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Builds with `gcc -Wall hello_world.c -o hello_world`
- Runs `./hello_world`

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Builds optimized binary: `gcc -O2 -Wall hello_world.c -o hello_world`
- Runs `./hello_world`

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World from Development Server!
```

## Customization

- Extend request parsing and routing in `hello_world.c`.
- Export `PORT` if you need a non-default listening port.
- Replace manual build commands with Makefile when project complexity increases.
