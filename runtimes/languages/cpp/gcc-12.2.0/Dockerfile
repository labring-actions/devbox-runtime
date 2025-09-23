ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest
FROM $BASE_IMAGE

USER root
RUN apt-get update && \
    apt-get install -y gcc g++ make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /root/.devbox

USER devbox
RUN cd /home/devbox/project && rm -rf ./*
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
