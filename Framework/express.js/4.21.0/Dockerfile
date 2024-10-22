FROM ghcr.io/labring-actions/devbox/node.js-20:5c2eec

RUN cd /home/sealos/project && \
rm -rf ./*
 
COPY /Framework/express.js/4.21.0/project /home/sealos/project
RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
chmod -R +x /home/sealos/project/entrypoint.sh

USER sealos
RUN cd /home/sealos/project && \
npm install && \
pnpm run build

USER root
RUN mkdir /home/sealos/.sealos