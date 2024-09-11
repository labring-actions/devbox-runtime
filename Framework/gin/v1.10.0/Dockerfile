FROM ghcr.io/labring-actions/devbox/go-1.22.5:35bf93

RUN cd /home/sealos/project && \
rm -rf ./*

USER sealos
COPY /Framework/gin/v1.10.0/project /home/sealos/project
RUN cd /home/sealos/project && \
go mod tidy 

RUN mkdir /home/sealos/.sealos