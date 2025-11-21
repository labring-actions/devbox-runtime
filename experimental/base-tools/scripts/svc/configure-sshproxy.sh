#!/usr/bin/env bash
set -euo pipefail
# Source some common functions and variables
BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
ROOT_DIR=$BASE_TOOLS_DIR/scripts/svc
source $ROOT_DIR/common.sh
# sshproxy service
make_longrun sshproxy env SSHPROXY_AUTH_LOG=/var/log/sshd/current /usr/sbin/sshproxy :22 localhost:2222
touch "$S6_DIR/sshproxy/dependencies.d/sshd-log"
echo 'sshproxy-log' > "$S6_DIR/sshproxy/producer-for"

# sshproxy log service
make_log_longrun sshproxy-log logutil-service /var/log/sshproxy
touch "$S6_DIR/sshproxy-log/dependencies.d/sshproxy-log-prepare"
echo 'sshproxy' > "$S6_DIR/sshproxy-log/consumer-for"
echo 'sshproxy-pipeline' > "$S6_DIR/sshproxy-log/pipeline-name"

# Prepare sshproxy log directory service
make_oneshot_up sshproxy-log-prepare \
	'if { mkdir -p /var/log/sshproxy }' \
	'if { chown nobody:nogroup /var/log/sshproxy }' \
	'chmod 02755 /var/log/sshproxy'
touch "$S6_DIR/sshproxy-log-prepare/dependencies.d/base"

for svc in sshproxy sshproxy-log-prepare sshproxy-log; do
	: >"$S6_DIR/user/contents.d/$svc"
done

# Ensure s6 service scripts have correct permissions if they already exist (idempotent)
for f in \
    $S6_DIR/sshproxy/run \
    $S6_DIR/sshproxy-log/run; do
    [ -f "$f" ] && chmod 700 "$f" || true
done

echo "sshproxy services ensured." >&2