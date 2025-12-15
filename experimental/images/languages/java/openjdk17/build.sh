#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

# Download and install OpenJDK 17
# Note: wget and curl are already installed in images/debian-12.6 via install-base-pkg-deb.sh
wget https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_linux-x64_bin.tar.gz && \
    mkdir -p /usr/lib/jvm && \
    tar -xvf openjdk-17+35_linux-x64_bin.tar.gz -C /usr/lib/jvm && \
    mv /usr/lib/jvm/jdk-17 /usr/lib/jvm/java-17-openjdk-amd64 && \
    rm -f openjdk-17+35_linux-x64_bin.tar.gz

# Download and install Maven 3.8.6
curl -o /tmp/apache-maven-3.8.6-bin.tar.gz https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz && \
    mkdir -p /opt/maven && \
    tar -xzf /tmp/apache-maven-3.8.6-bin.tar.gz -C /opt/maven && \
    ln -s /opt/maven/apache-maven-3.8.6 /opt/maven/latest && \
    ln -s /opt/maven/latest/bin/mvn /usr/bin/mvn && \
    rm -f /tmp/apache-maven-3.8.6-bin.tar.gz

# Set up Java for root
ROOT_HOME="${HOME:-/root}"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
grep -qxF "export JAVA_HOME=$JAVA_HOME" "$ROOT_HOME/.bashrc" || \
    echo "export JAVA_HOME=$JAVA_HOME" >> "$ROOT_HOME/.bashrc"
grep -qxF 'export PATH=$PATH:$JAVA_HOME/bin' "$ROOT_HOME/.bashrc" || \
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> "$ROOT_HOME/.bashrc"

# Set up Java for devbox user
DEVBOX_USER="${DEFAULT_DEVBOX_USER}"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

grep -qxF "export JAVA_HOME=$JAVA_HOME" "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo "export JAVA_HOME=$JAVA_HOME" >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true
grep -qxF 'export PATH=$PATH:$JAVA_HOME/bin' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true

# Configure Maven settings for Chinese users (if L10N is zh_CN)
if [ "$L10N" = "zh_CN" ]; then
    # Create Maven settings.xml with Chinese mirror
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

# Set environment variables
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

