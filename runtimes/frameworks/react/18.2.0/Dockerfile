ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/node.js-22:latest
FROM $BASE_IMAGE

USER root
RUN cd /home/devbox/project && \
rm -rf ./* && \
mkdir -p /usr/lib/node_modules && \
chown -R devbox:devbox /usr/lib/node_modules

COPY project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
ENV PATH=/home/devbox/.npm-global/bin:$PATH

RUN mkdir -p /home/devbox/.npm-global && \
npm config set prefix '/home/devbox/.npm-global' && \
echo 'export PATH=/home/devbox/.npm-global/bin:$PATH' >> /home/devbox/.bashrc && \
cd /home/devbox/project && \
npm install -g serve && \
npm install && \
npm run build

RUN mkdir -p /home/devbox/.devbox
