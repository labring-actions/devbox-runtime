
# Svelte Web Application Example

This is a modern web application example built with Svelte 6.4.0 and SvelteKit, a progressive JavaScript framework that focuses on high performance through compile-time optimizations.

## Project Description

This project creates a responsive single-page application using Svelte and SvelteKit. The application includes a home page with interactive components, an about page, and a Wordle-like game called "Sverdle". It demonstrates Svelte's reactive UI system, component architecture, and server-side rendering capabilities. The development server listens on port 5173 and provides hot module replacement for a smooth development experience.

## Environment

This project runs on a Debian 12 system with Node.js and Svelte 6.4.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or Svelte dependencies yourself. The development environment includes all necessary tools for building and running Svelte applications, including Vite for fast development and optimized builds. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the Svelte development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build optimized static files and serve them using the Svelte preview server.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.