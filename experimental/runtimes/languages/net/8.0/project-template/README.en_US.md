# .NET Web API Example

This is a simple ASP.NET Core web application example that demonstrates basic HTTP server functionality.

## Project Description

This project creates a minimal .NET web API that listens on port 8080 and returns a "Hello, World" message when accessed. The project supports both development and production environment modes.

## Environment

This project runs on a Debian 12 system with .NET 8, which is pre-configured in the Devbox environment. You don't need to worry about setting up the .NET SDK or runtime dependencies yourself. The development environment includes all necessary tools for building and running ASP.NET Core applications. If you need to make adjustments to match your specific requirements, you can modify the project configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will run the application using `dotnet run`.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will publish the application in Release configuration and run the published DLL.


DevBox: Code. Build. Deploy. We’ve Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 