FROM ghcr.io/labring-actions/devbox/node.js-20:255ae9

RUN cd /home/sealos/project && \
rm -rf ./*
 
COPY /Framework/docusaurus/3.5.2/project /home/sealos/project
RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
chmod -R +x /home/sealos/project/entrypoint.sh

USER sealos
RUN cd /home/sealos/project && \
npm install && \
npx docusaurus build
 
USER root
RUN mkdir /home/sealos/.devbox