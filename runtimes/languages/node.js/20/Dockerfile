ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest
FROM $BASE_IMAGE

USER root
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript yarn pnpm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /root/.devbox

USER devbox
ENV NODE_VERSION 20
ENV NVM_DIR /home/devbox/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh

RUN cd /home/devbox/project && rm -rf ./*
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

ARG CN_PATCH_ENABLED=false
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
        sudo su devbox -c "npm config set registry https://registry.npmmirror.com"; \
        sudo su root -c "npm config set registry https://registry.npmmirror.com"; \
    fi
