#!/bin/bash
app_env=${1:-development}

# Define build target
build_target="hello_world"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    php -S 0.0.0.0:8080 \
        -d display_errors=0 \
        -d error_reporting=E_ALL \
        -d log_errors=1 \
        "${build_target}.php"
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    php -S 0.0.0.0:8080 \
        -d display_errors=0 \
        -d opcache.enable=1 \
        -d opcache.memory_consumption=128 \
        "${build_target}.php"
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
