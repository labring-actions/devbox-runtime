#!/bin/bash
cd /home/devbox/project

# Development environment commands
dev_commands() {
    echo "Running UmiJS development environment..."
    npm run dev
}

# Production environment commands
prod_commands() {
    echo "Building UmiJS for production..."
    npm run build
    echo "Starting UmiJS production server..."
    npm start
}

# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi