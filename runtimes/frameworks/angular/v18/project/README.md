# Angular Web Application Example

This is a modern web application example built with Angular v18, a platform and framework for building client-side applications in HTML, TypeScript, and CSS with a focus on performance and developer productivity.

## Project Description

This project creates a single-page application using Angular. The application demonstrates Angular's core features, including its component-based architecture, powerful dependency injection system, and comprehensive tooling. The development server listens on port 4200 and provides hot reloading for a smooth development experience. Angular's robust features make it ideal for building dynamic, enterprise-grade applications with maintainable code structure and optimized performance.

## Environment

This project runs on a Debian 12 system with Node.js and Angular v18, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or Angular dependencies yourself. The development environment includes all necessary tools for building and running Angular applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the Angular development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized production bundle and serve it.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.











# Project

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 18.2.9.

## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The application will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via a platform of your choice. To use this command, you need to first add a package that implements end-to-end testing capabilities.

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI Overview and Command Reference](https://angular.dev/tools/cli) page.
