FROM ghcr.io/labring-actions/devbox/node.js-20:8db5f4

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Framework/next.js/14.2.5/project /home/sealos/project
RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project  && \
chmod -R +x /home/sealos/project/entrypoint.sh

USER sealos
RUN cd /home/sealos/project && \
npm config set fetch-retry-maxtimeout 4000000 && \
pnpm install && \
pnpm run build

 
RUN mkdir /home/sealos/.sealos