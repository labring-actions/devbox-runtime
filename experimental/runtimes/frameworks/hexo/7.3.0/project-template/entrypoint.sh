#!/bin/bash
app_env=${1:-development}

# Force set HOME to the current user's home directory
# s6-setuidgid may inherit HOME=/root from the parent process, so we need to override it
CURRENT_USER=$(whoami)
USER_HOME=$(getent passwd "$CURRENT_USER" | cut -d: -f6)
if [ -z "$USER_HOME" ]; then
    USER_HOME="/home/$CURRENT_USER"
fi
export HOME="$USER_HOME"

# Set npm cache directory explicitly to avoid permission issues
export npm_config_cache="${HOME}/.npm"
mkdir -p "${npm_config_cache}"

# Development environment commands
dev_commands() {
    echo "Running Hexo development server..."
    # Install dependencies and start development server
    npm install
    npm run server
}

# Production environment commands
prod_commands() {
    echo "Running Hexo production environment..."
    # Install dependencies
    npm install
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
