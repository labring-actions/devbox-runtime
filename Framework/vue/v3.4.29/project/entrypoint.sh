#!/bin/bash
# Development environment commands
dev_commands() {
    echo "Running Vue development environment with Vite..."
    npm run dev
}

# Production environment commands
prod_commands() {
    echo "Running Vue production environment..."
    npm run build
    # Use Vite's built-in preview server instead of serve
    npm run preview
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
