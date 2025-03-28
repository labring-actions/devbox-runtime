#!/bin/bash

# Development environment commands
dev_commands() {
    echo "Running Nuxt development environment..."
    pnpm run dev
}

# Production environment commands
prod_commands() {
    echo "Running Nuxt production environment..."
    pnpm run build
    # Start Nuxt server in production mode
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
