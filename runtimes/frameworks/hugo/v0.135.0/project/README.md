# Hugo Static Site Example

This is a modern static site example built with Hugo v0.135.0, a fast and flexible static site generator written in Go, known for its speed, simplicity, and powerful content management capabilities.

## Project Description

This project creates a static website using Hugo. The application demonstrates Hugo's core features, including content management, templating system, and theme customization. Hugo's blazing-fast build process allows you to generate static HTML files that can be deployed to any web server or CDN. The development server listens on port 1313 and provides live reloading for a smooth content creation experience. Hugo's content-focused approach makes it perfect for blogs, documentation sites, portfolios, and corporate websites.

## Environment

This project runs on a Debian 12 system with Hugo v0.135.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Hugo, Go, or any dependencies yourself. The development environment includes all necessary tools for building and running Hugo sites. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the Hugo development server with live reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build optimized static files with minification enabled and serve them using Hugo's built-in server.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 