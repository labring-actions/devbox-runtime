#!/usr/bin/env bash
set -euo pipefail
# Source some common functions and variables
BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
ROOT_DIR=$BASE_TOOLS_DIR/scripts/svc
source $ROOT_DIR/common.sh
# Configure sshd
SSHD_CONFIG=/etc/ssh/sshd_config

set_sshd_config() {
	local key value
	key="$(echo "$1" | awk '{print $1}')"
	value="$(echo "$1" | cut -d' ' -f2-)"
	if grep -q "^$key " "$SSHD_CONFIG"; then
		sed -i "s|^$key .*|$key $value|" "$SSHD_CONFIG"
	else
		echo "$key $value" >> "$SSHD_CONFIG"
	fi
}

set_sshd_config 'X11Forwarding no'
set_sshd_config 'IgnoreRhosts yes'
set_sshd_config 'ListenAddress 0.0.0.0'
set_sshd_config 'Port 22'
set_sshd_config 'AuthorizedKeysFile /usr/start/.ssh/authorized_keys'
set_sshd_config 'PasswordAuthentication no'
set_sshd_config 'PubKeyAuthentication yes'
set_sshd_config 'PermitRootLogin prohibit-password'
set_sshd_config 'PermitEmptyPasswords no'
mkdir -p /run/sshd && chmod 755 /run/sshd

# sshd service
make_longrun sshd /usr/sbin/sshd -D -e
touch "$S6_DIR/sshd/dependencies.d/startup"
echo 'sshd-log' > "$S6_DIR/sshd/producer-for"

# sshd log service
make_log_longrun sshd-log logutil-service /var/log/sshd
touch "$S6_DIR/sshd-log/dependencies.d/sshd-log-prepare"
echo 'sshd' > "$S6_DIR/sshd-log/consumer-for"
echo 'sshd-pipeline' > "$S6_DIR/sshd-log/pipeline-name"

# Prepare sshd log directory service
make_oneshot_up sshd-log-prepare \
	'if { mkdir -p /var/log/sshd }' \
	'if { chown nobody:nogroup /var/log/sshd }' \
	'chmod 02755 /var/log/sshd'
touch "$S6_DIR/sshd-log-prepare/dependencies.d/base"

for svc in sshd sshd-log-prepare sshd-log; do
	: >"$S6_DIR/user/contents.d/$svc"
done

# Ensure s6 service scripts have correct permissions if they already exist (idempotent)
for f in \
    $S6_DIR/sshd/run \
    $S6_DIR/sshd-log/run; do
    [ -f "$f" ] && chmod 700 "$f" || true
done

echo "sshd services ensured." >&2