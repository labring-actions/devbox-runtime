#!/usr/bin/env bash
set -euo pipefail

L10N=${L10N:-en_US}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}
RUST_VERSION=${RUST_VERSION:-1.81.0}

configure_cargo_mirror() {
    local cargo_home="$1"
    local owner="${2:-}"
    local config_file="$cargo_home/config.toml"

    mkdir -p "$cargo_home"
    cat > "$config_file" <<'EOF'
[source.crates-io]
replace-with = "rsproxy-sparse"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"

[net]
git-fetch-with-cli = true
EOF
    chmod 0644 "$config_file"

    if [ -n "$owner" ]; then
        chown -R "$owner:$owner" "$cargo_home" || true
    fi
}

# Install build dependencies
# Note: curl and make are already installed in the Debian base image layer via install-base-pkg-deb.sh
apt-get update && \
    apt-get install -y build-essential libudev-dev pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up Rust for root
ROOT_HOME="${HOME:-/root}"

# Set up Rust for devbox user
DEVBOX_USER="${DEFAULT_DEVBOX_USER}"
DEVBOX_HOME="$(getent passwd "$DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
    DEVBOX_HOME="/home/${DEVBOX_USER}"
fi

# Install Rust for devbox user
# Note: Rust installation needs to be done as the devbox user, but we're running as root
# So we'll create the directory and install Rust, then fix permissions
mkdir -p "$DEVBOX_HOME/.cargo"
chown -R "${DEVBOX_USER}:${DEVBOX_USER}" "$DEVBOX_HOME/.cargo" || true

# Install the template-declared Rust version using rustup.
su - "$DEVBOX_USER" -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain ${RUST_VERSION}"
su - "$DEVBOX_USER" -c "$DEVBOX_HOME/.cargo/bin/rustup default ${RUST_VERSION}"

# Set up environment variables for devbox user
# shellcheck disable=SC2016
grep -qxF 'export PATH=/home/devbox/.cargo/bin:$PATH' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo 'export PATH=/home/devbox/.cargo/bin:$PATH' >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true
grep -qxF '. /home/devbox/.cargo/env' "$DEVBOX_HOME/.bashrc" 2>/dev/null || \
    echo '. /home/devbox/.cargo/env' >> "$DEVBOX_HOME/.bashrc" 2>/dev/null || true

# Ensure cargo is in PATH for root as well
cat > /etc/profile.d/rust-env.sh <<EOF
export CARGO_HOME=$DEVBOX_HOME/.cargo
export RUSTUP_HOME=$DEVBOX_HOME/.rustup
export PATH=$DEVBOX_HOME/.cargo/bin:\$PATH
EOF
chmod 0644 /etc/profile.d/rust-env.sh

grep -qxF "export CARGO_HOME=$DEVBOX_HOME/.cargo" "$ROOT_HOME/.bashrc" || \
    echo "export CARGO_HOME=$DEVBOX_HOME/.cargo" >> "$ROOT_HOME/.bashrc"
grep -qxF "export RUSTUP_HOME=$DEVBOX_HOME/.rustup" "$ROOT_HOME/.bashrc" || \
    echo "export RUSTUP_HOME=$DEVBOX_HOME/.rustup" >> "$ROOT_HOME/.bashrc"
# shellcheck disable=SC2016
grep -qxF "export PATH=$DEVBOX_HOME/.cargo/bin:\$PATH" "$ROOT_HOME/.bashrc" || \
    echo "export PATH=$DEVBOX_HOME/.cargo/bin:\$PATH" >> "$ROOT_HOME/.bashrc"

export CARGO_HOME="$DEVBOX_HOME/.cargo"
export RUSTUP_HOME="$DEVBOX_HOME/.rustup"
export PATH="$DEVBOX_HOME/.cargo/bin:${PATH}"

if [ "$L10N" = "zh_CN" ]; then
    configure_cargo_mirror /root/.cargo
    configure_cargo_mirror "$DEVBOX_HOME/.cargo" "$DEVBOX_USER"
fi

rustc --version | grep -q "rustc ${RUST_VERSION}"
cargo --version | grep -q "cargo ${RUST_VERSION}"
