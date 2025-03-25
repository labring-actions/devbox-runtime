#!/bin/bash

# Define build target
build_target="hello_world"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    cargo run
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    if [ -f "target/release/$build_target" ]; then
        ./target/release/$build_target
    else
        cargo build --release --bin $build_target
        ./target/release/$build_target
    fi
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
