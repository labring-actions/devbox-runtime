FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:501781

RUN cd /home/devbox/project && \
rm -rf ./*

COPY /Language/c/project /home/devbox/project

RUN apt-get update && \
    apt-get install -y gcc g++ make && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
 
RUN mkdir /root/.devbox