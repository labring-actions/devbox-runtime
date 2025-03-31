#!/bin/bash

cd /home/devbox/project

# Development environment commands
dev_commands() {
    echo "Running Docusaurus development environment..."
    npm run start -- --host 0.0.0.0
}

# Production environment commands
prod_commands() {
    echo "Running Docusaurus production environment..."
    npm run build
    echo "Starting Docusaurus production server..."
    npm run serve -- --host 0.0.0.0
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi