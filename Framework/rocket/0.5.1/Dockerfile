FROM ghcr.io/labring-actions/devbox/rust-1.81.0:8c965d

RUN cd /home/sealos/project && \
rm -rf ./*

USER root
COPY /Framework/rocket/0.5.1/project /home/sealos/project

RUN chown -R sealos:sealos /home/sealos/project && \
chmod -R u+rw /home/sealos/project && \
chmod -R +x /home/sealos/project/entrypoint.sh 

USER sealos
RUN cd /home/sealos/project && \
cargo build --release

USER root
RUN mkdir -p /home/sealos/.sealos