#!/usr/bin/env bash
set -euo pipefail
# Enable compression in global logrotate.conf
if ! grep -q '^compress' /etc/logrotate.conf; then
	if grep -q '^#.*compress' /etc/logrotate.conf; then
		sed -i '/^#.*compress/ s/^# *//' /etc/logrotate.conf
	else
		# insert after first 'create' or at end
		if grep -q '^create ' /etc/logrotate.conf; then
			sed -i '/^create /a compress' /etc/logrotate.conf
		else
			echo 'compress' >> /etc/logrotate.conf
		fi
	fi
fi