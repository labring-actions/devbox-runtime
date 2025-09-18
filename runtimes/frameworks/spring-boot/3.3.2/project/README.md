# Spring Boot Web Application Example

This is a modern Java web application example built with Spring Boot 3.3.2, a powerful framework that simplifies the development of production-ready applications.

## Project Description

This project creates a lightweight, RESTful web service using Spring Boot. The application demonstrates Spring Boot's auto-configuration capabilities and embedded application server. The server listens on port 8080 and can be easily extended to create RESTful endpoints. Spring Boot's opinionated approach reduces boilerplate code and configuration, allowing developers to focus on business logic rather than infrastructure concerns.

## Environment

This project runs on a Debian 12 system with Java 17 and Spring Boot 3.3.2, which is pre-configured in the Devbox environment. You don't need to worry about setting up Java, Maven, or Spring Boot dependencies yourself. The development environment includes all necessary tools for building and running Spring Boot applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will compile and start the Spring Boot application using Maven's spring-boot:run command.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build a clean production JAR and run the application.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 