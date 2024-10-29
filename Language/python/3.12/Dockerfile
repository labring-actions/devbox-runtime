FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:501781
RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Language/python/project /home/devbox/project

RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /home/devbox/project && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
 
RUN mkdir /root/.devbox