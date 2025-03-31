#!/bin/bash

app_env=${1:-development}

# NOTE: When using pip, add the parameter: --break-system-packages

. bin/activate
# Activate virtual environment

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    # In development environment, enable debug mode and hot reload
    export FLASK_ENV=development
    export FLASK_DEBUG=1
    python3 -u hello.py
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    # In production environment, use gunicorn as WSGI server
    echo "Installing gunicorn..."
    pip install gunicorn --break-system-packages
    gunicorn --workers=2 --bind=0.0.0.0:8080 "hello:app"
}

# Check environment variable to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
