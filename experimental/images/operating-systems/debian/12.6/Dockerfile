ARG REPO_OWNER=labring-actions
ARG REPO_NAME=devbox-expt-image
ARG BASE_TOOLS_VERSION=v0.0.1

FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/base-tools:${BASE_TOOLS_VERSION} AS base-tools
FROM debian:12.6-slim
ENV BASE_TOOLS_DIR=/opt/base-tools
COPY build.sh /build.sh
COPY --from=base-tools ${BASE_TOOLS_DIR} ${BASE_TOOLS_DIR}
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh