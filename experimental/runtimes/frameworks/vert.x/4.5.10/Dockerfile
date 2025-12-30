# These ARGs can be overridden at build time to customize the image
ARG REPO=labring-actions/devbox-base-expt
ARG REGISTRY=ghcr.io
ARG L10N_NORMALIZED=en-us

# These ARGs are not recommended to be overridden at build time.
# Instead, update the Dockerfile directly for consistent builds,
# and release new versions as needed.
ARG FRAMEWORK_IMAGE_VERSION=v0.0.1-alpha.1-${L10N_NORMALIZED}

FROM ${REGISTRY}/${REPO}/vert.x-4.5.10:${FRAMEWORK_IMAGE_VERSION}
LABEL org.opencontainers.image.authors="The Devbox Authors"
ENV PROJECT_TEMPLATE_DIR=/project-template
COPY ./project-template ${PROJECT_TEMPLATE_DIR}
COPY ./build.sh /build.sh
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh && \
    rm -rf ${PROJECT_TEMPLATE_DIR}
# Switch to the default devbox user and set HOME to the user's home directory
ENV HOME=/home/${DEFAULT_DEVBOX_USER}
USER ${DEFAULT_DEVBOX_USER}
# Set the working directory to the default devbox user's project directory
WORKDIR /home/${DEFAULT_DEVBOX_USER}/project

