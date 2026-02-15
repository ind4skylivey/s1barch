#!/bin/bash
# ============================================================
#  DWM TOGGLE FLOATING - Toggle floating mode for current window
#  Dependencies: xdotool, dwm
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check if we're in DWM environment
if ! check_dwm_running; then
    log_error "DWM is not running"
    exit 1
fi

# Toggle floating mode using xdotool
log_info "Toggling floating mode for active window..."

# Get active window ID
active_window=$(xdotool getactivewindow 2>/dev/null || echo "")

if [ -z "$active_window" ]; then
    log_error "No active window found"
    exit 1
fi

# Toggle floating using xdotool key (Mod+Shift+Space in DWM)
# This depends on your DWM keybindings
xdotool key super+shift+space

log_success "Floating mode toggled"
