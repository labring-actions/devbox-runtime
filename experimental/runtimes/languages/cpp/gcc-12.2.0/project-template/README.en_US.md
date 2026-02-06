# C++ GCC 12.2.0 Runtime Template

This template provides a minimal C++ HTTP service for DevBox runtime **GCC 12.2.0 (C++)**.

## Runtime Summary

- Compiler version: `g++ (GCC) 12.2.0`
- Base runtime image: `cpp-gcc-12.2.0`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `hello_world.cpp`: socket-based HTTP server
- `entrypoint.sh`: compile-and-run script for both modes

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Compiles with `g++ hello_world.cpp -o hello_world`
- Runs `./hello_world`

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Uses the same compile-and-run command path.

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Add routing or protocol handling logic in `hello_world.cpp`.
- Introduce `Makefile` or CMake for larger codebases.
- Keep build target name in `entrypoint.sh` consistent with your binary output.
