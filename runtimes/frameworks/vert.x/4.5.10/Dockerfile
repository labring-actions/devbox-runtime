FROM ghcr.io/labring-actions/devbox/java-openjdk17:latest

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Framework/vert.x/4.5.10/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh

USER devbox
RUN cd /home/devbox/project && \
mvn package && \
mvn install

RUN mkdir -p /home/devbox/.devbox
