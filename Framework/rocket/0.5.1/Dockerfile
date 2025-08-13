FROM ghcr.io/labring-actions/devbox/rust-1.81.0:9361af9

RUN cd /home/devbox/project && \
rm -rf ./*
 
USER root
COPY /Framework/rocket/0.5.1/project /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
chmod -R u+rw /home/devbox/project && \
chmod -R +x /home/devbox/project/entrypoint.sh 

USER devbox
RUN cd /home/devbox/project && \
cargo build --release
 
USER root
RUN mkdir -p /home/devbox/.devbox