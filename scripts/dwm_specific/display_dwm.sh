#!/bin/bash
# ============================================================
#  DISPLAY DWM - Display management for DWM
# Uses: feh, xdotool, xrandr
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check environment
ENV_FILE="$S1B_ROOT/config/current_env.yaml"
CURRENT_ENV=$(cat "$ENV_FILE" 2>/dev/null | grep "^current:" | cut -d: -f2 | tr -d ' ')
readonly CURRENT_ENV

if [ "$CURRENT_ENV" != "dwm" ]; then
    log_error "This script requires DWM (X11) environment"
    log_warn "Detected environment: $CURRENT_ENV"
    exit 1
fi

# Wallpaper management with feh
set_wallpaper() {
    local wallpaper="$1"
    
    if [ ! -f "$wallpaper" ]; then
        log_error "Wallpaper not found: $wallpaper"
        return 1
    fi
    
    log_info "Setting wallpaper: $(basename "$wallpaper")"
    feh --bg-scale --no-xinerama "$wallpaper"
    log_success "Wallpaper set"
}

cycle_wallpaper() {
    local WALLPAPER_DIR="$HOME/Pictures/wallpapers"
    
    if [ ! -d "$WALLPAPER_DIR" ]; then
        log_error "Wallpaper directory not found: $WALLPAPER_DIR"
        exit 1
    fi
    
    # Get current wallpaper
    local current_wp
    current_wp=$(feh --bg-scale --no-xinerama --list 2>/dev/null | tail -1)
    
    # Get all wallpapers
    local wallpapers
    mapfile -t wallpapers <<< "$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort)"
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        log_error "No wallpapers found"
        exit 1
    fi
    
    # Find current index
    local current_idx=-1
    for i in "${!wallpapers[@]}"; do
        if [ "${wallpapers[$i]}" = "$current_wp" ]; then
            current_idx=$i
            break
        fi
    done
    
    # Calculate next index
    local next_idx=$(((current_idx + 1) % ${#wallpapers[@]}))
    
    # Set next wallpaper
    local next_wp="${wallpapers[$next_idx]}"
    set_wallpaper "$next_wp"
}

# Brightness management
set_brightness() {
    local action="$1"
    local step="${2:-5}"
    
    # Check xbacklight
    if ! command -v xbacklight &>/dev/null; then
        log_error "xbacklight not found"
        log_info "Install: sudo pacman -S xorg-xbacklight"
        exit 1
    fi
    
    case "$action" in
        up|increase|+)
            xbacklight -inc "$step"
            ;;
        down|decrease|-)
            xbacklight -dec "$step"
            ;;
        toggle)
            local current
            current=$(xbacklight -get)
            if [ "$current" -gt 0 ]; then
                xbacklight -set 0
                log_info "Brightness: Off"
            else
                xbacklight -set 100
                log_info "Brightness: 100%"
            fi
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [up|down|toggle] [step]"
            exit 1
            ;;
    esac
    
    local new_brightness
    new_brightness=$(xbacklight -get)
    log_success "Brightness: ${new_brightness}%"
}

# Main function
main() {
    local action="${1:-cycle}"
    local param="$2"
    
    case "$action" in
        wallpaper|wp)
            if [ -z "$param" ]; then
                cycle_wallpaper
            else
                set_wallpaper "$param"
            fi
            ;;
        brightness|bright|br)
            if [ -z "$param" ]; then
                set_brightness up
            else
                set_brightness "$param" "$param"
            fi
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [wallpaper|brightness]"
            exit 1
            ;;
    esac
}
