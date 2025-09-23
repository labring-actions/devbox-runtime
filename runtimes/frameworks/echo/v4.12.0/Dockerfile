ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/go-1.22.5:latest
FROM $BASE_IMAGE

USER root
RUN rm -rf /home/devbox/project/* && \
    mkdir -p /home/devbox/.devbox
COPY project /home/devbox/project
RUN chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN cd /home/devbox/project && \
    go mod tidy && \
    go build -o main main.go
