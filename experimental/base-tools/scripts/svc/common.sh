# Setup s6 service for sshd
export S6_DIR=/etc/s6-overlay/s6-rc.d

make_log_longrun() { # name cmd...
	local name="$1"; shift
	mkdir -p "$S6_DIR/$name" "$S6_DIR/$name/dependencies.d"
	{ echo '#!/usr/bin/env bash'; echo "exec $*"; } >"$S6_DIR/$name/run"
	echo longrun >"$S6_DIR/$name/type"
	chmod 700 "$S6_DIR/$name/run"
}

make_longrun() { # name cmd...
	local name="$1"; shift
	mkdir -p "$S6_DIR/$name" "$S6_DIR/$name/dependencies.d"
	{ echo '#!/usr/bin/env bash'; echo 'exec 2>&1'; echo "exec $*"; } >"$S6_DIR/$name/run"
	echo longrun >"$S6_DIR/$name/type"
	chmod 700 "$S6_DIR/$name/run"
}

make_oneshot_up() { # name lines...
	local name="$1"; shift
	mkdir -p "$S6_DIR/$name" "$S6_DIR/$name/dependencies.d"
	echo oneshot >"$S6_DIR/$name/type"
	printf '%s\n' "$@" >"$S6_DIR/$name/up"
	chmod 644 "$S6_DIR/$name/up"
}