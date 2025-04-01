FROM ghcr.io/labring-actions/devbox/java-openjdk17:13aacd

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Service/mcp/spring-boot-3-3-2/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh 

USER devbox
RUN cd /home/devbox/project && \
    mvn install

USER root
RUN mkdir -p /home/devbox/.devbox