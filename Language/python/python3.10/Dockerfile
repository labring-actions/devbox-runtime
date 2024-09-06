FROM ghcr.io/labring-actions/devbox/debian-ssh:d8f335

RUN apt-get update && \
    apt-get install -y python3.10 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN mkdir /root/.sealos