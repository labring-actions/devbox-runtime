FROM  ghcr.io/labring-actions/devbox/node.js-18:a49ab6
USER root
RUN cd /home/devbox/project && \
rm -rf ./*
 
COPY /Framework/next.js/14.2.5/project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project  && \
chmod -R +x /home/devbox/project/entrypoint.sh
 
USER devbox
RUN cd /home/devbox/project && \
npm config set fetch-retry-maxtimeout 10000000 && \
pnpm install && \
pnpm run build

RUN mkdir -p /home/devbox/.devbox