# Rust Actix Web Example Project

This is a simple Rust web server application example that demonstrates basic HTTP server functionality.

## Project Description

This project creates a basic HTTP server that listens on 0.0.0.0:8080 and returns a "Hello, World!" message. The project supports both development and production environment modes.

## Environment

This project runs on a Debian 12 system with Rust, which is pre-configured in the Devbox environment. You don't need to worry about setting up Rust or system dependencies yourself. The development environment includes all necessary tools for building and running Rust applications with the Actix web framework. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script and command parameters.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.
