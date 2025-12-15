#!/bin/bash

app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    # Use Maven to run Spring Boot in development mode
    mvn spring-boot:run
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    # Clean, install, and run Spring Boot application
    mvn clean install
    mvn spring-boot:run
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
