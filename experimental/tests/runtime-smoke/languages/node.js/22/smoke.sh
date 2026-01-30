#!/bin/sh
set -eu

project_dir=/home/devbox/project

if [ ! -d "$project_dir" ]; then
  echo "Missing project dir: $project_dir" >&2
  exit 1
fi

cd "$project_dir"

node -e 'process.exit(process.versions.node.split(".")[0]==="22"?0:1)'

if [ ! -f "$project_dir/hello_world.js" ]; then
  echo "Missing hello_world.js in $project_dir" >&2
  exit 1
fi

if [ ! -f "$project_dir/README.md" ]; then
  echo "Missing README.md in $project_dir" >&2
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
