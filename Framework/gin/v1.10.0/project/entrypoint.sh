#!/bin/bash

# Define build target
build_target="hello_world"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    # Set Gin mode to debug for development
    export GIN_MODE=debug
    go run main.go
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    # Set Gin mode to release for production
    export GIN_MODE=release
    go build -o $build_target main.go
    ./$build_target
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi