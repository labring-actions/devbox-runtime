# Chi Web Application Example

This is a modern Go web application example built with Chi v5.1.0, a lightweight, idiomatic, and composable router for building Go HTTP services with clean, elegant patterns and middleware support.

## Project Description

This project creates a lightweight web server using Chi. The application demonstrates Chi's core features, including its lightweight router, middleware system, and clean request handling patterns. The server listens on port 8080 and provides a simple endpoint that returns a "welcome" message. Chi's minimalist design, built on top of the standard net/http library without external dependencies, makes it ideal for building high-performance RESTful services and web applications with clean, maintainable code.

## Environment

This project runs on a Debian 12 system with Go and Chi v5.1.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Go, dependencies, or Chi framework yourself. The development environment includes all necessary tools for building and running Go applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will run the Chi application directly from source code using `go run main.go`.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized executable binary and run the application.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 