FROM ghcr.io/labring-actions/devbox/node.js-20:8c965d

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Framework/umi/4.3.27/project /home/sealos/project
RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
chmod -R +x /home/sealos/project/entrypoint.sh

USER sealos
RUN cd /home/sealos/project && \
pnpm install
 
USER root
RUN mkdir /home/sealos/.sealos