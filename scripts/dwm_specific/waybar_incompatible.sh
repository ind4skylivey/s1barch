#!/bin/bash
# ============================================================
#  WAYBAR INCOMPATIBLE - Scripts that DON'T run on Waybar
#  This script should be sourced by other scripts to check environment
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

ENV_FILE="$S1B_ROOT/config/current_env.yaml"

is_waybar() {
    if [ ! -f "$ENV_FILE" ]; then
        source "$SCRIPT_DIR/../detection/detect_env.sh" && main desktop >/dev/null 2>&1 || true
        return 0
    fi
    
    local current_env
    current_env=$(cat "$ENV_FILE" | grep "^current:" | cut -d: -f2 | tr -d ' ')
    [ "$current_env" = "waybar" ]
}

# Block execution if Waybar is active
block_on_waybar() {
    if is_waybar; then
        log_error "This script is not compatible with Waybar environment"
        log_info "Detected environment: waybar"
        log_warn "Use wayland_specific/ scripts instead"
        exit 1
    fi
}

# Warning for Waybar environment
warn_on_waybar() {
    if is_waybar; then
        log_warn "This script may not work correctly on Waybar environment"
        log_info "Detected environment: waybar"
    fi
}

# Export functions
export -f is_waybar
export -f block_on_waybar
export -f warn_on_waybar
