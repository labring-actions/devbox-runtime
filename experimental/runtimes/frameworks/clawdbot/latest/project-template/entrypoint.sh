#!/bin/bash
set -euo pipefail

cd /home/devbox/project
source .env
sed -i "s/<OPENAI_BASE_URL>/${OPENAI_BASE_URL}/g" /home/devbox/.openclaw/openclaw.json
sed -i "s/<OPENAI_API_KEY>/${OPENAI_API_KEY}/g" /home/devbox/.openclaw/openclaw.json
sed -i "s/<OPENAI_MODEL>/${OPENAI_MODEL}/g" /home/devbox/.openclaw/openclaw.json
node auto-approve.js &
exec openclaw gateway --allow-unconfigured --bind lan
