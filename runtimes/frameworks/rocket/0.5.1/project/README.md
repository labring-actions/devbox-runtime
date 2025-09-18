# Rocket Web Application Example

This is a modern Rust web application example built with Rocket 0.5.1, a fast and secure web framework that makes it simple to write reliable web applications without sacrificing flexibility, usability, or type safety.

## Project Description

This project creates a lightweight web server using Rocket. The application demonstrates Rocket's routing system and configuration capabilities. The server listens on all network interfaces (0.0.0.0) and responds with "Hello, world!" when accessed at the root path. Rocket's type-safe approach to web development ensures robust error handling and request validation, while its simple syntax allows for clean, maintainable code.

## Environment

This project runs on a Debian 12 system with Rust and Rocket 0.5.1, which is pre-configured in the Devbox environment. You don't need to worry about setting up Rust, Cargo, or Rocket dependencies yourself. The development environment includes all necessary tools for building and running Rust applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will compile and run the Rocket application using Cargo's development mode.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized release binary and run the application.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 