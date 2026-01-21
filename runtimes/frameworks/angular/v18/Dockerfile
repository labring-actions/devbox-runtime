ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-20:latest
FROM $BASE_IMAGE

USER root
RUN rm -rf /home/devbox/project/* && \
    mkdir -p /home/devbox/.devbox
COPY --chown=devbox:devbox project /home/devbox/project
RUN chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh && \
    npm install -g @angular/cli@^18.2.9 serve

USER devbox
RUN cd /home/devbox/project && \
    npm ci --silent && \
    npm run build
