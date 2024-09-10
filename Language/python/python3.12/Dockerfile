FROM ghcr.io/labring-actions/devbox/debian-ssh:d8f335

COPY /Language/python/workspace /home/sealos/workspace

RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /home/sealos/workspace 

RUN mkdir /root/.sealos