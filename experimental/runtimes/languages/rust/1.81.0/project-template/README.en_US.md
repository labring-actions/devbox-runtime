# Rust 1.81.0 Runtime Template

This template provides a minimal Rust HTTP service using Actix Web for DevBox runtime **Rust 1.81.0**.

## Runtime Summary

- Language version: `Rust 1.81.0`
- Base runtime image: `rust-1.81.0`
- Entrypoint script: `entrypoint.sh`
- Default service port: `8080`

## Template Files

- `Cargo.toml` / `Cargo.lock`: project and dependency metadata
- `src/main.rs`: Actix Web server entry
- `entrypoint.sh`: development/production startup logic

## Run in DevBox

Run commands from `/home/devbox/project`.

### Development mode

```bash
bash entrypoint.sh
```

Behavior:
- Runs `cargo run`.

### Production mode

```bash
bash entrypoint.sh production
```

Behavior:
- Builds release binary: `cargo build --release --bin hello_world`
- Runs binary: `./target/release/hello_world`

## Verify Service

```bash
curl http://127.0.0.1:8080
```

Expected output:

```text
Hello, World!
```

## Customization

- Extend routes and middleware in `src/main.rs`.
- Add crates in `Cargo.toml`.
- Keep `entrypoint.sh` binary target aligned with `Cargo.toml` bin name.
