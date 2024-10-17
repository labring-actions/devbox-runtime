FROM ghcr.io/labring-actions/devbox/debian-ssh-12.6:d720f6

RUN cd /home/sealos/project && \
    rm -rf ./*

COPY /Language/php/project /home/sealos/project

RUN apt update && \
    apt install -y apt-transport-https lsb-release ca-certificates wget  && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt update && \
    apt install -y php7.4 php7.4-cli php7.4-common php7.4-xml php-pear php7.4-mbstring && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chown -R sealos:sealos /home/sealos/project && \
    chmod -R u+rw /home/sealos/project && \
    rm -rf /var/lib/apt/lists/* && \
    chmod -R +x /home/sealos/project/entrypoint.sh

# 创建必要的目录
RUN mkdir /root/.sealos