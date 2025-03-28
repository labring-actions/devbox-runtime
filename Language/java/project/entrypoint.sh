#!/bin/bash

# Define build target
build_target="HelloWorld"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    javac "${build_target}.java"
    java "${build_target}"
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    javac "${build_target}.java"
    java "${build_target}"
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
