ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest
FROM $BASE_IMAGE

USER root
ARG CN_PATCH_ENABLED=false
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
        echo "export GOPROXY=https://goproxy.cn,direct" >> /home/devbox/.bashrc && \
        echo "export GOPROXY=https://goproxy.cn,direct" >> /root/.bashrc ; \
    fi

RUN curl -O https://dl.google.com/go/go1.22.5.linux-amd64.tar.gz && \
    tar -xvf go1.22.5.linux-amd64.tar.gz && \
    mv go /usr/local && \
    rm go1.22.5.linux-amd64.tar.gz && \
    mkdir -p /go/bin && \
    echo 'export GOPATH=/go' >> /home/devbox/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin:/go/bin' >> /home/devbox/.bashrc && \
    echo 'export GOPATH=/go' >> /root/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin:/go/bin' >> /root/.bashrc && \
    chmod -R 777 /go && \
    mkdir /root/.devbox

ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:/go/bin

USER devbox
RUN cd /home/devbox/project && rm -rf ./*
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
