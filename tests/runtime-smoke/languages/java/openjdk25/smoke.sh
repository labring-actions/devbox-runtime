#!/bin/bash
set -eu

project_dir=/home/devbox/project

if [ ! -d "$project_dir" ]; then
  echo "Missing project dir: $project_dir" >&2
  exit 1
fi

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
  echo "JAVA_HOME=${JAVA_HOME:-}"
  echo "MAVEN_HOME=${MAVEN_HOME:-}"
  echo "PATH=$PATH"
  for cmd in java javac mvn curl; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "cmd:$cmd=$(command -v "$cmd")"
    else
      echo "cmd:$cmd=missing"
    fi
  done
fi

cd "$project_dir"

javac -version 2>&1 | grep -q 'javac 25.0.4.1'
java -version 2>&1 | grep -q '25.0.4.1'
java -version 2>&1 | grep -q 'Temurin'
java -XshowSettings:properties -version 2>&1 | grep -q 'file.encoding = UTF-8'
mvn -version | grep -q 'Apache Maven 3.9.16'
mvn -version | grep -q 'Java version: 25.0.4.1'

for required_file in HelloWorld.java README.md; do
  if [ ! -f "$project_dir/$required_file" ]; then
    echo "Missing $required_file in $project_dir" >&2
    exit 1
  fi
done

entrypoint="$project_dir/entrypoint.sh"
if [ ! -x "$entrypoint" ]; then
  echo "Missing executable entrypoint.sh in $project_dir" >&2
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
deadline=$((SECONDS + 60))
while ! curl -fsS http://127.0.0.1:8080 >/tmp/smoke-response 2>/dev/null; do
  if ! kill -0 "$pid" >/dev/null 2>&1; then
    echo "entrypoint exited early" >&2
    echo "---- entrypoint log ----" >&2
    cat /tmp/entrypoint.log >&2 || true
    exit 1
  fi
  if [ "$SECONDS" -ge "$deadline" ]; then
    echo "entrypoint did not serve HTTP on port 8080 within 60 seconds" >&2
    echo "---- entrypoint log ----" >&2
    cat /tmp/entrypoint.log >&2 || true
    exit 1
  fi
  sleep 2
done

grep -q 'Hello, World!' /tmp/smoke-response

cleanup_entrypoint
trap - EXIT INT TERM

echo "ok"
