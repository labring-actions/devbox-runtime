#!/bin/bash
app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running Nuxt development environment..."
    # Install dependencies and start development server
    pnpm install
    pnpm run dev
}

# Production environment commands
prod_commands() {
    echo "Running Nuxt production environment..."
    # Install dependencies, build, and start production server
    pnpm install
    pnpm run build
    # Start Nuxt server in production mode
    pnpm run start
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
