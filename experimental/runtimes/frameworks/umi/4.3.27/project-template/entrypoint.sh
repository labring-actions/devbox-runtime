#!/bin/bash
app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running UmiJS development environment..."
    # Install dependencies and start development server
    npm install
    npm run dev
}

# Production environment commands
prod_commands() {
    echo "Building UmiJS for production..."
    # Install dependencies, build, and start production server
    npm install
    npm run build
    echo "Starting UmiJS production server..."
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
