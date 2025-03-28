#!/bin/bash

# Define build target
build_target="hello_world"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    export ENV="development"
    gcc -Wall ${build_target}.c -o $build_target || exit 1
    ./$build_target
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    export ENV="production"
    gcc -O2 -Wall ${build_target}.c -o $build_target || exit 1
    nohup ./$build_target > server.log 2>&1 &
    echo "Server started in background. Check server.log for details."
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
