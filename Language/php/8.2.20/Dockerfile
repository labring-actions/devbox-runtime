FROM ghcr.io/labring-actions/devbox/debian-ssh:d8f335

COPY  /Language/php/project /home/sealos/project

RUN apt update && \
    apt install -y php-common libapache2-mod-php php-cli && \
    chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project && \
    rm -rf /var/lib/apt/lists/* 