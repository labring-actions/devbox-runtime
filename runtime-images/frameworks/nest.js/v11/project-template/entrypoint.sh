#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

app_env=${1:-development}
export HOME=${HOME:-/home/devbox}
export npm_config_cache=${npm_config_cache:-$HOME/.npm}
mkdir -p "$npm_config_cache"

# Development environment commands
dev_commands() {
    echo "Running NestJS development environment..."
    # Install development dependencies if they're not already installed
    npm install
    # Start NestJS with watch mode for auto-reloading
    npm run start:dev
}

# Production environment commands
prod_commands() {
    echo "Running NestJS production environment..."
    # Install only production dependencies
    npm install --production
    # Build the project
    npm run build
    # Start NestJS in production mode
    node dist/main
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
