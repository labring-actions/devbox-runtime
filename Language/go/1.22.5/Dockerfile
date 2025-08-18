FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a5f75b3

USER root

RUN curl -O https://dl.google.com/go/go1.22.5.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz && \
    rm go1.22.5.linux-amd64.tar.gz

USER devbox

RUN mkdir -p /home/devbox/.devbox && \
    if [ -d /home/devbox/project ]; then rm -rf /home/devbox/project/*; fi && \
    mkdir -p /home/devbox/go && \
    echo 'export GOPATH=/home/devbox/go' >> /home/devbox/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin:/home/devbox/go/bin' >> /home/devbox/.bashrc

COPY --chown=devbox:devbox /Language/go/project /home/devbox/project

ENV GOPATH=/home/devbox/go
ENV PATH=$PATH:/usr/local/go/bin:/home/devbox/go/bin

RUN chmod +x /home/devbox/project/entrypoint.sh