FROM ghcr.io/labring-actions/devbox/java-openjdk17:006879

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Framework/rocket/0.5.1/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
chmod -R +x /home/sealos/project/entrypoint.sh 

USER sealos
RUN cd /home/sealos/project && \
cargo build --release

RUN mkdir -p /home/sealos/.sealos