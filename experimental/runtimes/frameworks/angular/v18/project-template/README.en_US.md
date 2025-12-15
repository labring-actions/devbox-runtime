# Angular Web Application Example

This is a modern web application example built with Angular v18, a platform and framework for building client-side applications in HTML, TypeScript, and CSS with a focus on performance and developer productivity.

## Project Description

This project creates a single-page application using Angular. The application demonstrates Angular's core features, including its component-based architecture, powerful dependency injection system, and comprehensive tooling. The development server listens on port 4200 and provides hot reloading for a smooth development experience. Angular's robust features make it ideal for building dynamic, enterprise-grade applications with maintainable code structure and optimized performance.

## Environment

This project runs on a Debian 12 system with Node.js and Angular v18, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or Angular dependencies yourself. The development environment includes all necessary tools for building and running Angular applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the Angular development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will install dependencies, build an optimized production bundle, and serve it using the `serve` static file server on port 4200.

Within Devbox, you only need to focus on development - you can trust that everything is application-ready XD


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.

