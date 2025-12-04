ARG REPO_OWNER=labring-actions
ARG REPO_NAME=devbox-base-expt
ARG OS_IMAGE_VERSION=v0.0.1-en-us

FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/debian-12.6:${OS_IMAGE_VERSION}
ENV PROJECT_TEMPLATE_DIR=/project-template
COPY ./project-template ${PROJECT_TEMPLATE_DIR}
COPY ./build.sh /build.sh
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh && \
    rm -rf ${PROJECT_TEMPLATE_DIR}
USER devbox
ENTRYPOINT ["/init"]