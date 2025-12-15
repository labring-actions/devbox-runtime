# Quarkus Web Application Example

This is a modern Java web application example built with Quarkus 3.16.1, a Kubernetes Native Java framework tailored for GraalVM and HotSpot, designed to optimize Java specifically for container environments.

## Project Description

This project creates a lightweight RESTful web service using Quarkus. The application demonstrates Quarkus's fast startup time, low memory footprint, and developer-friendly features like live coding. The server listens on port 8080 and provides simple REST endpoints that return "Hello from Quarkus REST" messages. Quarkus's reactive programming model ensures efficient handling of web requests, making it ideal for microservices and cloud-native applications.

## Environment

This project runs on a Debian 12 system with Java 17 and Quarkus 3.16.1, which is pre-configured in the Devbox environment. You don't need to worry about setting up Java, Maven, or Quarkus dependencies yourself. The development environment includes all necessary tools for building and running Quarkus applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will use Maven wrapper to compile and start the Quarkus application in development mode with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will use Maven wrapper to package the application and run the optimized JAR.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.

