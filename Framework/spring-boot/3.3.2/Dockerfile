FROM ghcr.io/labring-actions/devbox/java-openjdk17:8c965d

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Framework/spring-boot/3.3.2/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
chmod -R +x /home/sealos/project/entrypoint.sh 

USER sealos
RUN cd /home/sealos/project && \
    mvn install

USER root
RUN mkdir /home/sealos/.sealos