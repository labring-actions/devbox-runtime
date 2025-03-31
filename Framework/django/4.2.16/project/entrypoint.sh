#!/bin/bash

app_env=${1:-development}

# ※To use pip, parameters need to be added: --break-system-packages
. bin/activate
# Activate virtual environment

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    # In the development environment, we may need more debugging information
    python manage.py runserver 0.0.0.0:8000 --verbosity 2
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    # In the production environment, we may need to add other parameters
    python manage.py runserver 0.0.0.0:8000
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
