FROM ghcr.io/labring-actions/devbox/nodejs20:b50472

COPY /Framework/vue/vue3.4.29/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
cd /home/sealos/project && \
npm install

RUN mkdir /home/sealos/.sealos