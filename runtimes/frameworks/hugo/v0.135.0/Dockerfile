ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/go-1.22.5:latest
FROM $BASE_IMAGE

USER root
RUN rm -rf /home/devbox/project/* && mkdir -p /home/devbox/.devbox

RUN curl -Lo /tmp/hugo.tgz https://github.com/gohugoio/hugo/releases/download/v0.135.0/hugo_extended_0.135.0_linux-amd64.tar.gz && \
    tar -xvzf /tmp/hugo.tgz -C /tmp && \
    mv /tmp/hugo /usr/local/bin/hugo && \
    chmod +x /usr/local/bin/hugo && \
    rm -f /tmp/README.md /tmp/LICENSE /tmp/hugo.tgz

USER devbox
RUN cd /home/devbox && \
    hugo new site project && \
    cd /home/devbox/project && \
    git init && \
    git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke && \
    echo "theme = 'ananke'" >> hugo.toml && \
    hugo
COPY --chown=devbox:devbox project /home/devbox/project
RUN chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
