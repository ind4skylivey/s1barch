#!/bin/bash
# ============================================================
#  WALLPAPER CYCLE - Cycle through wallpapers
#  Dependencies: swww, notify-send (optional)
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

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
    tail -100 "$HISTORY_FILE" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
}

# Get current wallpaper
get_current() {
    if command -v swww &>/dev/null; then
        swww query | head -1 | awk '{print $1}'
    elif command -v hyprctl &>/dev/null; then
        hyprctl hyprpaper listloaded | head -1 | awk '{print $1}'
    elif command -v feh &>/dev/null; then
        pgrep -a feh | grep -o '[^ ]*\.\(jpg\|png\|jpeg\)' | head -1
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
    
    if command -v swww &>/dev/null; then
        swww img "$wallpaper" --transition-type random --transition-step 100
    elif command -v hyprctl &>/dev/null; then
        killall hyprpaper
        hyprctl hyprpaper preload "$wallpaper"
        hyprctl hyprpaper wallpaper "eDP-1,$wallpaper"
    elif command -v feh &>/dev/null; then
        feh --bg-"$mode" "$wallpaper"
    else
        log_error "No wallpaper manager found (swww/hyprpaper/feh)"
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

# Main logic
main() {
    local action="${1:-next}"
    local wallpaper="$2"
    
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
        current|get)
            local current
            current=$(get_current)
            echo "Current wallpaper: $current"
            log_info "Current wallpaper: $(basename "$current")"
            ;;
        list|ls)
            get_wallpapers | while read -r wp; do
                echo "  $(basename "$wp")"
            done
            ;;
        history)
            if [ -f "$HISTORY_FILE" ]; then
                tail -20 "$HISTORY_FILE" | while read -r wp; do
                    echo "  $(basename "$wp")"
                done
            else
                log_info "No wallpaper history found"
            fi
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [next|prev|random|set|current|list|history] [wallpaper]"
            exit 1
            ;;
    esac
}

main "$@"
