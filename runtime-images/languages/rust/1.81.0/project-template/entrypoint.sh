#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- env HOME=/home/devbox USER=devbox LOGNAME=devbox bash "$SCRIPT_PATH" "$@"
fi

if [ -z "${HOME:-}" ]; then
    HOME="$(getent passwd "$(id -u)" | cut -d: -f6)"
    export HOME
fi

app_env=${1:-development}

# Define build target
build_target="hello_world"
release_binary="target/release/$build_target"
export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
export PATH="$CARGO_HOME/bin:$PATH"

template_is_newer() {
    [ -x "$release_binary" ] || return 0
    [ -n "$(find Cargo.toml Cargo.lock src -newer "$release_binary" -print -quit 2>/dev/null)" ]
}

run_release_binary() {
    if template_is_newer; then
        cargo build --release --locked --bin "$build_target"
    fi
    exec "./$release_binary"
}

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    if ! template_is_newer; then
        exec "./$release_binary"
    fi
    cargo run --locked --bin "$build_target"
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    run_release_binary
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
