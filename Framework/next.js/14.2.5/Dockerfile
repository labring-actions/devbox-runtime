FROM ghcr.io/labring-actions/devbox/nodejs-20:d8bfae

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Framework/next.js/14.2.5/project /home/sealos/project
RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project  

USER sealos
RUN cd /home/sealos/project && \
npm config set fetch-retry-maxtimeout 2000000 && \
pnpm install 

RUN mkdir /home/sealos/.sealos