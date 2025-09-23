# Iris Web Application Example

This is a modern Go web application example built with Iris v12.2.11, a fast, simple, and efficient web framework for Go that provides a robust set of features for building powerful web applications.

## Project Description

This project creates a lightweight RESTful web service using Iris. The application demonstrates Iris's core features, including middleware support, JSON response handling, and efficient request routing. The server listens on port 8080 and provides a simple `/ping` endpoint that returns a JSON response. Iris's clean API design and performance-focused architecture make it ideal for building high-throughput web services and APIs with minimal code.

## Environment

This project runs on a Debian 12 system with Go and Iris v12.2.11, which is pre-configured in the Devbox environment. You don't need to worry about setting up Go, dependencies, or Iris framework yourself. The development environment includes all necessary tools for building and running Go applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will run the Iris application directly from source code using `go run main.go`.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized executable binary and run the application.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 