FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:d720f6

RUN cd /home/sealos/project && \
rm -rf ./*

COPY  /Language/php/project /home/sealos/project

RUN apt update && \
    apt install -y php-common libapache2-mod-php php-cli php-xml php-pear wget&& \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project && \
    rm -rf /var/lib/apt/lists/* && \
    chmod -R +x /home/sealos/project/entrypoint.sh

RUN mkdir /root/.sealos