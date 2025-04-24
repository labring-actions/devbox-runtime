# MCP Proxy Server Example

This is an MCP format conversion tool that can expose STDIO services in the form of SSE, or vice versa.

## Project Description

This project is a tool used to convert MCP services at the STDIO level into SSE services, so that existing MCP STDIO programs can be developed and called on the public network.

When you use this template for development, you need to write your own MCP service program and related dependencies in this template, After you have completed writing your code, modify the startup command in the entrypoint file by adding the stdio startup command for your project. For example:

```
mcp-proxy --sse-port=8080 npx @modelcontextprotocol/server-puppeteer
```

Then start the project.

The source code for this project comes from https://github.com/sparfenyuk/mcp-proxy.

## Environment

This project runs on a Debian 12 system with Python 3.3.2 installed. The environment is pre-configured in Devbox, so you don't need to worry about setting up Python or other system dependencies yourself. If you need to make adjustments to meet your specific requirements, you can modify the configuration file accordingly.

## Project Execution

**Development Mode**: For a normal development environment, just enter Devbox and run "bash entrypoint.sh" in the terminal. This will compile and run the Java application.
**Production mode:** Once published, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script (run `bash entrypoint.sh production`).
DevBox: Code. Build. Deploy. We do the rest.
With DevBox, you can fully focus on writing great code while we take care of infrastructure, scaling, and deployment. Seamless development from start to production.