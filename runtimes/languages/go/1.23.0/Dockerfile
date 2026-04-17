ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-12.6:latest
FROM $BASE_IMAGE

USER root
ARG CN_PATCH_ENABLED=false
ARG TARGETARCH
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
        echo "export GOPROXY=https://goproxy.cn,direct" >> /home/devbox/.bashrc && \
        echo "export GOPROXY=https://goproxy.cn,direct" >> /root/.bashrc ; \
    fi

RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64|x86_64) GO_ARCH=amd64 ;; \
        arm64|aarch64) GO_ARCH=arm64 ;; \
        *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    GO_TARBALL="go1.23.0.linux-${GO_ARCH}.tar.gz"; \
    curl -fsSLO "https://dl.google.com/go/${GO_TARBALL}" && \
    tar -xvf "${GO_TARBALL}" && \
    mv go /usr/local && \
    rm "${GO_TARBALL}" && \
    mkdir -p /go/bin && \
    echo 'export GOPATH=/go' >> /home/devbox/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin:/go/bin' >> /home/devbox/.bashrc && \
    echo 'export GOPATH=/go' >> /root/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin:/go/bin' >> /root/.bashrc && \
    chmod -R 777 /go && \
    mkdir /root/.devbox

ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:/go/bin

USER devbox
RUN cd /home/devbox/project && rm -rf ./*
COPY --chown=devbox:devbox project /home/devbox/project
RUN chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
