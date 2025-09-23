ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-20:latest
FROM $BASE_IMAGE

# Install Angular CLI and serve
RUN npm install -g @angular/cli@^18.2.9 serve

# Clean existing project directory and copy new files
RUN rm -rf /home/devbox/project/*
COPY project/ /home/devbox/project/
RUN chmod +x /home/devbox/project/entrypoint.sh

# Install dependencies and build
WORKDIR /home/devbox/project
RUN npm ci --silent && npm run build
