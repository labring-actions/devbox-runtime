# C# MCP Server Example

This is a C# and ASP.NET Core-based MCP (Model Context Protocol) server example project that demonstrates basic server functionality implementation.

## Project Description

This project creates a lightweight MCP server using the ASP.NET Core framework. The server runs on port 3001 by default and provides example tools such as Echo and LLM sampling. The project supports both development and production environment modes with graceful shutdown capabilities.

## Environment

This project runs on a Debian 12 system with .NET 9.0 SDK. The development environment is pre-configured in the Devbox environment, so you don't need to worry about installing .NET SDK or system dependencies. The development environment includes all necessary tools for building and running C# applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will compile your C# code with debugging flags and run the executable.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script (run `bash entrypoint.sh production`). This will build an optimized executable binary and run it.

DevBox: Code. Build. Deploy. We've Got the Rest.
With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.
