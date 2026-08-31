#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

app_env=${1:-development}
build_target="HelloWorld"

dev_commands() {
    echo "Running development environment commands..."
    javac "${build_target}.java"
    exec java "${build_target}"
}

prod_commands() {
    echo "Running production environment commands..."
    javac "${build_target}.java"
    exec java "${build_target}"
}

if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ]; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
