#!/bin/bash

app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running VitePress development environment..."
    npm run docs:dev -- --host 0.0.0.0 --port 4173
}

# Production environment commands
prod_commands() {
    echo "Running VitePress production environment..."
    npm run docs:build
    echo "Starting VitePress production server..."
    npm run docs:preview -- --host 0.0.0.0 --port 4173
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
