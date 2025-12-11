#!/usr/bin/env bash
set -euo pipefail

# Currently, we set locale to en_US.UTF-8 even in zh_CN images
echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8