FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:stable

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Language/rust/project /home/devbox/project

USER devbox
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 

USER root
 
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get install -y libudev-dev && \
    apt-get install -y pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'export PATH=/home/devbox/.cargo/bin:$PATH' >> $HOME/.bashrc && \
    echo '. /home/devbox/.cargo/env' >> $HOME/.bashrc && \ 
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
 
USER devbox
ENV PATH="/home/devbox/.cargo/bin:${PATH}"
RUN cd /home/devbox/project && \
    cargo build --release

RUN mkdir -p /home/devbox/.devbox