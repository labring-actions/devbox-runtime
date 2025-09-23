ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest
FROM $BASE_IMAGE

RUN cd /home/devbox/project && \rm -rf ./*
COPY project /home/devbox/project

RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN cd /home/devbox/project && \
    python3 -m venv .venv && \
    . .venv/bin/activate && \
    pip3 install "mcp[cli]==1.6.0" && \
    deactivate

RUN mkdir -p /home/devbox/.devbox
