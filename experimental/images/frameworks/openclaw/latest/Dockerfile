# These ARGs can be overridden at build time to customize the image
ARG REPO=labring-actions/devbox-base-expt
ARG REGISTRY=ghcr.io
ARG L10N_NORMALIZED=en-us

# These ARGs are not recommended to be overridden at build time.
# Instead, update the Dockerfile directly for consistent builds,
# and release new versions as needed.
ARG NODE_IMAGE_VERSION=v0.0.1-alpha.1-${L10N_NORMALIZED}
ARG CLAWHUB_ALLOW_SUSPICIOUS_SKILLS=false

FROM ${REGISTRY}/${REPO}/node.js-22:${NODE_IMAGE_VERSION}
LABEL org.opencontainers.image.authors="The Devbox Authors"
# Add build script and execute it
COPY build.sh /build.sh
RUN chmod +x /build.sh && \
    CLAWHUB_ALLOW_SUSPICIOUS_SKILLS="${CLAWHUB_ALLOW_SUSPICIOUS_SKILLS}" /build.sh && \
    rm -f /build.sh
