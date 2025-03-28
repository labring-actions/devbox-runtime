#!/bin/bash

# Development environment commands
dev_commands() {
    echo "Running Svelte development environment..."
    npm run dev -- --host 0.0.0.0
}

# Production environment commands
prod_commands() {
    echo "Running Svelte production build..."
    npm run build
    echo "Starting Svelte production preview server..."
    npm run preview -- --host 0.0.0.0 --port 5173
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
