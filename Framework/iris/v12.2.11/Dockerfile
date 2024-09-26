FROM ghcr.io/labring-actions/devbox/go-1.22.5:715122

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Framework/iris/v12.2.11/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project  && \
chmod -R +x /home/sealos/project/entrypoint.sh
 
USER sealos
RUN cd /home/sealos/project && \
go mod tidy && \
go build -o main main.go

RUN mkdir /home/sealos/.sealos