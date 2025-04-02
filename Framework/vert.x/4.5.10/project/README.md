# Vert.x Web Server Example

This is a reactive web server application example built with Vert.x 4.5.10, a toolkit for building reactive applications on the JVM.

## Project Description

This project creates a lightweight, high-performance HTTP server using Vert.x. The server listens on port 8888 and returns a "Hello from Vert.x!" message when accessed. Built on Vert.x's event-driven, non-blocking model, this example demonstrates the core concepts of reactive programming and Vert.x's verticle deployment pattern.

## Environment

This project runs on a Debian 12 system with Java 17 and Vert.x 4.5.10, which is pre-configured in the Devbox environment. You don't need to worry about setting up Java, Maven, or Vert.x dependencies yourself. The development environment includes all necessary tools for building and running Vert.x applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will compile and run the Vert.x application using Maven.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build a fat JAR and run the application from it.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 