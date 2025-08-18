FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a5f75b3
USER root

RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python

USER devbox

RUN mkdir -p /home/devbox/.devbox && \
    if [ -d /home/devbox/project ]; then rm -rf /home/devbox/project/*; fi

COPY --chown=devbox:devbox /Language/python/project /home/devbox/project

RUN python -m venv /home/devbox/project && chmod +x /home/devbox/project/entrypoint.sh