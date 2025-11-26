#!/usr/bin/env bash
set -euo pipefail
# Override wtmp rotation
cat > /etc/logrotate.d/wtmp <<'EOF'
/var/log/wtmp {
		missingok
		daily
		create 0660 root utmp
		rotate 1
		maxsize 10M
}
EOF
# Override btmp rotation
cat > /etc/logrotate.d/btmp <<'EOF'
/var/log/btmp {
		missingok
		daily
		create 0664 root utmp
		rotate 1
		maxsize 10M
}
EOF


# Ensure /run/utmp exists with secure permissions (some tools expect it)
if [ ! -e /run/utmp ]; then
	: > /run/utmp
	chmod 664 /run/utmp
	chown root:utmp /run/utmp
fi