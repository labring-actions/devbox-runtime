ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-12.6:latest
FROM $BASE_IMAGE

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jdk maven && \
    JAVA_ARCH="$(dpkg --print-architecture)" && \
    JAVA_HOME_REAL="/usr/lib/jvm/java-17-openjdk-${JAVA_ARCH}" && \
    ln -sfn "${JAVA_HOME_REAL}" /usr/lib/jvm/java-17-openjdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/devbox/.bashrc && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> /home/devbox/.bashrc && \
    mkdir /root/.devbox

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin

USER devbox
RUN cd /home/devbox/project && rm -rf ./*
COPY --chown=devbox:devbox project /home/devbox/project
RUN chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

ARG CN_PATCH_ENABLED=false
COPY settings.xml /tmp/settings.xml
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
        mkdir -p /home/devbox/.m2 && cp /tmp/settings.xml /home/devbox/.m2/settings.xml; \
    fi
