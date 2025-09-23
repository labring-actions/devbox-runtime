# Gin Web Application Example

This is a modern Go web application example built with Gin v1.10.0, a high-performance HTTP web framework written in Go, known for its martini-like API with much better performance and lower memory usage.

## Project Description

This project creates a lightweight RESTful web service using Gin. The application demonstrates Gin's core features, including its lightning-fast HTTP router, middleware support, and JSON response handling. The server listens on port 8080 and provides a simple endpoint that returns a JSON "Hello World" message. Gin's excellent performance metrics and minimalist design philosophy make it ideal for building high-throughput microservices and web APIs with clean, maintainable code.

## Environment

This project runs on a Debian 12 system with Go and Gin v1.10.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Go, dependencies, or Gin framework yourself. The development environment includes all necessary tools for building and running Go applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will run the Gin application directly from source code with `GIN_MODE=debug` for detailed logging.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized executable binary with `GIN_MODE=release` for maximum performance and run the application.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 