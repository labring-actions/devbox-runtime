ARG REPO_OWNER=labring-actions
ARG REPO_NAME=devbox-image
ARG CONFIGURE_TOOLS_VERSION=12a54089b454324f2d8e1d91b4bbf8493736b223@sha256:a6f369bdc75f9db17ec743b12c5a513fac0cada4454a3dee722fefb46a94124a
ARG DEBIAN_IMAGE_VERSION=b71e217629de2b94b08e1cab7ecb89cadaa18197@sha256:2b090f3b7652f7fb898e2d7b076159b0633338b2c9e4aea19fb105f9331023f2

FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/configure-tools:${CONFIGURE_TOOLS_VERSION} AS configure-tools
FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}/debian-12.6:${DEBIAN_IMAGE_VERSION} AS baseimage
ENV CONFIGURE_TOOLS_DIR=/opt/configure-tools
COPY build.sh /build.sh
COPY --from=configure-tools ${CONFIGURE_TOOLS_DIR} ${CONFIGURE_TOOLS_DIR}
COPY ./project /home/devbox/project
RUN chmod +x /build.sh && \
    /build.sh && \
    rm -f /build.sh
WORKDIR /home/devbox/project
EXPOSE 22
ENTRYPOINT ["/init"]