#!/bin/bash
app_env=${1:-development}

# Define build target
build_target="starter-1.0.0-SNAPSHOT-fat.jar"

# Development environment commands
dev_commands() {
    echo "Running development environment commands..."
    echo "Compiling may take 3-5 minutes, please be patient"
    # Using maven wrapper to compile and run as mentioned in README
    ./mvnw clean compile exec:java
}

# Production environment commands
prod_commands() {
    echo "Running production environment commands..."
    # Package the application if not already packaged
    echo "Packaging application..."
    ./mvnw clean package
    # Run the packaged jar
    java -jar target/$build_target
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
