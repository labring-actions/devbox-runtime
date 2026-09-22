#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

app_env=${1:-development}
export HOME=${HOME:-/home/devbox}
export HOST=${HOST:-0.0.0.0}
export PORT=${PORT:-3000}
export npm_config_cache=${npm_config_cache:-$HOME/.npm}
mkdir -p "$npm_config_cache"

dev_commands() {
    echo "Running Next.js development environment..."
    npm install
    npm run dev -- --hostname "$HOST" --port "$PORT"
}

prod_commands() {
    echo "Running Next.js production environment..."
    npm install
    npm run build
    npm prune --omit=dev
    npm run start -- --hostname "$HOST" --port "$PORT"
}

if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
