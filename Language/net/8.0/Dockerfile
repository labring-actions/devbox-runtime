FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a5f75b3

USER root

RUN apt update && \
    apt install -y wget && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-8.0 && \
    rm -rf /var/lib/apt/lists/*

USER devbox

RUN mkdir -p /home/devbox/.devbox && \
    if [ -d /home/devbox/project ]; then rm -rf /home/devbox/project/*; fi

COPY --chown=devbox:devbox /Language/net/project /home/devbox/project

RUN chmod +x /home/devbox/project/entrypoint.sh
