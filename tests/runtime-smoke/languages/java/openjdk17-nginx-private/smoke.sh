#!/bin/bash
set -eu

project_dir=/home/devbox/project

if [ ! -d "$project_dir" ]; then
  echo "Missing project dir: $project_dir" >&2
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
  for cmd in go python3 node php dotnet java javac nginx gcc g++ cargo rustc; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "cmd:$cmd=$(command -v "$cmd")"
    else
      echo "cmd:$cmd=missing"
    fi
  done
fi

cd "$project_dir"

mkdir -p \
  /tmp/nginx-devbox/client-body \
  /tmp/nginx-devbox/proxy \
  /tmp/nginx-devbox/fastcgi \
  /tmp/nginx-devbox/uwsgi \
  /tmp/nginx-devbox/scgi

javac --version | grep -q 'javac 17'
java -version 2>&1 | grep -q '17'
java -XshowSettings:properties -version 2>&1 | grep -q 'file.encoding = UTF-8'
/usr/sbin/nginx -v 2>&1 | grep -q '1.22.1'
/usr/sbin/nginx -t -c /etc/nginx/nginx.conf >/dev/null 2>&1

if [ ! -f "$project_dir/HelloWorld.java" ]; then
  echo "Missing HelloWorld.java in $project_dir" >&2
  exit 1
fi

if [ ! -f "$project_dir/nginx.conf" ]; then
  echo "Missing nginx.conf in $project_dir" >&2
  exit 1
fi

if [ ! -f "$project_dir/README.md" ]; then
  echo "Missing README.md in $project_dir" >&2
  exit 1
fi

entrypoint="$project_dir/entrypoint.sh"
if [ ! -x "$entrypoint" ]; then
  echo "Missing executable entrypoint.sh in $project_dir" >&2
  exit 1
fi

if ! command -v bash >/dev/null 2>&1; then
  echo "bash not found" >&2
  exit 1
fi

cleanup_entrypoint() {
  if [ -n "${pid:-}" ] && kill -0 "$pid" >/dev/null 2>&1; then
    kill "$pid" >/dev/null 2>&1 || true
    wait "$pid" >/dev/null 2>&1 || true
  fi
}

trap cleanup_entrypoint EXIT INT TERM

( cd "$project_dir" && bash "$entrypoint" ) >/tmp/entrypoint.log 2>&1 &
pid=$!
sleep 5
if ! kill -0 "$pid" >/dev/null 2>&1; then
  echo "entrypoint exited early" >&2
  echo "---- entrypoint log ----" >&2
  cat /tmp/entrypoint.log >&2 || true
  exit 1
fi

if command -v curl >/dev/null 2>&1; then
  curl -fsS http://127.0.0.1:8080 | grep -q 'Hello from JDK 17 behind Nginx'
else
  timeout 2 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/8080"
fi

cleanup_entrypoint
trap - EXIT INT TERM

echo "ok"
