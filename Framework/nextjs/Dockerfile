FROM ghcr.io/labring-actions/devbox/nodejs20:aa9aff

COPY /Framework/nextjs/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project
RUN mkdir /home/sealos/.sealos