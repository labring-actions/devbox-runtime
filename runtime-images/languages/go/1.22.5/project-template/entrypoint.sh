#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- \
        env \
            HOME=/home/devbox \
            USER=devbox \
            LOGNAME=devbox \
            GOPATH=/home/devbox/go \
            GOCACHE=/home/devbox/go/cache/go-build \
            bash "$SCRIPT_PATH" "$@"
fi

if [ -z "${HOME:-}" ]; then
    HOME="$(getent passwd "$(id -u)" | cut -d: -f6)"
    export HOME
fi

app_env=${1:-development}

# Define build target
build_target="hello_world"
export GOPATH="${GOPATH:-$HOME/go}"
if [ -z "${GOCACHE:-}" ] || [[ "$GOCACHE" == /root/* ]]; then
    export GOCACHE="$HOME/go/cache/go-build"
fi
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"
mkdir -p "$GOCACHE"

run_binary() {
    if [ ! -x "$build_target" ] || [ main.go -nt "$build_target" ]; then
        go build -o "$build_target" main.go
    fi
    exec "./$build_target"
}

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    run_binary
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    run_binary
}

# prod_commands
# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
