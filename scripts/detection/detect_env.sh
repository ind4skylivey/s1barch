#!/bin/bash
# ============================================================
#  DETECT ENV - Detect active desktop environment
#  Usage: source ~/Desktop/S1Bs1stem/scripts/detection/detect_env.sh
#  Output: "desktop:display_server" (e.g., "dwm:x11")
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Detect desktop environment
detect_desktop() {
    # Check DWM (X11)
    if pgrep -x "dwm" &>/dev/null; then
        echo "dwm"
        return 0
    fi
    
    # Check Hyprland (Wayland)
    if pgrep -x "hyprland" &>/dev/null; then
        echo "hyprland"
        return 0
    fi
    
    # Check Waybar (KDE/Wayland)
    if pgrep -x "waybar" &>/dev/null; then
        echo "waybar"
        return 0
    fi
    
    # Check Gnome
    if pgrep -x "gnome-shell" &>/dev/null; then
        echo "gnome"
        return 0
    fi
    
    echo "unknown"
    return 1
}

# Detect display server
detect_display_server() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo "wayland"
        return 0
    elif [ -n "$DISPLAY" ]; then
        echo "x11"
        return 0
    else
        echo "unknown"
        return 1
    fi
}

# Get full environment info
get_env_info() {
    local desktop
    local display_server
    local compositor
    
    desktop=$(detect_desktop)
    display_server=$(detect_display_server)
    
    # Detect compositor
    if [ "$desktop" = "hyprland" ]; then
        compositor="hyprland"
    elif [ "$desktop" = "waybar" ]; then
        if pgrep -x "kwin" &>/dev/null; then
            compositor="kwin"
        else
            compositor="none"
        fi
    elif [ "$desktop" = "dwm" ]; then
        if command -v picom &>/dev/null && pgrep -x "picom" &>/dev/null; then
            compositor="picom"
        else
            compositor="none"
        fi
    else
        compositor="unknown"
    fi
    
    # Output format: desktop:display_server:compositor
    echo "${desktop}:${display_server}:${compositor}"
}

# Main function
main() {
    local action="${1:-info}"
    
    case "$action" in
        desktop|wm)
            detect_desktop
            ;;
        display|ds)
            detect_display_server
            ;;
        compositor|cmp)
            get_env_info | cut -d: -f3
            ;;
        info|get|env|all)
            get_env_info
            ;;
        json)
            local env_info
            env_info=$(get_env_info)
            local desktop display_server compositor
            IFS=':' read -r desktop display_server compositor <<< "$env_info"
            echo "{\"desktop\":\"$desktop\",\"display_server\":\"$display_server\",\"compositor\":\"$compositor\"}"
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [desktop|display|compositor|info|json]"
            exit 1
            ;;
    esac
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Export functions for sourcing
export -f detect_desktop
export -f detect_display_server
export -f get_env_info
export -f main
