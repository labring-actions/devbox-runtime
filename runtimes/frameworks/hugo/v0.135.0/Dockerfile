ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/go-1.22.5:latest
FROM $BASE_IMAGE

USER root
ARG TARGETARCH
RUN rm -rf /home/devbox/project/* && mkdir -p /home/devbox/.devbox

RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64|x86_64) HUGO_ARCH=amd64 ;; \
        arm64|aarch64) HUGO_ARCH=arm64 ;; \
        *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    HUGO_TARBALL="hugo_extended_0.135.0_linux-${HUGO_ARCH}.tar.gz"; \
    curl -fL -o /tmp/hugo.tgz "https://github.com/gohugoio/hugo/releases/download/v0.135.0/${HUGO_TARBALL}" && \
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
    # Pin a theme release compatible with Hugo v0.135.0.
    git -C themes/ananke checkout v2.12.1 && \
    echo "theme = 'ananke'" >> hugo.toml && \
    hugo
COPY --chown=devbox:devbox project /home/devbox/project
RUN chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
