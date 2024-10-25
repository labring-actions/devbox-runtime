FROM ghcr.io/labring-actions/devbox/go-1.22.5:d988c9

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Framework/echo/v4.12.0/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project  && \
chmod -R +x /home/devbox/project/entrypoint.sh
 
USER devbox
RUN cd /home/devbox/project && \
go mod tidy && \
go build -o main main.go

RUN mkdir /home/devbox/.devbox