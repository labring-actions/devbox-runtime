#!/bin/bash
app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running NestJS development environment..."
    # Install development dependencies if they're not already installed
    npm install
    # Start NestJS with watch mode for auto-reloading
    npm run start:dev
}

# Production environment commands
prod_commands() {
    echo "Running NestJS production environment..."
    # Install only production dependencies
    npm install --production
    # Build the project
    npm run build
    # Start NestJS in production mode
    node dist/main
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
