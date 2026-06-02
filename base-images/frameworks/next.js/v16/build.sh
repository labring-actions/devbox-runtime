#!/usr/bin/env bash
set -euo pipefail

NEXT_VERSION=${NEXT_VERSION:-16.2.6}

# Install the Next.js project scaffolding CLI globally for convenience.
npm install -g "create-next-app@${NEXT_VERSION}"
