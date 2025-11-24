ARG REPO_OWNER=labring-actions
ARG REPO_NAME=devbox-expt-image
ARG CONFIGURE_TOOLS_VERSION=v0.0.1
ARG DEBIAN_IMAGE_VERSION=v0.0.1
ARG CN_PATCH_ENABLED=false

FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/configure-tools:${CONFIGURE_TOOLS_VERSION} AS configure-tools
FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/debian-12.6:${DEBIAN_IMAGE_VERSION} AS baseimage
ENV CONFIGURE_TOOLS_DIR=/opt/configure-tools
ENV CN_PATCH_ENABLED=${CN_PATCH_ENABLED}
COPY build.sh /build.sh
COPY --from=configure-tools ${CONFIGURE_TOOLS_DIR} ${CONFIGURE_TOOLS_DIR}
COPY ./project /home/devbox/project
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh
WORKDIR /home/devbox/project
EXPOSE 22
ENTRYPOINT ["/init"]