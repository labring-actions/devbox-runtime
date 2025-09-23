# Docusaurus Documentation Site Example

This is a modern documentation site example built with Docusaurus 3.5.2, a static site generator designed for creating documentation websites with a focus on ease of use, customizability, and SEO-friendly output.

## Project Description

This project creates a comprehensive documentation site using Docusaurus. The application demonstrates Docusaurus's core features, including documentation versioning, blog functionality, internationalization support, and MDX integration. The development server listens on port 3000 and provides hot reloading for a smooth content editing experience. Docusaurus's powerful features make it ideal for creating documentation sites, technical blogs, and product landing pages with clean, consistent navigation and excellent search engine optimization.

## Environment

This project runs on a Debian 12 system with Node.js and Docusaurus 3.5.2, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, npm, or Docusaurus dependencies yourself. The development environment includes all necessary tools for building and running Docusaurus sites. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the Docusaurus development server with hot-reload enabled.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will build a static site optimized for production and serve it.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production.











# Website

This website is built using [Docusaurus](https://docusaurus.io/), a modern static website generator.

### Installation

```
$ yarn
```

### Local Development

```
$ yarn start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

### Build

```
$ yarn build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.

### Deployment

Using SSH:

```
$ USE_SSH=true yarn deploy
```

Not using SSH:

```
$ GIT_USER=<Your GitHub username> yarn deploy
```

If you are using GitHub pages for hosting, this command is a convenient way to build the website and push to the `gh-pages` branch.
