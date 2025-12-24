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
    echo "Running Svelte development environment..."
    # Install dependencies and start development server
    npm install
    npm run dev -- --host 0.0.0.0
}

# Production environment commands
prod_commands() {
    echo "Running Svelte production build..."
    # Install dependencies, build, and serve production bundle
    npm install
    npm run build
    echo "Starting Svelte production preview server..."
    npm run preview -- --host 0.0.0.0 --port 5173
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
