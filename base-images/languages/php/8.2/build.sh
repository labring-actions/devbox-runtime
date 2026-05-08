#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

configure_composer_mirror() {
    local user_home="$1"
    local owner="${2:-}"

    mkdir -p "$user_home"
    HOME="$user_home" composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

    if [ -n "$owner" ]; then
        chown -R "$owner:$owner" "$user_home/.config" "$user_home/.composer" 2>/dev/null || true
    fi
}

# Install PHP 8.2 from Sury repository
# Note: wget, curl, and ca-certificates are already installed in the Debian base image layer via install-base-pkg-deb.sh
apt-get update && \
    apt-get install -y apt-transport-https lsb-release && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y \
        php8.2 \
        php8.2-cli \
        php8.2-common \
        php8.2-xml \
        php8.2-mbstring \
        php8.2-pgsql \
        php8.2-mysql \
        php8.2-mongodb \
        php8.2-redis \
        php-pear \
        unzip && \
    update-alternatives --install /usr/bin/php php /usr/bin/php8.2 100 && \
    update-alternatives --set php /usr/bin/php8.2 && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
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
