FROM ghcr.io/labring-actions/devbox/java-openjdk17:d988c9

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Framework/quarkus/3.16.1/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh 

USER devbox
RUN cd /home/devbox/project && \
    ./mvnw package

USER root
RUN mkdir /home/devbox/.devbox