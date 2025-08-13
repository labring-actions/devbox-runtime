FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:stable

RUN cd /home/devbox/project && \
rm -rf ./*
 
COPY  /Language/php/project /home/devbox/project

RUN apt update && \
    apt install -y apt-transport-https lsb-release ca-certificates wget  && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt update && \
    apt install -y php8.2 php8.2-cli php8.2-common php8.2-xml php-pear php8.2-mbstring php-pgsql php-mysql php-mongo php-redis && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    rm -rf /var/lib/apt/lists/* && \
    chmod -R +x /home/devbox/project/entrypoint.sh

COPY /Language/php/php.ini /etc/php/8.2/apache2/php.ini

RUN mkdir /root/.devbox