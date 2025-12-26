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
    echo "Running Express.js development environment..."
    # Install development dependencies if they're not already installed
    npm install
    # Start Express with nodemon for auto-reloading
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
