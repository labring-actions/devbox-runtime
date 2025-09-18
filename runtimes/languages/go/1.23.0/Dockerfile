FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest

RUN cd /home/devbox/project && \
rm -rf ./*

COPY project /home/devbox/project

RUN curl -O https://dl.google.com/go/go1.23.0.linux-amd64.tar.gz && \
    tar -xvf go1.23.0.linux-amd64.tar.gz && \
    mv go /usr/local && \
    rm go1.23.0.linux-amd64.tar.gz && \
    mkdir -p /go/bin && \
    echo 'export GOPATH=/go' >> /home/devbox/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin:/go/bin' >> /home/devbox/.bashrc && \
    echo 'export GOPATH=/go' >> /root/.bashrc && \
    echo 'export PATH=$PATH:/usr/local/go/bin:/go/bin' >> /root/.bashrc && \
    chmod -R 777 /go && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:/go/bin
RUN mkdir /root/.devbox
