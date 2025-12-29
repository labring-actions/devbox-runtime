#!/bin/bash
app_env=${1:-development}

# # Force set HOME to the current user's home directory
# # s6-setuidgid may inherit HOME=/root from the parent process, so we need to override it
# # Get the actual home directory from /etc/passwd for the current user
# CURRENT_USER=$(whoami)
# USER_HOME=$(getent passwd "$CURRENT_USER" | cut -d: -f6)
# if [ -z "$USER_HOME" ]; then
#     # Fallback: construct home directory path
#     USER_HOME="/home/$CURRENT_USER"
# fi
# export HOME="$USER_HOME"

# # Set npm cache directory explicitly to avoid permission issues
# # This ensures npm uses the devbox user's cache instead of root's cache
# export npm_config_cache="${HOME}/.npm"
# mkdir -p "${npm_config_cache}"

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
