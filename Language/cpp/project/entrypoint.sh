#!/bin/bash

# Define build target
build_target="hello_world"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    g++ ${build_target}.cpp -o $build_target
    ./$build_target
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    echo "Building C++ application..."
    g++ ${build_target}.cpp -o $build_target
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
