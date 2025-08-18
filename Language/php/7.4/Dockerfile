FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:a5f75b3
# Set the user to root
USER root

RUN apt update && \
    apt install -y apt-transport-https lsb-release ca-certificates wget  && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt update && \
    apt install -y php7.4 php7.4-cli php7.4-common php7.4-xml php-pear php7.4-mbstring php-pgsql php-mysql php-mongo php-redis && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    rm -rf /var/lib/apt/lists/*

COPY /Language/php/php.ini /etc/php/7.4/apache2/php.ini

USER devbox

RUN mkdir -p /home/devbox/.devbox && \
    if [ -d /home/devbox/project ]; then rm -rf /home/devbox/project/*; fi

COPY --chown=devbox:devbox /Language/php/project /home/devbox/project

RUN chmod +x /home/devbox/project/entrypoint.sh