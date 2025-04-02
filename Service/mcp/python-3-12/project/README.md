# Python MCP Server Example

This is a simple Python MCP server application that uses Claude's official MCP-related dependencies to implement the remote server function of SSE communication.

## Project Description

This project uses Python's FastMCP package to create an SSE MCP server. And a MCP Tool is built in, which returns "Hello, World!" when called.

This project supports development and production environment modes.

## Environment

This project runs on a Debian 12 system with Python 3.3.2 installed. The environment is pre-configured in Devbox, so you don't need to worry about setting up Python or other system dependencies yourself. If you need to make adjustments to meet your specific requirements, you can modify the configuration file accordingly.

## Project Execution

**Development Mode**: For a normal development environment, just enter Devbox and run "bash entrypoint.sh" in the terminal. This will compile and run the Java application.
**Production mode:** Once published, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script (run `bash entrypoint.sh production`).
DevBox: Code. Build. Deploy. We do the rest.
With DevBox, you can fully focus on writing great code while we take care of infrastructure, scaling, and deployment. Seamless development from start to production.