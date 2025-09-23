ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest
FROM $BASE_IMAGE

USER root
RUN apt update && \
    apt install -y wget && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-8.0 && \
    cd /home/devbox/project && \
    mkdir /root/.devbox && \
    rm -rf /var/lib/apt/lists/*

USER devbox
RUN cd /home/devbox/project && rm -rf ./*
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
