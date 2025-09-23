ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/go-1.22.5:latest
FROM $BASE_IMAGE

USER root
RUN rm -rf /home/devbox/project/* && mkdir -p /home/devbox/.devbox

USER devbox
RUN curl -LO https://github.com/gohugoio/hugo/releases/download/v0.135.0/hugo_extended_0.135.0_linux-amd64.tar.gz && \
    tar -xvzf hugo_extended_0.135.0_linux-amd64.tar.gz && \
    mv hugo /usr/local/bin/ && \
    chmod +x /usr/local/bin/hugo && \
    rm README.md && rm LICENSE && rm hugo_extended_0.135.0_linux-amd64.tar.gz && \
    cd /home/devbox && \
    hugo new site project && \
    cd /home/devbox/project && \
    git init && \
    git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke && \
        echo "theme = 'ananke'" >> hugo.toml && \
    hugo
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R u+rw /home/devbox/project && \
    sudo chmod -R +x /home/devbox/project/entrypoint.sh
