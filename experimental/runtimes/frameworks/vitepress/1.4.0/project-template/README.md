# VitePress Documentation Site Example

This is a modern documentation site example built with VitePress 1.4.0, a static site generator powered by Vue and Vite.

## Project Description

This project creates a documentation website using VitePress, featuring markdown extensions, syntax highlighting, custom containers, and interactive Vue components. The development server listens on port 4173 and provides instant hot updates. The example includes a home page with customizable hero section and feature listings, as well as sample pages demonstrating VitePress's powerful markdown and API capabilities.

## Environment

This project runs on a Debian 12 system with Node.js and VitePress 1.4.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or VitePress dependencies yourself. The development environment includes all necessary tools for building and running VitePress documentation sites, including Vite for fast development and optimized builds. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the VitePress development server with hot-reload enabled on port 4173.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build optimized static files and serve them using VitePress's preview server.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 