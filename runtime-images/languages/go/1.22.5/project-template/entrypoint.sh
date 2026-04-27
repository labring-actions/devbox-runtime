#!/bin/bash
app_env=${1:-development}

# Define build target
build_target="hello_world"
export PATH="/usr/local/go/bin:$HOME/go/bin:$PATH"
export GOCACHE="${GOCACHE:-$HOME/go/cache/go-build}"
mkdir -p "$GOCACHE"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    go run main.go
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    go build -o $build_target main.go
    ./$build_target
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
