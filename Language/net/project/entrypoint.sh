#!/bin/bash

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    dotnet run
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    dotnet publish -c Release
    dotnet ./bin/Release/net8.0/publish/hello_world.dll
}

Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
