FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:501781

RUN cd /home/devbox/project && \
    rm -rf ./*

COPY /Language/php/project /home/devbox/project

RUN apt update && \
    apt install -y apt-transport-https lsb-release ca-certificates wget  && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt update && \
    apt install -y php7.4 php7.4-cli php7.4-common php7.4-xml php-pear php7.4-mbstring && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chown -R devbox:devbox /home/devbox/project && \
    chmod -R u+rw /home/devbox/project && \
    rm -rf /var/lib/apt/lists/* && \
    chmod -R +x /home/devbox/project/entrypoint.sh

# 创建必要的目录
RUN mkdir /root/.devbox