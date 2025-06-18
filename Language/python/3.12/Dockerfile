FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:547a61

RUN cd /home/devbox/project && \
    rm -rf ./*

COPY /Language/python/project /home/devbox/project


RUN apt-get update && \
    apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN cd /tmp && \
    wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz && \
    tar -xf Python-3.12.0.tgz && \
    cd Python-3.12.0 && \
    ./configure --enable-optimizations && \
    make -j $(nproc) && \
    make altinstall && \
    cd / && \
    rm -rf /tmp/Python-3.12.0*

RUN ln -sf /usr/local/bin/python3.12 /usr/bin/python && \
    ln -sf /usr/local/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip3


RUN python -m venv /home/devbox/project

RUN chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh

RUN mkdir /home/devbox/.devbox