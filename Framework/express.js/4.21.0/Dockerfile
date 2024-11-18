FROM ghcr.io/labring-actions/devbox/node.js-18:a49ab6

USER root
RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Framework/express.js/4.21.0/project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh
 
USER devbox
RUN cd /home/devbox/project && \
npm install
 
RUN mkdir -p /home/devbox/.devbox