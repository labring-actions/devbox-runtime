# Hexo Blog Example

This is a modern static site generator built with Hexo v7.3.0, a fast, simple, and efficient blog framework powered by Node.js that provides a robust set of features for building powerful websites and blogs.

## Project Description

This project creates a static website/blog using Hexo. The application demonstrates Hexo's core features, including content management, theme customization, and efficient static site generation. The development server listens on port 4000 by default and provides a complete blog structure with posts, pages, and customizable themes. Hexo's clean design and performance-focused architecture make it ideal for building fast-loading websites and blogs with minimal configuration.

## Environment

This project runs on a Debian 12 system with Node.js and Hexo v7.3.0, which is pre-configured in the Devbox environment. You don't need to worry about setting up Node.js, dependencies, or the Hexo framework yourself. The development environment includes all necessary tools for building and running Hexo applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files like `_config.yml` accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will start the Hexo development server, allowing you to preview your site at http://localhost:4000.

**Production mode:** To generate the static files for deployment, you can run `npm run build` or `hexo generate`. This will create production-ready HTML, CSS, and JavaScript files in the `public` directory that can be deployed to any static hosting service.

DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great content while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 