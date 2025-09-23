#!/bin/bash
app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running Hexo development server..."
    npm run server
}

# Production environment commands
prod_commands() {
    echo "Cleaning previous builds..."
    npm run clean
    echo "Building Hexo static site..."
    npm run build
    echo "Starting production server..."
    # For production, we can serve the static files in the public directory
    # Using a simple HTTP server (if installed)
    if command -v http-server &> /dev/null; then
        http-server ./public -p 4000
    # Or we can use Hexo's built-in server in production mode
    else
        npm run server -- -s
    fi
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
