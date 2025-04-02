# Flask Web Application Example

This is a modern Python web application example built with Flask 3.0.3, a lightweight WSGI web application framework designed to make getting started quick and easy, with the ability to scale up to complex applications.

## Project Description

This project creates a lightweight web service using Flask. The application demonstrates Flask's core features, including its simple routing system and development server. The server listens on port 8080 and provides a basic endpoint that returns a "Hello World!" message. Flask's minimalist design and flexibility make it ideal for both small projects and large applications, with an extensive ecosystem of extensions for adding functionality like database integration, form validation, and authentication.

## Environment

This project runs on a Debian 12 system with Python and Flask 3.0.3, which is pre-configured in the Devbox environment. You don't need to worry about setting up Python, virtual environments, or Flask dependencies yourself. The development environment includes all necessary tools for building and running Flask applications. If you need to make adjustments to match your specific requirements, you can modify the configuration files accordingly.

## Project Execution

**Development mode:** For normal development environment, simply enter Devbox and run `bash entrypoint.sh` in the terminal. This will activate the virtual environment and start the Flask development server with debug mode enabled for automatic reloading.

**Production mode:** After release, the project will be automatically packaged into a Docker image and deployed according to the `entrypoint.sh` script with production parameters (run `bash entrypoint.sh production`). This will install Gunicorn as a production WSGI server and run the application with worker processes for better performance and reliability.


DevBox: Code. Build. Deploy. We've Got the Rest.

With DevBox, you can focus entirely on writing great code while we handle the infrastructure, scaling, and deployment. Seamless development from start to production. 