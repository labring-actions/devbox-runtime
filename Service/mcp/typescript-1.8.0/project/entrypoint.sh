#!/bin/bash

app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running Express.js development environment..."
    # Install development dependencies if they're not already installed
    npm install

    # Start the inspector and the server
    npm run dev
}

# Production environment commands
prod_commands() {
    echo "Running Express.js production environment..."
    # Install only production dependencies
    npm install --production
    # Start Express in production mode
    npm start
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi