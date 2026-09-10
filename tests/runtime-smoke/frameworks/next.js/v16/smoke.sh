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
  for cmd in node npm yarn pnpm npx create-next-app; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "cmd:$cmd=$(command -v "$cmd")"
    else
      echo "cmd:$cmd=missing"
    fi
  done
fi

cd "$project_dir"

node -e 'process.exit(process.versions.node.split(".")[0]==="20"?0:1)'

for file in package.json package-lock.json next.config.ts tsconfig.json app/page.tsx app/layout.tsx README.md; do
  if [ ! -f "$project_dir/$file" ]; then
    echo "Missing $file in $project_dir" >&2
    exit 1
  fi
done

if [ ! -d "$project_dir/.next" ]; then
  echo "Missing prebuilt .next output in $project_dir" >&2
  exit 1
fi

entrypoint="$project_dir/entrypoint.sh"
if [ ! -x "$entrypoint" ]; then
  echo "Missing executable entrypoint.sh in $project_dir" >&2
  exit 1
fi

stop_entrypoint() {
  pid="$1"
  kill -TERM "-$pid" >/dev/null 2>&1 || kill -TERM "$pid" >/dev/null 2>&1 || true
  sleep 1
  kill -KILL "-$pid" >/dev/null 2>&1 || kill -KILL "$pid" >/dev/null 2>&1 || true
  wait "$pid" >/dev/null 2>&1 || true
}

if ! command -v setsid >/dev/null 2>&1; then
  echo "setsid not found" >&2
  exit 1
fi

setsid bash -lc "cd '$project_dir' && bash '$entrypoint' production" >/tmp/entrypoint.log 2>&1 &
pid=$!
for _ in $(seq 1 60); do
  if curl -fsS --max-time 2 http://127.0.0.1:3000/ >/tmp/next-smoke.html 2>/tmp/next-smoke.err; then
    stop_entrypoint "$pid"
    grep -q "Next.js is ready" /tmp/next-smoke.html
    echo "ok"
    exit 0
  fi
  if ! kill -0 "$pid" >/dev/null 2>&1; then
    echo "entrypoint exited early" >&2
    echo "---- entrypoint log ----" >&2
    cat /tmp/entrypoint.log >&2 || true
    exit 1
  fi
  sleep 2
done

echo "entrypoint did not serve HTTP on port 3000" >&2
echo "---- entrypoint log ----" >&2
cat /tmp/entrypoint.log >&2 || true
stop_entrypoint "$pid"
exit 1
