# These ARGs can be overridden at build time to customize the image
ARG REGISTRY=ghcr.io
ARG REPO=labring-actions/devbox-base-expt
ARG L10N=en_US
ARG ARCH=amd64
ARG DEFAULT_DEVBOX_USER=devbox
# These ARGs are not recommended to be overridden at build time.
# Instead, update the Dockerfile directly for consistent builds,
# and release new versions as needed.
ARG BASE_TOOLS_VERSION=v0.0.1-alpha.1
ARG BASE_IMAGE_VERSION=12.6-slim

FROM ${REGISTRY}/${REPO}/base-tools:${BASE_TOOLS_VERSION} AS base-tools
FROM debian:${BASE_IMAGE_VERSION}
ARG L10N
ARG ARCH
ARG DEFAULT_DEVBOX_USER
LABEL org.opencontainers.image.authors="The Devbox Authors"
# Define some environment variables
## BASE_TOOLS_DIR: Directory where base tools are installed
ENV BASE_TOOLS_DIR=/opt/base-tools
## DEBIAN_FRONTEND: Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
## L10N: Internationalization setting
ENV L10N=${L10N}
## ARCH: System architecture
ENV ARCH=${ARCH}
## DEFAULT_DEVBOX_USER: Default user for the devbox environment
ENV DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER}
## S6_STAGE2_HOOK: Hook script executed BEFORE s6-rc compilation
## This allows us to dynamically disable services based on DEVBOX_ENV
ENV S6_STAGE2_HOOK=/etc/s6-overlay-hook/pre-rc-init.sh
# Copy base tools from the base-tools stage
COPY --from=base-tools ${BASE_TOOLS_DIR} ${BASE_TOOLS_DIR}
# Add build script and execute it
COPY build.sh /build.sh
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh && \
    rm -rf ${BASE_TOOLS_DIR} 