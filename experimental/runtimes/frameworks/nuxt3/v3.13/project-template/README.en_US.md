# Nuxt3 Web Application Example

This is a modern Vue.js full-stack application example built with Nuxt3 v3.13, a powerful framework based on Vue 3 that provides server-side rendering, static site generation, and a rich development experience.

## Project Description

This project creates a single-page application built with Nuxt3. The application showcases Nuxt3's core features, including automatic route generation, server-side rendering, API integration, and static site generation capabilities. The development server listens on port 3000 and provides hot-reloading for a smooth development experience. The project structure follows Nuxt3's convention-based design, simplifying the development process and increasing productivity.

## Environment

This project runs on a Debian 12 system with Node.js and Nuxt3 v3.13, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, pnpm, or Nuxt dependencies yourself. The development environment includes all necessary tools for building and running Nuxt applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will install dependencies and start the Nuxt development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will install dependencies, build optimized static files, and start the Nuxt production server.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.

