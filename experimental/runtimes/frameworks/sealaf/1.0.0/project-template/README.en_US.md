# Sealaf Web Application Framework Example

This is a modern function-based web application framework example built with Sealaf 1.0.0, providing a clean and powerful API development experience.

## Project Description

This project creates a lightweight function-programming web service framework showcasing Simple Web's file-system routing capabilities. The application uses a functional approach for writing backend APIs with zero configuration and automatic route generation. The server listens on port 2342 and provides a clean, intuitive API development experience. The framework supports WebSocket, XML parsing, CORS, and other features, making it suitable for rapid development of small applications, microservices, and cloud functions.

## Environment

This project runs on a Debian 12 system with Node.js and Sealaf 1.0.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, pnpm, or Sealaf dependencies yourself. The development environment includes all necessary tools for building and running Sealaf applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will install dependencies and start the Simple Web development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will install dependencies, build an optimized production build, and run the application.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.

