ARG REPO_OWNER=labring-actions
ARG REPO_NAME=devbox-expt-image
ARG BASE_TOOLS_VERSION=2b5c9915580c95f9d772a2abd01ee1c926a58a32@sha256:0320454bcdcd0ca54913dacb1efa8e17d5dd0f409aa219710b000089c6f7dc7b

FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/base-tools:${BASE_TOOLS_VERSION} AS base-tools
FROM debian:12.6-slim
ENV BASE_TOOLS_DIR=/opt/base-tools
COPY build.sh /build.sh
COPY --from=base-tools ${BASE_TOOLS_DIR} ${BASE_TOOLS_DIR}
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh