ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-20:latest
FROM $BASE_IMAGE

USER root
RUN rm -rf /home/devbox/project/* && \
    mkdir -p /home/devbox/.devbox

USER devbox
RUN sudo npm install -g hexo-cli && \
    hexo init /home/devbox/project && \
    cd /home/devbox/project && \
    npm install

COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
