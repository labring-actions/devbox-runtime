#!/bin/bash

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    mvn spring-boot:run
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    mvn clean install
    mvn spring-boot:run
}

# prod_commands
# Check environment variables to determine the running environment
if [ -n "$SEALOS_DEVBOX_NAME" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
