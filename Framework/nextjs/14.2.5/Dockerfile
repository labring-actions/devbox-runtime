FROM ghcr.io/labring-actions/devbox/nodejs-20:d8bfae

COPY /Framework/nextjs/14.2.5/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
cd /home/sealos/project && \
npm config set fetch-retry-maxtimeout 600000 && \
npm install

RUN mkdir /home/sealos/.sealos