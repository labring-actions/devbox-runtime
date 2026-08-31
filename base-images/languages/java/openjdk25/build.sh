#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
JAVA_HOME=${JAVA_HOME:-/opt/java/openjdk}
MAVEN_HOME=${MAVEN_HOME:-/opt/maven}
TEMURIN_RELEASE=jdk-25.0.4.1+1
TEMURIN_VERSION=25.0.4.1_1
MAVEN_VERSION=3.9.16
MAVEN_SHA512=831a8591fe20c8243b1dbe7d71e3244f31d1665b0804b2e825e38cbbe5ce0cafb8338851f90780735568773e0a6cd07bbec107cda0b896b008b861075358b6f6

apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RAW_ARCH="${TARGETARCH:-}"
if [ -z "$RAW_ARCH" ]; then
    RAW_ARCH="$(dpkg --print-architecture 2>/dev/null || true)"
fi
if [ -z "$RAW_ARCH" ]; then
    RAW_ARCH="${ARCH:-}"
fi

case "$RAW_ARCH" in
    amd64|x86_64)
        TEMURIN_ARCH=x64
        TEMURIN_SHA256=dbb698396d478e7fa2b1e50f4103324b2a99b90569ee27c33f2261f9215cf41e
        ;;
    arm64|aarch64)
        TEMURIN_ARCH=aarch64
        TEMURIN_SHA256=69df11a02cfa3ef7d7ca645e03edce6778ec090e100f6ae2b42097865730ac52
        ;;
    *)
        echo "Unsupported architecture: $RAW_ARCH" >&2
        exit 1
        ;;
esac

TEMURIN_ARCHIVE="OpenJDK25U-jdk_${TEMURIN_ARCH}_linux_hotspot_${TEMURIN_VERSION}.tar.gz"
TEMURIN_URL="https://github.com/adoptium/temurin25-binaries/releases/download/${TEMURIN_RELEASE}/${TEMURIN_ARCHIVE}"
curl -fsSL "$TEMURIN_URL" -o "/tmp/${TEMURIN_ARCHIVE}"
echo "${TEMURIN_SHA256}  /tmp/${TEMURIN_ARCHIVE}" | sha256sum -c -
mkdir -p "$JAVA_HOME"
tar -xzf "/tmp/${TEMURIN_ARCHIVE}" -C "$JAVA_HOME" --strip-components=1
rm -f "/tmp/${TEMURIN_ARCHIVE}"

MAVEN_ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_ARCHIVE}"
curl -fsSL "$MAVEN_URL" -o "/tmp/${MAVEN_ARCHIVE}"
echo "${MAVEN_SHA512}  /tmp/${MAVEN_ARCHIVE}" | sha512sum -c -
mkdir -p "$MAVEN_HOME"
tar -xzf "/tmp/${MAVEN_ARCHIVE}" -C "$MAVEN_HOME" --strip-components=1
rm -f "/tmp/${MAVEN_ARCHIVE}"

cat > /etc/profile.d/java-env.sh <<EOF
export JAVA_HOME=$JAVA_HOME
export MAVEN_HOME=$MAVEN_HOME
export PATH=\$JAVA_HOME/bin:\$MAVEN_HOME/bin:\$PATH
EOF
chmod 644 /etc/profile.d/java-env.sh

ROOT_HOME="${HOME:-/root}"
DEVBOX_USER="$DEFAULT_DEVBOX_USER"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

for shell_rc in "$ROOT_HOME/.bashrc" "$DEVBOX_HOME/.bashrc"; do
    grep -qxF "export JAVA_HOME=$JAVA_HOME" "$shell_rc" 2>/dev/null || \
        echo "export JAVA_HOME=$JAVA_HOME" >> "$shell_rc" 2>/dev/null || true
    grep -qxF "export MAVEN_HOME=$MAVEN_HOME" "$shell_rc" 2>/dev/null || \
        echo "export MAVEN_HOME=$MAVEN_HOME" >> "$shell_rc" 2>/dev/null || true
    grep -qxF 'export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH' "$shell_rc" 2>/dev/null || \
        echo 'export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH' >> "$shell_rc" 2>/dev/null || true
done

if [ "$L10N" = "zh_CN" ]; then
    mkdir -p "$DEVBOX_HOME/.m2"
    cat > "$DEVBOX_HOME/.m2/settings.xml" <<'EOF'
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

export JAVA_HOME MAVEN_HOME
export PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH"
java -version
javac -version
mvn -version
