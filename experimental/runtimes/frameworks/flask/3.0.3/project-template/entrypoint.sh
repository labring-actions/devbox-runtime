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
    pip install --break-system-packages flask
    # In development environment, enable debug mode and hot reload
    export FLASK_ENV=development
    export FLASK_DEBUG=1
    python3 -u hello.py
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
    # Install dependencies including gunicorn for production
    pip install --break-system-packages flask gunicorn
    # In production environment, use gunicorn as WSGI server
    gunicorn --workers=2 --bind=0.0.0.0:8080 "hello:app"
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
