ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-20:latest
FROM $BASE_IMAGE

USER root
RUN npm install -g hexo-cli

USER devbox
RUN rm -rf /home/devbox/project/* && \
    hexo init /home/devbox/project && \
    cd /home/devbox/project && \
    npm install

USER root
COPY --chown=devbox:devbox project/entrypoint.sh /home/devbox/project/entrypoint.sh
RUN chmod -R 777 /home/devbox/project && \
    chmod +x /home/devbox/project/entrypoint.sh

USER devbox
