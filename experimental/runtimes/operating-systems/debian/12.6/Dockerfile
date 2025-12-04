# These ARGs can be overridden at build time to customize the image
ARG REPO=labring-actions/devbox-base-expt
ARG REGISTRY=ghcr.io
ARG L10N_NORMALIZED=en-us

# These ARGs are not recommended to be overridden at build time.
# Instead, update the Dockerfile directly for consistent builds,
# and release new versions as needed.
ARG OS_IMAGE_VERSION=v0.0.1-${L10N_NORMALIZED}

FROM ${REGISTRY}/${REPO}/debian-12.6:${OS_IMAGE_VERSION}
ENV PROJECT_TEMPLATE_DIR=/project-template
COPY ./project-template ${PROJECT_TEMPLATE_DIR}
COPY ./build.sh /build.sh
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh && \
    rm -rf ${PROJECT_TEMPLATE_DIR}
USER devbox
ENTRYPOINT ["/init"]