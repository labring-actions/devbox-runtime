FROM ghcr.io/labring-actions/devbox/go1.22.5:1e1bf3

COPY /Framework/gin/project /home/sealos/project
 
RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project

RUN mkdir /home/sealos/.sealos