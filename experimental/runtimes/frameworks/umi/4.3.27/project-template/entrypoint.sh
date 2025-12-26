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
