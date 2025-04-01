#!/bin/bash
app_env=${1:-development}

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
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
