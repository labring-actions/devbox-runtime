ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-20:latest
FROM $BASE_IMAGE

USER root
RUN apt-get update && apt-get install -y nginx
RUN rm -rf /home/devbox/project/* && \
    mkdir -p /home/devbox/.devbox
COPY project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf
