#!/usr/bin/env bash
set -euo pipefail

STARTUP_SCRIPTS_DIR=${STARTUP_SCRIPTS_DIR:-/usr/start}

# Exit quietly if the directory is missing or empty
if [ ! -d "$STARTUP_SCRIPTS_DIR" ]; then
    exit 0
fi

mapfile -t STARTUP_SCRIPTS < <(find "$STARTUP_SCRIPTS_DIR" -type f -executable -print | sort)

if [ ${#STARTUP_SCRIPTS[@]} -eq 0 ]; then
    exit 0
fi

# Run each startup program sequentially in lexical order for deterministic behavior
# IMPORTANT: These programs should exit quickly to avoid delaying container startup
run_startup_script() {
    local script="$1"
    echo "Running startup script: $script" >&2
    if ! "$script"; then
        echo "Startup script failed: $script" >&2
        exit 1
    fi
}

for script in "${STARTUP_SCRIPTS[@]}"; do
    run_startup_script "$script"
done
