#!/bin/bash
set -eu

workspace_dir=/home/devbox/workspace

if [ ! -d "$workspace_dir" ]; then
  echo "Missing workspace dir: $workspace_dir" >&2
  exit 1
fi

# load profile env (best effort)
set +u
# shellcheck disable=SC1091
[ -f /etc/profile ] && . /etc/profile || true
if [ -d /etc/profile.d ]; then
  for f in /etc/profile.d/*.sh; do
    # shellcheck disable=SC1090
    [ -r "$f" ] && . "$f" || true
  done
fi
# shellcheck disable=SC1091
[ -f /home/devbox/.bashrc ] && . /home/devbox/.bashrc || true
set -u

if [ "${SMOKE_DEBUG:-}" = "1" ]; then
  echo "SMOKE_DEBUG=1"
  echo "user=$(id -un) uid=$(id -u) gid=$(id -g)"
  echo "HOME=$HOME"
  echo "SHELL=${SHELL:-}"
  echo "PATH=$PATH"
  for cmd in codex node npm python3 pip3 kubectl helm buildctl bun rg bwrap railpack versitygw; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "cmd:$cmd=$(command -v "$cmd")"
    else
      echo "cmd:$cmd=missing"
    fi
  done
fi

cd "$workspace_dir"

for cmd in codex node npm python3 pip3 kubectl helm buildctl bun rg bwrap railpack versitygw; do
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
versitygw --version >/dev/null

if [ "${AWS_ACCESS_KEY_ID:-}" != "admin" ]; then
  echo "AWS_ACCESS_KEY_ID should default to admin" >&2
  exit 1
fi

if [ "${AWS_REGION:-}" != "sealos-internal" ]; then
  echo "AWS_REGION should default to sealos-internal" >&2
  exit 1
fi

if [ "${S3_ENDPOINT:-}" != "http://127.0.0.1:1319" ]; then
  echo "S3_ENDPOINT should point kaniko at local versitygw" >&2
  exit 1
fi

if [ "${S3_FORCE_PATH_STYLE:-}" != "true" ]; then
  echo "S3_FORCE_PATH_STYLE should default to true" >&2
  exit 1
fi

if [ ! -f /etc/s6-overlay/s6-rc.d/versitygw/run ]; then
  echo "versitygw s6 run file not found" >&2
  exit 1
fi

if [ "${KANIKO_CONTEXT_S3_BASE:-}" != "s3://kaniko-contexts/contexts" ]; then
  echo "KANIKO_CONTEXT_S3_BASE should default to s3://kaniko-contexts/contexts" >&2
  exit 1
fi

if [ ! -d "$workspace_dir/.versitygw-s3/kaniko-contexts/contexts" ]; then
  echo "kaniko context POSIX directory not found" >&2
  exit 1
fi

echo "ok"
