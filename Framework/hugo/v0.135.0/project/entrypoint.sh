#!/bin/bash

# Development environment commands
dev_commands() {
    echo "Running Hugo development server..."
    hugo server --bind 0.0.0.0 --port 1313
}

# Production environment commands
prod_commands() {
    echo "Building Hugo static site for production..."
    hugo --minify
    echo "Starting server for production build..."
    # Use Hugo's server in production mode instead of Python's HTTP server
    hugo server --bind 0.0.0.0 --port 1313 --environment production --minify --disableLiveReload
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
