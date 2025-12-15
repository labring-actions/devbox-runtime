#!/bin/bash

app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running Astro development environment..."
    # Install dependencies and start development server
    npm install
    npm run dev -- --host 0.0.0.0
}

# Production environment commands
prod_commands() {
    echo "Running Astro production environment..."
    # Install dependencies, build, and serve production bundle
    npm install
    npm run build
    echo "Starting Astro production server..."
    npm run preview -- --host 0.0.0.0
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
