#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ "${DEVBOX_ENTRYPOINT_AS_DEVBOX:-1}" = "1" ] && id devbox >/dev/null 2>&1; then
    export DEVBOX_ENTRYPOINT_AS_DEVBOX=0
    SCRIPT_PATH=$(readlink -f "$0")
    exec runuser -u devbox -- bash "$SCRIPT_PATH" "$@"
fi

cd /home/devbox/project

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

if [ -n "${OPENAI_BASE_URL:-}" ] && [ -n "${OPENAI_API_KEY:-}" ] && [ -n "${OPENAI_MODEL:-}" ]; then
  OPENAI_BASE_URL_ESCAPED=$(escape_sed_replacement "$OPENAI_BASE_URL")
  OPENAI_API_KEY_ESCAPED=$(escape_sed_replacement "$OPENAI_API_KEY")
  OPENAI_MODEL_ESCAPED=$(escape_sed_replacement "$OPENAI_MODEL")

  sed -i "s/<OPENAI_BASE_URL>/${OPENAI_BASE_URL_ESCAPED}/g" /home/devbox/.openclaw/openclaw.json
  sed -i "s/<OPENAI_API_KEY>/${OPENAI_API_KEY_ESCAPED}/g" /home/devbox/.openclaw/openclaw.json
  sed -i "s/<OPENAI_MODEL>/${OPENAI_MODEL_ESCAPED}/g" /home/devbox/.openclaw/openclaw.json
fi

node auto-approve.js &
NODE_PID=$!
trap 'kill "$NODE_PID" 2>/dev/null' EXIT
openclaw gateway --allow-unconfigured --bind lan
