ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-ssh-12.6:latest
FROM $BASE_IMAGE

USER root
RUN apt-get update && \
    apt-get install -y wget build-essential libncursesw5-dev libssl-dev \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev && \
    wget https://www.python.org/ftp/python/3.11.11/Python-3.11.11.tgz && \
    tar xzf Python-3.11.11.tgz && \
    cd Python-3.11.11 && \
    ./configure --enable-optimizations && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.11.11 Python-3.11.11.tgz && \
    ln -s /usr/local/bin/python3.11 /usr/bin/python3 && \
    ln -s /usr/local/bin/python3.11 /usr/bin/python && \
    python3.11 -m ensurepip --upgrade && \
    ln -s /usr/local/bin/pip3.11 /usr/bin/pip && \
    ln -s /usr/local/bin/pip3.11 /usr/bin/pip3 && \
    mkdir /root/.devbox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER devbox
RUN sudo rm -rf /home/devbox/project/*
COPY project /home/devbox/project
RUN sudo chown -R devbox:devbox /home/devbox/project && \
    sudo chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh && \
    python3.11 -m venv /home/devbox/project

ARG CN_PATCH_ENABLED=false
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
        sudo su devbox -c "pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"; \
        sudo su root -c "pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"; \
    fi
