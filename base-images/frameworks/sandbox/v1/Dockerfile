# These ARGs can be overridden at build time to customize the image
ARG REPO=labring-actions/devbox-base-images
ARG REPO_CODEX_GATEWAY=labring/codex-gateway
ARG REGISTRY=ghcr.io
ARG L10N=en_US
ARG L10N_NORMALIZED=en-us

ARG CODEX_GATEWAY_IMAGE_TAG=latest

# These ARGs are not recommended to be overridden at build time.
# Instead, update the Dockerfile directly for consistent builds,
# and release new versions as needed.
ARG NODE_IMAGE_VERSION=v0.0.1-alpha.1-${L10N_NORMALIZED}

FROM ${REGISTRY}/${REPO_CODEX_GATEWAY}:${CODEX_GATEWAY_IMAGE_TAG} AS codex-gateway

FROM ${REGISTRY}/${REPO}/node.js-22:${NODE_IMAGE_VERSION}
ARG L10N
LABEL org.opencontainers.image.authors="The Devbox Authors"
ENV L10N=${L10N}
ENV PYTHON_VERSION=3.14.0
ENV VERSITYGW_VERSION=1.5.0

ENV CODEX_GATEWAY_ROOT=/opt/codex-gateway
ENV CODEX_GATEWAY_CODEX_HOME=/codex-home
ENV CODEX_GATEWAY_CWD=/home/${DEFAULT_DEVBOX_USER}/workspace
ENV CODEX_GATEWAY_HOST=0.0.0.0
ENV CODEX_GATEWAY_PORT=1317
ENV CODEX_GATEWAY_MAX_SESSIONS=12
ENV CODEX_GATEWAY_SESSION_TTL_MS=1800000
ENV CODEX_GATEWAY_SESSION_SWEEP_INTERVAL_MS=60000

ENV VERSITYGW_ENABLED=true
ENV VERSITYGW_HOST=0.0.0.0
ENV VERSITYGW_PORT=1319
ENV VERSITYGW_REGION=sealos-internal
ENV VERSITYGW_ROOT=/home/${DEFAULT_DEVBOX_USER}/workspace/.versitygw-s3
ENV VERSITYGW_IAM_DIR=/home/${DEFAULT_DEVBOX_USER}/workspace/.versitygw-iam
ENV VERSITYGW_VERSIONING_DIR=/home/${DEFAULT_DEVBOX_USER}/workspace/.versitygw-versioning

ENV AWS_ACCESS_KEY_ID=admin
ENV AWS_REGION=sealos-internal
ENV AWS_DEFAULT_REGION=sealos-internal
ENV AWS_ENDPOINT_URL=http://127.0.0.1:1319
ENV AWS_ENDPOINT_URL_S3=http://127.0.0.1:1319
ENV AWS_S3_FORCE_PATH_STYLE=true
ENV S3_ENDPOINT=http://127.0.0.1:1319
ENV S3_FORCE_PATH_STYLE=true
ENV KANIKO_CONTEXT_S3_BUCKET=kaniko-contexts
ENV KANIKO_CONTEXT_S3_PREFIX=contexts
ENV KANIKO_CONTEXT_S3_BASE=s3://kaniko-contexts/contexts
ENV KANIKO_CONTEXT_POSIX_DIR=/home/${DEFAULT_DEVBOX_USER}/workspace/.versitygw-s3/kaniko-contexts/contexts

COPY --from=codex-gateway /usr/local/bin/codex-gateway /usr/local/bin/codex-gateway

# Add build assets and execute them.
COPY codex-gateway /tmp/codex-gateway-service
COPY versitygw /tmp/versitygw-service
COPY build.sh /build.sh
RUN chmod +x \
        /build.sh \
        /tmp/codex-gateway-service/run \
        /tmp/codex-gateway-service/finish \
        /tmp/versitygw-service/run \
        /tmp/versitygw-service/finish && \
    /build.sh && \
    rm -f /build.sh && \
    rm -rf /tmp/codex-gateway-service /tmp/versitygw-service

EXPOSE 1317 1319
