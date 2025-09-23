ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest
FROM $BASE_IMAGE

USER root
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get install -y libudev-dev && \
    apt-get install -y pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'export PATH=/home/devbox/.cargo/bin:$PATH' >> $HOME/.bashrc && \
    echo '. /home/devbox/.cargo/env' >> $HOME/.bashrc && \
    mkdir /root/.devbox

USER devbox
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/home/devbox/.cargo/bin:${PATH}"
RUN cd /home/devbox/project && rm -rf ./*
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

RUN cd /home/devbox/project && \
    cargo build --release
