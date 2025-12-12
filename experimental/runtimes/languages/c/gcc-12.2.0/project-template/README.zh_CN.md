# C HTTP Server Example

This is a simple C web server application example that demonstrates basic HTTP server functionality.

## Project Description

This project creates a lightweight HTTP server using C socket programming. The server listens on port 8080 and returns a "Hello, World from Development Server!" message when accessed. The project supports both development and production environment modes with graceful shutdown capabilities.

## Environment

This project runs on a Debian 12 system with C development tools, which are pre-configured in the Devbox environment. You don't need to worry about setting up gcc compiler or system dependencies yourself. The development environment includes all necessary tools for building and running C applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will compile your C code with debugging flags and run the executable.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized executable binary and run it.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 