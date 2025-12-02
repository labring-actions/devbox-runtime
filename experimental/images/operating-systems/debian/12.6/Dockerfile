ARG REPO_OWNER=labring-actions
ARG REPO_NAME=devbox-base-expt
ARG BASE_TOOLS_VERSION=v0.0.1

FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/base-tools:${BASE_TOOLS_VERSION} AS base-tools
FROM debian:12.6-slim
ENV BASE_TOOLS_DIR=/opt/base-tools
# S6_STAGE2_HOOK: Hook script executed BEFORE s6-rc compilation
# This allows us to dynamically disable services based on DEVBOX_ENV
ENV S6_STAGE2_HOOK=/opt/base-tools/scripts/svc/pre-rc-init.sh
COPY build.sh /build.sh
COPY --from=base-tools ${BASE_TOOLS_DIR} ${BASE_TOOLS_DIR}
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh