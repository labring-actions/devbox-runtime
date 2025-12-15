# Nginx Web Server Example

This is a modern web server example built with Nginx 1.22.1, a high-performance HTTP and reverse proxy server known for its stability, rich feature set, and low resource consumption.

## Project Description

This project creates a simple web server using Nginx. The application demonstrates Nginx's core features, including static file serving, reverse proxy capabilities, and efficient request handling. The server listens on port 80 and serves static HTML files. Nginx's event-driven architecture makes it ideal for serving high-traffic websites and as a reverse proxy for application servers.

## Environment

This project runs on a Debian 12 system with Nginx 1.22.1, which is pre-configured in the Devbox environment. You don't need to worry about setting up Nginx or configuring the server yourself. The development environment includes all necessary tools for running Nginx. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will check the Nginx configuration and start the Nginx server in foreground mode.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will check the Nginx configuration and start the Nginx server in foreground mode.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.

