#!/bin/bash

app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    # Activate virtual environment
    source venv/bin/activate
    # Install dependencies
    pip install --break-system-packages django==4.2.16
    # In the development environment, we may need more debugging information
    python manage.py runserver 0.0.0.0:8000 --verbosity 2
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    # Activate virtual environment
    source venv/bin/activate
    # Install dependencies
    pip install --break-system-packages django==4.2.16
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
