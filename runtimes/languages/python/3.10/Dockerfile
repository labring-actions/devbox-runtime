ARG BASE_IMAGE=ghcr.io/labring-actions/devbox/debian-12.6:latest
FROM $BASE_IMAGE

USER root
RUN apt-get update && \
    apt-get install -y wget build-essential libssl-dev libffi-dev zlib1g-dev && \
    cd /tmp && wget https://www.python.org/ftp/python/3.10.16/Python-3.10.16.tgz && \
    tar xzf Python-3.10.16.tgz && \
    cd Python-3.10.16 && \
    ./configure && \
    make -j $(($(nproc) / 2)) && \
    make altinstall && \
    cd .. && \
    ln -s /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -s /usr/local/bin/python3.10 /usr/bin/python && \
    python3.10 -m ensurepip --upgrade && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip3 && \
    mkdir /root/.devbox && \
    apt-get remove -y build-essential libssl-dev libffi-dev zlib1g-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf Python-3.10.16 Python-3.10.16.tgz && \
    rm -rf /tmp/* /var/tmp/* && \
    find /usr/local -name "*.pyc" -delete && \
    find /usr/local -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

USER devbox
RUN rm -rf /home/devbox/project/*
COPY --chown=devbox:devbox project /home/devbox/project
RUN chmod -R 777 /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh && \
    python3.10 -m venv /home/devbox/project

ARG CN_PATCH_ENABLED=false
RUN if [ "$CN_PATCH_ENABLED" = "true" ]; then \
        sudo su devbox -c "pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"; \
        sudo su root -c "pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"; \
    fi
