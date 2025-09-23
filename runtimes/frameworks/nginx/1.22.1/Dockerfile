ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-20:latest
FROM $BASE_IMAGE
# Test comment for GitHub Actions trigger
USER root
RUN cd /home/devbox/project

RUN apt-get update && apt-get install -y nginx

COPY project /home/devbox/project
COPY nginx.conf /etc/nginx/nginx.conf
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh

RUN mkdir -p /home/devbox/.devbox
