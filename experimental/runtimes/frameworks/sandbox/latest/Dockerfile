# These ARGs can be overridden at build time to customize the image
ARG REPO=labring-actions/devbox-base-expt
ARG REGISTRY=ghcr.io
ARG L10N_NORMALIZED=en-us

# These ARGs are not recommended to be overridden at build time.
# Instead, update the Dockerfile directly for consistent builds,
# and release new versions as needed.
ARG RUNTIME_IMAGE_VERSION=v0.0.1-alpha.1-${L10N_NORMALIZED}

FROM ${REGISTRY}/${REPO}/sandbox-latest:${RUNTIME_IMAGE_VERSION}
LABEL org.opencontainers.image.authors="The Devbox Authors"

COPY ./build.sh /build.sh
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh && \
# Set the working directory to the default devbox user's project directory
WORKDIR /home/${DEFAULT_DEVBOX_USER}/workspace
