#!/usr/bin/env bash
set -euo pipefail

CLAWDBOT_VERSION=${CLAWDBOT_VERSION:-latest}
DEFAULT_DEVBOX_USER=${DEFAULT_DEVBOX_USER:-devbox}

DEVBOX_HOME="$(getent passwd "$DEFAULT_DEVBOX_USER" | cut -d: -f6 || true)"
if [ -z "$DEVBOX_HOME" ]; then
  DEVBOX_HOME="/home/${DEFAULT_DEVBOX_USER}"
fi

npm install -g "clawdbot@${CLAWDBOT_VERSION}"

mkdir -p "$DEVBOX_HOME/.clawdbot" "$DEVBOX_HOME/workspace"
cat <<'JSON' > "$DEVBOX_HOME/.clawdbot/clawdbot.json"
{
  "gateway": {
    "controlUi": {
      "enabled": true,
      "allowInsecureAuth": true
    }
  },
  "messages": {
    "ackReactionScope": "group-mentions"
  },
  "agents": {
    "defaults": {
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      },
      "compaction": {
        "mode": "safeguard"
      }
    }
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      }
    }
  }
}
JSON

chown -R "$DEFAULT_DEVBOX_USER:$DEFAULT_DEVBOX_USER" "$DEVBOX_HOME/.clawdbot" "$DEVBOX_HOME/workspace"
