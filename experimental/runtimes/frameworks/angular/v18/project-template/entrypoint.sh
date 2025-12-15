#!/bin/bash
app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running Angular development server..."
    # Install dependencies and start development server
    npm install
    npm run start -- --host 0.0.0.0
}

# Production environment commands
prod_commands() {
    echo "Building Angular for production..."
    # Install dependencies, build, and serve production bundle
    npm install
    npm run build

    echo "Starting production server on port 4200..."
    serve -s dist/project -l 4200
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
