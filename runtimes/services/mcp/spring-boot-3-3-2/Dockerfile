ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-12.6:latest
FROM $BASE_IMAGE

USER root
RUN cd /home/devbox/project && \
rm -rf ./*

COPY project /home/devbox/project

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jdk maven && \
    JAVA_ARCH="$(dpkg --print-architecture)" && \
    JAVA_HOME_REAL="/usr/lib/jvm/java-17-openjdk-${JAVA_ARCH}" && \
    ln -sfn "${JAVA_HOME_REAL}" /usr/lib/jvm/java-17-openjdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /home/devbox/.bashrc && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> /home/devbox/.bashrc && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin
RUN mkdir /root/.devbox

USER devbox
RUN cd /home/devbox/project && \
    mvn install
