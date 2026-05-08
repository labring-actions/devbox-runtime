#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

app_env=${1:-development}

# Define build target
build_target="hello_world"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    export ENV="development"
    gcc -Wall "${build_target}.c" -o "$build_target"
    exec "./$build_target"
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    export ENV="production"
    gcc -O2 -Wall "${build_target}.c" -o "$build_target"
    exec "./$build_target"
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
