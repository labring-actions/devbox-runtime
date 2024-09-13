FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a9c28d

RUN cd /home/sealos/project && \
rm -rf ./*

COPY /Language/python/project /home/sealos/project

RUN apt-get update && \
    apt-get install -y python3.10 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /home/sealos/project && \
    chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project
    
RUN mkdir /root/.sealos