# These ARGs can be overridden at build time to customize the image
ARG REPO=labring-actions/devbox-base-images
ARG REPO_CODEX_GATEWAY=labring/codex-gateway
ARG REGISTRY=ghcr.io
ARG L10N_NORMALIZED=en-us

ARG CODEX_GATEWAY_IMAGE_TAG=latest

# These ARGs are not recommended to be overridden at build time.
# Instead, update the Dockerfile directly for consistent builds,
# and release new versions as needed.
ARG NODE_IMAGE_VERSION=v0.0.1-alpha.1-${L10N_NORMALIZED}

FROM ${REGISTRY}/${REPO_CODEX_GATEWAY}:${CODEX_GATEWAY_IMAGE_TAG} AS codex-gateway

FROM ${REGISTRY}/${REPO}/node.js-22:${NODE_IMAGE_VERSION}
LABEL org.opencontainers.image.authors="The Devbox Authors"
ENV PYTHON_VERSION=3.14.0

ENV CODEX_GATEWAY_ROOT=/opt/codex-gateway
ENV CODEX_GATEWAY_CODEX_HOME=/codex-home
ENV CODEX_GATEWAY_CWD=/home/${DEFAULT_DEVBOX_USER}/workspace
ENV CODEX_GATEWAY_HOST=0.0.0.0
ENV CODEX_GATEWAY_PORT=1317
ENV CODEX_GATEWAY_MAX_SESSIONS=12
ENV CODEX_GATEWAY_SESSION_TTL_MS=1800000
ENV CODEX_GATEWAY_SESSION_SWEEP_INTERVAL_MS=60000

COPY --from=codex-gateway /usr/local/bin/codex-gateway /usr/local/bin/codex-gateway

# Add build assets and execute them.
COPY codex-gateway /tmp/codex-gateway-service
COPY build.sh /build.sh
RUN chmod +x /build.sh /tmp/codex-gateway-service/run /tmp/codex-gateway-service/finish && \
    /build.sh && \
    rm -f /build.sh && \
    rm -rf /tmp/codex-gateway-service

EXPOSE 1317
