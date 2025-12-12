#!/bin/bash

app_env=${1:-development}

# Define build target
build_target="hello_world"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    NODE_ENV=development node "${build_target}.js"
}

# Production environment commands
# ※Compiled before release
prod_commands() {
    echo "Running production environment commands..."
    NODE_ENV=production node "${build_target}.js"
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
