#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

php_apt_source_url() {
    if [ "$L10N" = "zh_CN" ]; then
        printf '%s\n' "https://mirrors.ustc.edu.cn/sury/php"
        return
    fi

    printf '%s\n' "https://packages.sury.org/php"
}

configure_php_apt_source() {
    local source_url
    source_url="$(php_apt_source_url)"

    wget -O /etc/apt/trusted.gpg.d/php.gpg "${source_url}/apt.gpg"
    printf 'deb %s/ %s main\n' "$source_url" "$(lsb_release -sc)" >/etc/apt/sources.list.d/php.list
}

install_composer() {
    if [ "$L10N" = "zh_CN" ]; then
        curl -fsSL https://mirrors.aliyun.com/composer/composer.phar -o /usr/local/bin/composer
        chmod 0755 /usr/local/bin/composer
        return
    fi

    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
    php7.4 /tmp/composer-setup.php -- --install-dir=/usr/local/bin --filename=composer
    rm -f /tmp/composer-setup.php
}

configure_composer_mirror() {
    local user_home="$1"
    local owner="${2:-}"

    mkdir -p "$user_home"
    HOME="$user_home" composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

    if [ -n "$owner" ]; then
        chown -R "$owner:$owner" "$user_home/.config" "$user_home/.composer" 2>/dev/null || true
    fi
}

# Install PHP 7.4 from Sury repository
# Note: wget, curl, and ca-certificates are already installed in the Debian base image layer via install-base-pkg-deb.sh
apt-get update && \
    apt-get install -y apt-transport-https lsb-release && \
    configure_php_apt_source && \
    apt-get update && \
    apt-get install -y \
        php7.4 \
        php7.4-cli \
        php7.4-common \
        php7.4-xml \
        php7.4-mbstring \
        php7.4-pgsql \
        php7.4-mysql \
        php7.4-mongodb \
        php7.4-redis \
        unzip && \
    update-alternatives --install /usr/bin/php php /usr/bin/php7.4 74 || true && \
    update-alternatives --set php /usr/bin/php7.4 || true && \
    install_composer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

if [ "$L10N" = "zh_CN" ]; then
    configure_composer_mirror /root

    DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
    if [ -z "$DEVBOX_HOME" ]; then
        DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
    fi
    configure_composer_mirror "$DEVBOX_HOME" "$DEFAULT_DEVBOX_USER"
fi
