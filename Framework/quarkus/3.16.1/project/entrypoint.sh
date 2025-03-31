#!/bin/bash

app_env=${1:-development}

# Define application name
app_name="code-with-quarkus"

# Development environment commands
dev_commands() {
    echo "Running Quarkus in development mode..."
    ./mvnw compile quarkus:dev -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080
}

# Production environment commands
prod_commands() {
    echo "Running Quarkus in production mode..."
    echo "Packaging the application..."
    ./mvnw package
    echo "Starting the application..."
    java -jar target/quarkus-app/quarkus-run.jar -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=8080
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi
