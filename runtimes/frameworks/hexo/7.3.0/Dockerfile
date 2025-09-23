ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-20:latest
FROM $BASE_IMAGE

USER root
RUN rm -r /home/devbox/project && \
mkdir -p /home/devbox/project && \
chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project

USER devbox
RUN sudo npm install -g hexo-cli && \
hexo init /home/devbox/project && \
cd /home/devbox/project && \
npm install
COPY entrypoint.sh /home/devbox/project/entrypoint.sh
COPY README.md /home/devbox/project/README.md

USER root
RUN chown -R devbox:devbox /home/devbox/project/entrypoint.sh && \
chmod -R 777 /home/devbox/project/entrypoint.sh
USER devbox

RUN mkdir -p /home/devbox/.devbox
