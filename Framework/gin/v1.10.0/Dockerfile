FROM ghcr.io/labring-actions/devbox/go1.22.5:1e1bf3

COPY /Framework/gin/v1.10.0/project /home/sealos/project
 
RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project 

USER sealos
RUN cd /home/sealos/project && \
go mod tidy 

USER root
RUN mkdir /home/sealos/.sealos