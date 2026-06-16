#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jdk maven nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

JAVA_ARCH="$(dpkg --print-architecture)"
JAVA_HOME_REAL="/usr/lib/jvm/java-17-openjdk-${JAVA_ARCH}"
ln -sfn "${JAVA_HOME_REAL}" /usr/lib/jvm/java-17-openjdk

ROOT_HOME="${HOME:-/root}"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
grep -qxF "export JAVA_HOME=$JAVA_HOME" "$ROOT_HOME/.bashrc" || \
    echo "export JAVA_HOME=$JAVA_HOME" >> "$ROOT_HOME/.bashrc"
grep -qxF "export PATH=\$PATH:\$JAVA_HOME/bin" "$ROOT_HOME/.bashrc" || \
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> "$ROOT_HOME/.bashrc"

DEVBOX_USER="${DEFAULT_DEVBOX_USER}"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

grep -qxF "export JAVA_HOME=$JAVA_HOME" "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo "export JAVA_HOME=$JAVA_HOME" >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true
grep -qxF "export PATH=\$PATH:\$JAVA_HOME/bin" "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true

if [ "$L10N" = "zh_CN" ]; then
    mkdir -p "$DEVBOX_HOME/.m2"
    cat > "$DEVBOX_HOME/.m2/settings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
          http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <id>aliyunmaven</id>
      <mirrorOf>central</mirrorOf>
      <name>Aliyun Maven</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
    chown -R "${DEVBOX_USER}:${DEVBOX_USER}" "$DEVBOX_HOME/.m2" || true
fi

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$PATH:$JAVA_HOME/bin
