ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/java-openjdk17:latest
FROM $BASE_IMAGE

RUN cd /home/devbox/project && \
rm -rf ./*

COPY project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN cd /home/devbox/project && \
    curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/ --global && \
    curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio --global && \
    ./mvnw package

USER root
RUN mkdir -p /home/devbox/.devbox
