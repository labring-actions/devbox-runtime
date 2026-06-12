#!/bin/bash
set -eu

workspace_dir=/home/devbox/workspace

if [ ! -d "$workspace_dir" ]; then
  echo "Missing workspace dir: $workspace_dir" >&2
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
  for cmd in codex node npm python3 pip3 kubectl helm buildctl bun rg bwrap railpack; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "cmd:$cmd=$(command -v "$cmd")"
    else
      echo "cmd:$cmd=missing"
    fi
  done
fi

cd "$workspace_dir"

for cmd in codex node npm python3 pip3 kubectl helm buildctl bun rg bwrap railpack; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd not found" >&2
    exit 1
  fi
done

if [ ! -x /usr/local/bin/codex-gateway ]; then
  echo "codex-gateway binary not found" >&2
  exit 1
fi

railpack --version >/dev/null
railpack schema >/dev/null

echo "ok"
