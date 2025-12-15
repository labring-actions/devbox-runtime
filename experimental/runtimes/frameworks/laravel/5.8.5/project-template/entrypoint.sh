#!/bin/bash

app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running Laravel development server..."
    # Install dependencies and start development server
    composer install
    php artisan serve --host=0.0.0.0 --port=8000
}

# Production environment commands
prod_commands() {
    echo "Running Laravel production server..."
    # Install dependencies and start production server
    composer install --no-dev --optimize-autoloader
    php artisan serve --host=0.0.0.0 --port=8000
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
