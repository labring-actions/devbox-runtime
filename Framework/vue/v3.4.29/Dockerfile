FROM ghcr.io/labring-actions/devbox/nodejs-20:d8bfae

COPY /Framework/vue/v3.4.29/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
cd /home/sealos/project && \
npm install

RUN mkdir /home/sealos/.sealos