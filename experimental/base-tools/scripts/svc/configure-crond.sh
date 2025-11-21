#!/usr/bin/env bash
set -euo pipefail
# Source some common functions and variables
BASE_TOOLS_DIR=${BASE_TOOLS_DIR:-/opt/base-tools}
ROOT_DIR=$BASE_TOOLS_DIR/scripts/svc
source $ROOT_DIR/common.sh
# crond service
make_longrun crond /usr/sbin/supercronic /etc/crontab
touch "$S6_DIR/crond/dependencies.d/startup"
echo 'crond-log' > "$S6_DIR/crond/producer-for"

# crond log service
make_log_longrun crond-log logutil-service /var/log/crond
touch "$S6_DIR/crond-log/dependencies.d/crond-log-prepare"
echo 'crond' > "$S6_DIR/crond-log/consumer-for"
echo 'crond-pipeline' > "$S6_DIR/crond-log/pipeline-name"

# crond log preparation service
make_oneshot_up crond-log-prepare \
	'if { mkdir -p /var/log/crond }' \
	'if { chown nobody:nogroup /var/log/crond }' \
	'chmod 02755 /var/log/crond'
touch "$S6_DIR/crond-log-prepare/dependencies.d/base"

for svc in crond crond-log-prepare crond-log; do
	: >"$S6_DIR/user/contents.d/$svc"
done

# Ensure s6 service scripts have correct permissions if they already exist (idempotent)
for f in \
    $S6_DIR/crond/run \
    $S6_DIR/crond-log/run; do
    [ -f "$f" ] && chmod 700 "$f" || true
done

echo "crond services ensured." >&2