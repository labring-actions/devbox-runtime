#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

app_env=${1:-development}
export HOME=${HOME:-/home/devbox}
export DOTNET_CLI_HOME=${DOTNET_CLI_HOME:-$HOME}
export NUGET_PACKAGES=${NUGET_PACKAGES:-$HOME/.nuget/packages}
mkdir -p "$DOTNET_CLI_HOME" "$NUGET_PACKAGES"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    dotnet run
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    dotnet publish -c Release
    dotnet ./bin/Release/net10.0/publish/hello_world.dll
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
