#!/bin/bash
# ============================================================
#  DWM AUTOSTART - Autostart applications for DWM
#  Dependencies: dwm
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

log_section "DWM Autostart"

# Function to start application if not already running
start_if_not_running() {
    local app_name="$1"
    local cmd="$2"
    
    if pgrep -x "$app_name" > /dev/null 2>&1; then
        log_info "$app_name is already running"
    else
        log_info "Starting $app_name..."
        eval "$cmd" &
        log_success "$app_name started"
    fi
}

# Autostart core DWM components
log_subsection "Core Components"

# Start compositor (picom) for transparency and effects
start_if_not_running "picom" "picom --config ~/.config/picom/picom.conf"

# Start notification daemon (dunst)
start_if_not_running "dunst" "dunst"

# Start polkit agent
start_if_not_running "polkit-gnome" "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"

# Start clipboard manager
start_if_not_running "clipmenud" "clipmenud"

# Autostart user applications
log_subsection "User Applications"

# Network manager applet
start_if_not_running "nm-applet" "nm-applet"

# Bluetooth applet (if available)
if command -v blueman-applet &>/dev/null; then
    start_if_not_running "blueman-applet" "blueman-applet"
fi

# Volume control applet
start_if_not_running "volumeicon" "volumeicon"

# Set wallpaper using feh
if [ -f ~/.config/dwm/wallpaper.sh ]; then
    log_info "Setting wallpaper..."
    bash ~/.config/dwm/wallpaper.sh &
fi

# Apply window rules
log_subsection "Applying Window Rules"
"$SCRIPT_DIR/window_rules.sh" apply

log_success "DWM autostart completed"
