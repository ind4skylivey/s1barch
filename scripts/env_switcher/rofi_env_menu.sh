#!/bin/bash
# ============================================================
#  ROFI ENV MENU - Rofi menu for environment switching
#  Usage: bash ~/Desktop/S1Bs1stem/scripts/env_switcher/rofi_env_menu.sh
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Options
declare -a OPTIONS=(
    "🪟 Switch to DWM (X11)"
    "🌊 Switch to Waybar (Wayland)"
    "🔄 Auto-detect & Switch"
    "❌ Cancel"
)

# Execute action
execute_switch() {
    local action="$1"
    
    case "$action" in
        dwm|x11)
            bash "$SCRIPT_DIR/to_dwm.sh"
            ;;
        waybar|wayland)
            bash "$SCRIPT_DIR/to_wayland.sh"
            ;;
        auto)
            bash "$SCRIPT_DIR/auto_switch.sh"
            ;;
        cancel)
            log_info "Cancelled by user"
            exit 0
            ;;
        *)
            log_error "Invalid action: $action"
            exit 1
            ;;
    esac
}

# Show Rofi menu
show_menu() {
    local selected
    selected=$(printf '%s\n' "${OPTIONS[@]}" | rofi -dmenu -p "Select Environment:" -i -theme "catppuccin-mocha")
    
    if [ -n "$selected" ]; then
        local action
        action=$(echo "$selected" | awk '{print $2}')
        execute_switch "$action"
    else
        log_info "No selection made"
    fi
}

# Main
main() {
    local action="${1:-menu}"
    
    case "$action" in
        menu|rofi)
            show_menu
            ;;
        dwm|x11)
            execute_switch "dwm"
            ;;
        waybar|wayland)
            execute_switch "waybar"
            ;;
        auto|detect)
            execute_switch "auto"
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [menu|dwm|waybar|auto]"
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
