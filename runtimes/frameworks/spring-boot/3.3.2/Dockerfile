ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/java-openjdk17:latest
FROM $BASE_IMAGE

RUN cd /home/devbox/project && \
rm -rf ./*

COPY project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN cd /home/devbox/project && \
    mvn install

USER root
RUN mkdir -p /home/devbox/.devbox
