FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:501781

RUN cd /home/devbox/project && \
rm -rf ./*

COPY  /Language/php/project /home/devbox/project

RUN apt update && \
    apt install -y php-common libapache2-mod-php php-cli php-xml php-pear wget&& \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    rm -rf /var/lib/apt/lists/* && \
    chmod -R +x /home/devbox/project/entrypoint.sh

RUN mkdir /root/.devbox