ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/python-3.12:latest
FROM $BASE_IMAGE

RUN cd /home/devbox/project && \
rm -rf ./*
COPY project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN python3 -m venv /home/devbox/project && \
    cd /home/devbox/project && \
    . bin/activate && \
    pip3 install flask && \
    deactivate

USER root
RUN mkdir -p /home/devbox/.devbox
