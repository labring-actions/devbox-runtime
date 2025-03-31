#!/bin/bash

cd /home/devbox/project

# Development environment commands
dev_commands() {
    echo "Running Angular development server..."
    npm run start -- --host 0.0.0.0
}

# Production environment commands
prod_commands() {
    echo "Building Angular for production..."
    npm run build
    
    echo "Setting up Express server for production..."
    
    echo "Starting Express server on port 4200..."
    npm run start -- --host 0.0.0.0
}

Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi