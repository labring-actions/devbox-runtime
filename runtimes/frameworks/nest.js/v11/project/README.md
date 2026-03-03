# NestJS Web Application Example

This is a modern Node.js web application example built with NestJS 11, a progressive Node.js framework for building efficient, reliable and scalable server-side applications. NestJS is built with TypeScript and combines elements of OOP, FP, and FRP.

## Project Description

This project is based on the official [NestJS TypeScript starter](https://github.com/nestjs/typescript-starter) repository. It demonstrates NestJS's core features, including its dependency injection system, decorators-based routing, and module organization. The server listens on port 3000 and provides a basic endpoint that returns a "Hello World!" message. NestJS's architecture is heavily inspired by Angular, making it ideal for building well-structured, maintainable enterprise-grade applications and APIs.

## Environment

This project runs on a Debian 12 system with Node.js and NestJS 11, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or NestJS dependencies yourself. The development environment includes all necessary tools for building and running NestJS applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will install development dependencies and start the NestJS application with watch mode for auto-reloading.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will install only production dependencies, build the project, and run the NestJS application in production mode.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.
