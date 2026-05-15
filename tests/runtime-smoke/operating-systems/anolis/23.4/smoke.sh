#!/bin/bash
set -eu

project_dir=/home/devbox/project

if [ ! -d "$project_dir" ]; then
  echo "Missing project dir: $project_dir" >&2
  exit 1
fi

# load profile env (best effort)
set +u
[ -f /etc/profile ] && . /etc/profile || true
if [ -d /etc/profile.d ]; then
  for f in /etc/profile.d/*.sh; do
    [ -r "$f" ] && . "$f" || true
  done
fi
[ -f /home/devbox/.bashrc ] && . /home/devbox/.bashrc || true
set -u

if [ "${SMOKE_DEBUG:-}" = "1" ]; then
  echo "SMOKE_DEBUG=1"
  echo "user=$(id -un) uid=$(id -u) gid=$(id -g)"
  echo "HOME=$HOME"
  echo "SHELL=${SHELL:-}"
  echo "PATH=$PATH"
  for cmd in dnf yum rpm busybox bash sudo curl wget git python3; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "cmd:$cmd=$(command -v "$cmd")"
    else
      echo "cmd:$cmd=missing"
    fi
  done
fi

if ! grep -qi anolis /etc/os-release; then
  echo "Expected Anolis in /etc/os-release" >&2
  exit 1
fi

if ! id devbox >/dev/null 2>&1; then
  echo "User devbox not found" >&2
  exit 1
fi

if [ ! -f "$project_dir/README.md" ]; then
  echo "Missing README.md in $project_dir" >&2
  exit 1
fi

if [ ! -f "$project_dir/entrypoint.sh" ]; then
  echo "Missing entrypoint.sh in $project_dir" >&2
  exit 1
fi

if ! command -v busybox >/dev/null 2>&1; then
  echo "busybox not found" >&2
  exit 1
fi

if ! command -v dnf >/dev/null 2>&1 && ! command -v yum >/dev/null 2>&1; then
  echo "dnf/yum not found" >&2
  exit 1
fi

if [ ! -x /usr/sbin/sshd ]; then
  echo "sshd not found" >&2
  exit 1
fi

if ! /usr/sbin/sshd -T | grep -qx 'allowtcpforwarding yes'; then
  echo "sshd AllowTcpForwarding is not enabled" >&2
  exit 1
fi

glibc_version="$(ldd --version | head -n1 | grep -oE '[0-9]+[.][0-9]+' | tail -n1)"
if ! awk -v version="$glibc_version" 'BEGIN { split(version, v, "."); exit !((v[1] > 2) || (v[1] == 2 && v[2] >= 28)) }'; then
  echo "glibc $glibc_version is older than the VS Code Server minimum 2.28" >&2
  exit 1
fi

if ! grep -ao 'GLIBCXX_3\.4\.25' /usr/lib64/libstdc++.so.6 >/dev/null 2>&1; then
  echo "libstdc++ does not provide GLIBCXX_3.4.25 required by VS Code Server" >&2
  exit 1
fi

# entrypoint smoke
entrypoint="$project_dir/entrypoint.sh"
if [ ! -f "$entrypoint" ]; then
  echo "Missing entrypoint.sh in $project_dir" >&2
  exit 1
fi

if ! command -v bash >/dev/null 2>&1; then
  echo "bash not found" >&2
  exit 1
fi

( cd "$project_dir" && bash "$entrypoint" ) >/tmp/entrypoint.log 2>&1 &
pid=$!
sleep 3
if ! kill -0 "$pid" >/dev/null 2>&1; then
  echo "entrypoint exited early" >&2
  echo "---- entrypoint log ----" >&2
  cat /tmp/entrypoint.log >&2 || true
  exit 1
fi
kill "$pid" >/dev/null 2>&1 || true
wait "$pid" >/dev/null 2>&1 || true

echo "ok"
