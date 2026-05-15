#!/usr/bin/env bash
set -euo pipefail
UTMP_GROUP=utmp
if ! getent group "$UTMP_GROUP" >/dev/null 2>&1; then
	UTMP_GROUP=root
fi
# Override wtmp rotation
cat > /etc/logrotate.d/wtmp <<EOF
/var/log/wtmp {
		missingok
		daily
		create 0660 root $UTMP_GROUP
		rotate 1
		maxsize 10M
}
EOF
# Override btmp rotation
cat > /etc/logrotate.d/btmp <<EOF
/var/log/btmp {
		missingok
		daily
		create 0664 root $UTMP_GROUP
		rotate 1
		maxsize 10M
}
EOF


# Ensure /run/utmp exists with secure permissions (some tools expect it)
if [ ! -e /run/utmp ]; then
	: > /run/utmp
	chmod 664 /run/utmp
	chown root:"$UTMP_GROUP" /run/utmp
fi
