#!/bin/bash
# ============================================================
#  DISPLAY WAYLAND - Display management for Wayland/Waybar
# Uses: wwww, swayosd-client (optional), hyprpaper (optional)
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check environment
ENV_FILE="$HOME/Desktop/S1Bs1stem/config/current_env.yaml"
CURRENT_ENV=$(grep "^current:" "$ENV_FILE" 2>/dev/null | cut -d: -f2)
readonly CURRENT_ENV

if [ "$CURRENT_ENV" != "wayland" ] && [ "$CURRENT_ENV" != "waybar" ]; then
    log_error "This script requires Wayland/Waybar environment"
    log_info "Current environment: $CURRENT_ENV"
    exit 1
fi

# Configuration
readonly WALLPAPER_DIR="$HOME/Pictures/wallpapers"
readonly HISTORY_FILE="$HOME/.s1b_wallpaper_history"

# Get all wallpapers
get_wallpapers() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        log_error "Wallpaper directory not found: $WALLPAPER_DIR"
        exit 1
    fi
    
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort
}

# Load history
load_history() {
    if [ -f "$HISTORY_FILE" ]; then
        cat "$HISTORY_FILE"
    fi
}

# Save to history
save_history() {
    local wallpaper="$1"
    echo "$wallpaper" >> "$HISTORY_FILE"
    # Keep only last 100 entries
    tail -100 "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
    mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
}

# Get current wallpaper
get_current() {
    # Try wwww
    if command -v wwww &>/dev/null; then
        wwww query | head -1 | awk '{print $1}'
    # Try hyprpaper
    elif command -v hyprpaper &>/dev/null; then
        hyprpaper hyprpaper listloaded | head -1 | awk '{print $2}'
    # Fallback
    else
        echo "unknown"
    fi
}

# Set wallpaper
set_wallpaper() {
    local wallpaper="$1"
    local mode="${2:-fill}"
    
    if [ ! -f "$wallpaper" ]; then
        log_error "Wallpaper not found: $wallpaper"
        exit 1
    fi
    
    log_info "Setting wallpaper: $(basename "$wallpaper")"
    
    # Use wwww (Wayfire paper) for Wayland
    if command -v wwww &>/dev/null; then
        wwww img "$wallpaper" --transition-type random --transition-step 100
    # Hyprpaper alternative
    elif command -v hyprpaper &>/dev/null; then
        killall hyprpaper
        hyprpaper hyprpaper preload "$wallpaper"
        for monitor in $(hyprpaper hyprpaper list monitors | jq -r '.[].monitor_name' | sort); do
            hyprpaper hyprpaper wallpaper "$monitor" "$wallpaper"
        done
    elif command -v feh &>/dev/null; then
        feh --bg-"$mode" "$wallpaper"
    else
        log_error "No wallpaper manager found (wwww/hyprpaper/feh)"
        exit 1
    fi
    
    save_history "$wallpaper"
    log_success "Wallpaper set"
}

# Cycle wallpapers
cycle_wallpapers() {
    local direction="$1"
    
    local wallpapers current
    wallpapers=$(get_wallpapers)
    current=$(get_current)
    
    if [ -z "$wallpapers" ]; then
        log_error "No wallpapers found"
        exit 1
    fi
    
    # Convert to array
    local wallpaper_array
    mapfile -t wallpaper_array <<< "$wallpapers"
    
    local current_index=-1
    local i=0
    for wp in "${wallpaper_array[@]}"; do
        if [ "$(basename "$wp")" = "$(basename "$current")" ]; then
            current_index=$i
            break
        fi
        ((i++))
    done
    
    # Calculate next index
    local next_index
    case "$direction" in
        next|forward)
            next_index=$(( (current_index + 1) % ${#wallpaper_array[@]} ))
            ;;
        prev|back)
            next_index=$(( (current_index - 1 + ${#wallpaper_array[@]}) % ${#wallpaper_array[@]} ))
            ;;
        random|rand)
            next_index=$(( RANDOM % ${#wallpaper_array[@]} ))
            ;;
        *)
            log_error "Invalid direction: $direction"
            exit 1
            ;;
    esac
    
    set_wallpaper "${wallpaper_array[$next_index]}"
}

# Brightness management (using wwww for Wayland)
set_brightness() {
    local brightness="$1"
    
    # Clamp brightness
    if [ "$brightness" -gt 100 ]; then
        brightness=100
    fi
    if [ "$brightness" -lt 1 ]; then
        brightness=1
    fi
    
    if command -v wwww &>/dev/null; then
        wwww brightness "$brightness"%
        log_success "Brightness set to ${brightness}%"
    elif command -v light &>/dev/null; then
        light -S "$brightness"%
        log_success "Brightness set to ${brightness}%"
    else
        log_warn "No brightness controller found (wwww/light)"
    fi
    
    # Show notification
    if command -v swayosd-client &>/dev/null; then
        swayosd-client --custom-message "Brightness: ${brightness}%" --custom-icon "display-brightness" &>/dev/null || true
    fi
}

# Main logic
main() {
    local action="${1:-next}"
    local wallpaper="$2"
    local brightness="$3"
    
    case "$action" in
        next|forward|prev|back|random|rand)
            cycle_wallpapers "$action"
            ;;
        set|select)
            if [ -z "$wallpaper" ]; then
                log_error "Usage: $0 set <wallpaper_path>"
                exit 1
            fi
            set_wallpaper "$wallpaper"
            ;;
        get|current|info)
            get_current
            echo "Current wallpaper: $(basename "$(get_current)")"
            log_info "Current wallpaper: $(basename "$(get_current)")"
            ;;
        history|ls)
            if [ -f "$HISTORY_FILE" ]; then
                tail -20 "$HISTORY_FILE"
            else
                log_info "No wallpaper history found"
            fi
            ;;
        brightness|bright)
            if [ -n "$brightness" ]; then
                set_brightness "$brightness"
            else
                log_error "Brightness level required"
                echo "Usage: $0 brightness <level>"
                exit 1
            fi
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [next|prev|random|set|get|history|brightness] [wallpaper] [brightness]"
            exit 1
            ;;
    esac
}

main "$@"
