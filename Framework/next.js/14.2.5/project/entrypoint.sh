#!/bin/bash

# Development environment commands
dev_commands() {
    echo "Running Next.js development environment..."
    pnpm run dev
}

# Production environment commands
prod_commands() {
    echo "Running Next.js production environment..."
    pnpm run build
    echo "Starting Next.js production server..."
    pnpm run start
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
