FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a5f75b3
USER root

RUN apt-get update && \
    apt-get install -y gcc g++ make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER devbox

RUN mkdir -p /home/devbox/.devbox && \
    if [ -d /home/devbox/project ]; then rm -rf /home/devbox/project/*; fi

COPY --chown=devbox:devbox /Language/cpp/project /home/devbox/project

RUN chmod +x /home/devbox/project/entrypoint.sh
