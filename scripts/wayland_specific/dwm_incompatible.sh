#!/bin/bash
# ============================================================
#  DWM INCOMPATIBLE - Scripts that DON'T work with DWM
#  Placeholder to prevent accidental execution
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

ENV_FILE="$HOME/Desktop/S1Bs1stem/config/current_env.yaml"
CURRENT_ENV=$(grep "^current:" "$ENV_FILE" 2>/dev/null | cut -d: -f2)
readonly CURRENT_ENV

if [ "$CURRENT_ENV" = "dwm" ]; then
    log_error "ERROR: This script is not compatible with DWM environment"
    log_warn "DWM detected, but this script requires Wayland/Waybar"
    log_info "Use dwm_specific scripts instead"
    exit 1
fi

# Exit with error for Waybar-incompatible scripts
log_error "This script is Waybar-incompatible"
exit 1
