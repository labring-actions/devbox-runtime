# UmiJS Web Application Example

This is a modern React application example built with UmiJS 4.3.27, a powerful React framework that includes routing, state management, and build utilities out of the box.

## Project Description

This project creates a single-page application using UmiJS framework. The application includes basic routing between home and documentation pages, with a clean development experience. UmiJS provides convention over configuration, so the project structure is organized in a standardized way. The development server offers hot module replacement for a smooth development experience.

## Environment

This project runs on a Debian 12 system with Node.js and UmiJS 4.3.27, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or UmiJS dependencies yourself. The development environment includes all necessary tools for building and running React applications with UmiJS, including Vite for fast development and optimized builds. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the UmiJS development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build optimized static files and serve them using the UmiJS production server.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 