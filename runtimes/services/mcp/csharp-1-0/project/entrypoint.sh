#!/bin/bash

app_env=${1:-development}

# Development environment commands
dev_commands() {
    echo "Running MCP Csharp development environment..."
    dotnet run
}

# Production environment commands
prod_commands() {
    echo "Running MCP Csharp production build..."
    dotnet publish
    echo "Starting MCP Csharp production preview server..."
    dotnet run -- --host 0.0.0.0 --port 3001
}

# Check environment variables to determine the running environment
if [ "$app_env" = "production" ] || [ "$app_env" = "prod" ] ; then
    echo "Production environment detected"
    prod_commands
else
    echo "Development environment detected"
    dev_commands
fi