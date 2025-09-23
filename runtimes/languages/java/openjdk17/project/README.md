# Java HTTP Server Example

This is a simple Java HTTP server application that demonstrates basic server functionality using Java's built-in HTTP server.

## Project Description

This project creates a lightweight HTTP server using Java's com.sun.net.httpserver package. The server listens on port 8080 and returns a "Hello World!" message when accessed. The project supports both development and production environment modes.

## Environment

This project runs on a Debian 12 system with Java 17 installed. The environment is pre-configured in the Devbox, so you don't need to worry about setting up Java or system dependencies yourself. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will compile and run the Java application.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script (run `bash entrypoint.sh production`).


DevBox: Code. Build. Deploy. We’ve Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 