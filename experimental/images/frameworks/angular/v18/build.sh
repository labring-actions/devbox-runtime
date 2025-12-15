#!/usr/bin/env bash
set -euo pipefail

# Install Angular CLI and serve globally
# Angular CLI is needed for development and build commands
# serve is needed for serving production builds
npm install -g @angular/cli@^18.2.9 serve

echo "Angular CLI v18.2.9 and serve installed successfully"

