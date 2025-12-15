#!/usr/bin/env bash
set -euo pipefail

# Install Quarkus CLI via jbang
# Note: curl is already installed in images/debian-12.6 via install-base-pkg-deb.sh
curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/ --global
curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio --global

echo "Quarkus CLI installed successfully"

