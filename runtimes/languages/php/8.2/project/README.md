# PHP Web Server Example

This is a simple PHP web server application example that demonstrates basic HTTP server functionality.

## Project Description

This project creates a basic PHP web server using PHP's built-in server capabilities. The server listens on port 8080 and returns a "Hello World!" message when accessed. The project supports both development and production environment modes.

## Environment

This project runs on a Debian 12 system with PHP, which is pre-configured in the Devbox environment. You don't need to worry about setting up PHP or system dependencies yourself. The development environment includes all necessary tools for building and running PHP applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`).


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 
