# TypeScript MCP Server Example

This is a simple TypeScript web server application example that demonstrates Model Context Protocol (MCP) server functionality.

### How to develop

1. Run `bash entrypoint.sh`, this will start the TypeScript server in development mode with hot-reloading and launch the MCP inspector for debugging.
   > Note: You can also run `npm run dev` to start the server and MCP inspector.
2. Your MCP server will be running on [localhost:3001](http://localhost:3001)
3. Open the MCP inspector in [localhost:5173](http://localhost:5173)

## Project Description

This project creates a lightweight MCP server using TypeScript and Express.js. The server implements the Model Context Protocol (v1.8.0) and provides a development environment with integrated debugging capabilities. The project supports both development and production environment modes with proper TypeScript compilation and execution.

## Environment

This project runs on a Node.js environment with TypeScript development tools, which are pre-configured in the Devbox environment. You don't need to worry about setting up TypeScript compiler or system dependencies yourself. The development environment includes all necessary tools for building and running TypeScript applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the TypeScript server in development mode with hot-reloading and launch the MCP inspector for debugging.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build an optimized JavaScript bundle and run it.

DevBox: Code. Build. Deploy. We've Got the Rest.
With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.
