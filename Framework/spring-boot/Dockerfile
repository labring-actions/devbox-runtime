FROM ghcr.io/labring-actions/devbox/openjdk17:1e1bf3

COPY /Framework/spring-boot/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project

RUN mkdir /home/sealos/.sealos