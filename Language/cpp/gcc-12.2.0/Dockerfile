FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a5f75b3
RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Language/cpp/project /home/devbox/project

RUN apt-get update && \
    apt-get install -y gcc g++ make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    chmod -R +x /home/devbox/project/entrypoint.sh
 
RUN mkdir /root/.devbox