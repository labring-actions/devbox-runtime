#!/command/with-contenv sh
# ============================================================================
# pre-rc-init.sh
#
# Stage 2 Hook script executed BEFORE s6-rc compilation.
# This is the key to elegantly controlling services based on environment.
#
# Usage: Set S6_STAGE2_HOOK=<path/to/this/script> in Dockerfile.
#
# Execution order:
#   1. Container starts
#   2. Stage 1 (minimal init)
#   3. Stage 2 Hook (THIS SCRIPT) ← Before s6-rc compile!
#   4. s6-rc-compile (services in contents.d are compiled)
#   5. s6-rc starts services
# 
# This hook should run BEFORE s6-rc compilation, allowing us to disable services
# based on DEVBOX_ENV environment variable
# ============================================================================

set -eu

# s6 service definition directory
S6_DIR=/etc/s6-overlay/s6-rc.d
SOURCE_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# Read environment variable, default is development
DEVBOX_ENV=${DEVBOX_ENV:-development}

# Load shared service configuration

echo "[pre-rc-init] ========================================"
echo "[pre-rc-init] Environment: $DEVBOX_ENV"
echo "[pre-rc-init] Running BEFORE s6-rc compilation"
echo "[pre-rc-init] ========================================"

# Source the services configuration
. "$SOURCE_DIR/services.conf"

# Function to check if service should be enabled
should_enable_service() {
    local service="$1"
    local line
    
    # Find service in configuration table
    line=$(echo "$SERVICE_CONFIG" | grep "^${service}|" || true)
    
    if [ -z "$line" ]; then
        # Unconfigured services are enabled by default
        return 0
    fi
    
    # Parse configuration: service name|development environment|production environment
    local dev_enabled prod_enabled
    dev_enabled=$(echo "$line" | cut -d'|' -f2)
    prod_enabled=$(echo "$line" | cut -d'|' -f3)
    
    # Return corresponding enabled status based on current environment
    if [ "$DEVBOX_ENV" = "production" ]; then
        [ "$prod_enabled" = "1" ]
    else
        [ "$dev_enabled" = "1" ]
    fi
}

# Function to disable service (remove from user bundle AND service definition BEFORE compilation)
disable_service() {
    local service="$1"
    local target="$S6_DIR/user/contents.d/$service"
    local service_dir="$S6_DIR/$service"
    
    # Remove from user bundle
    if [ -f "$target" ]; then
        echo "[pre-rc-init] Disabling: $service (removing from bundle)"
        rm -f "$target"
    fi
    
    # Also remove the service definition directory
    # This ensures s6-rc-compile won't see this service at all
    # and /run/service/<service> won't be created
    if [ -d "$service_dir" ]; then
        echo "[pre-rc-init] Removing service definition: $service"
        rm -rf "$service_dir"
    fi
}

# Function to enable service (ensure it's in user bundle)
enable_service() {
    local service="$1"
    local target="$S6_DIR/user/contents.d/$service"
    
    if [ -d "$S6_DIR/$service" ] && [ ! -f "$target" ]; then
        echo "[pre-rc-init] Enabling: $service"
        touch "$target"
    fi
}

# Process all services in configuration
echo "$SERVICE_CONFIG" | while IFS='|' read -r service dev prod; do
    # Trim whitespace from service name and skip empty/whitespace-only lines
    service=$(echo "$service" | xargs)
    [ -z "$service" ] && continue
    
    if should_enable_service "$service"; then
        enable_service "$service"
    else
        disable_service "$service"
    fi
done

echo "[pre-rc-init] ========================================"
echo "[pre-rc-init] Pre-RC initialization completed"
echo "[pre-rc-init] Services will be compiled without disabled ones"
echo "[pre-rc-init] ========================================"