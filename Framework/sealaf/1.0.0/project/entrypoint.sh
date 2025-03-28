#!/bin/bash

# Development environment commands
dev_commands() {
    echo "Running Simple Web development server..."
    pnpm run dev
}

# Production environment commands
prod_commands() {
    echo "Running Simple Web production environment..."
    pnpm run build:clean
    echo "Starting Simple Web production server..."
    NODE_ENV=production pnpm run start
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
