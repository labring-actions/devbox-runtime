#!/bin/bash
app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running Vue development environment with Vite..."
    # Install dependencies and start development server
    npm install
    npm run dev
}

# Production environment commands
prod_commands() {
    echo "Running Vue production environment..."
    # Install dependencies, build, and serve production bundle
    npm install
    npm run build
    # Use Vite's built-in preview server instead of serve
    npm run preview
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
