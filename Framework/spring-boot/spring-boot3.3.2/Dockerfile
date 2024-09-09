FROM ghcr.io/labring-actions/devbox/openjdk17:b50472

COPY /Framework/spring-boot/spring-boot3.3.2/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project 

USER sealos
RUN cd /home/sealos/project && \
    mvn install
 
USER root
RUN mkdir /home/sealos/.sealos