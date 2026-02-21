#!/bin/bash
# ============================================================
#  BRIGHTNESS SLIDER - Adjust screen brightness
#  Dependencies: brightnessctl (recommended) or xbacklight
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check for brightness control tool
if command -v brightnessctl &>/dev/null; then
    BRIGHTNESS_CMD="brightnessctl"
elif command -v xbacklight &>/dev/null; then
    BRIGHTNESS_CMD="xbacklight"
else
    log_error "No brightness control tool found"
    log_info "Install one of: brightnessctl (recommended) or xbacklight"
    exit 1
fi

log_info "Using: $BRIGHTNESS_CMD"

# Get current brightness
get_brightness() {
    case "$BRIGHTNESS_CMD" in
        "brightnessctl")
            brightnessctl get | tr -d '%'
            ;;
        "xbacklight")
            xbacklight -get | cut -d. -f1
            ;;
    esac
}

# Set brightness
set_brightness() {
    local value="$1"
    
    log_info "Setting brightness to ${value}%"
    
    case "$BRIGHTNESS_CMD" in
        "brightnessctl")
            brightnessctl set "${value}%"
            ;;
        "xbacklight")
            xbacklight -set "$value"
            ;;
    esac
    
    log_success "Brightness set to ${value}%"
}

# Increase brightness
increase_brightness() {
    local step="${1:-10}"
    
    log_info "Increasing brightness by ${step}%"
    
    case "$BRIGHTNESS_CMD" in
        "brightnessctl")
            brightnessctl set "+${step}%"
            ;;
        "xbacklight")
            xbacklight -inc "$step"
            ;;
    esac
    
    log_success "Brightness: $(get_brightness)%"
}

# Decrease brightness
decrease_brightness() {
    local step="${1:-10}"
    
    log_info "Decreasing brightness by ${step}%"
    
    case "$BRIGHTNESS_CMD" in
        "brightnessctl")
            brightnessctl set "${step}%-"
            ;;
        "xbacklight")
            xbacklight -dec "$step"
            ;;
    esac
    
    log_success "Brightness: $(get_brightness)%"
}

# Show brightness menu (for Rofi/dmenu)
show_menu() {
    # shellcheck disable=SC2155
    local options="Current: $(get_brightness)%
Increase (+10%)
Decrease (-10%)
Set to 100%
Set to 75%
Set to 50%
Set to 25%
Set to 10%"
    
    local choice
    choice=$(echo "$options" | rofi -dmenu -p "Brightness:" -theme "$HOME/.config/rofi/cyberpunk" 2>/dev/null || echo "")
    
    case "$choice" in
        "Increase (+10%)")
            increase_brightness 10
            ;;
        "Decrease (-10%)")
            decrease_brightness 10
            ;;
        "Set to 100%")
            set_brightness 100
            ;;
        "Set to 75%")
            set_brightness 75
            ;;
        "Set to 50%")
            set_brightness 50
            ;;
        "Set to 25%")
            set_brightness 25
            ;;
        "Set to 10%")
            set_brightness 10
            ;;
        *)
            log_info "No action taken"
            ;;
    esac
}

# Main
log_section "Brightness Control"

case "${1:-get}" in
    "get")
        log_info "Current brightness: $(get_brightness)%"
        ;;
    "set")
        if [ -z "${2:-}" ]; then
            log_error "Please specify brightness value (0-100)"
            echo "Usage: $0 set <value>"
            exit 1
        fi
        set_brightness "$2"
        ;;
    "up"|"inc"|"increase")
        increase_brightness "${2:-10}"
        ;;
    "down"|"dec"|"decrease")
        decrease_brightness "${2:-10}"
        ;;
    "menu")
        show_menu
        ;;
    *)
        echo "Usage: $0 [get|set <value>|up [step]|down [step]|menu]"
        exit 1
        ;;
esac
