FROM ghcr.io/labring-actions/devbox/node.js-20:219d11
USER root
RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Framework/nuxt3/v3.13/project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project  && \
chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN cd /home/devbox/project && \
npm install
 

RUN mkdir -p /home/devbox/.devbox