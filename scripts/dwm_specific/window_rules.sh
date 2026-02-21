#!/bin/bash
# ============================================================
#  DWM WINDOW RULES - Apply window rules to specific applications
#  Dependencies: xdotool, wmctrl
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

# Window rules configuration
apply_rule() {
    local window_class="$1"
    local action="$2"
    
    log_info "Applying rule: $window_class -> $action"
    
    case "$action" in
        "float")
            # Find windows by class and make them floating
            for wid in $(xdotool search --class "$window_class" 2>/dev/null); do
                xdotool windowactivate "$wid"
                xdotool key super+shift+space
                log_info "Made window $wid floating"
            done
            ;;
        "tag")
            local tag="${3:-1}"
            for wid in $(xdotool search --class "$window_class" 2>/dev/null); do
                # Move to specific tag
                xdotool windowactivate "$wid"
                xdotool key super+shift+$tag
                log_info "Moved window $wid to tag $tag"
            done
            ;;
        "center")
            for wid in $(xdotool search --class "$window_class" 2>/dev/null); do
                # Center window on screen
                local screen_w screen_h win_w win_h new_x new_y
                screen_w=$(xdotool getdisplaygeometry | cut -d' ' -f1)
                screen_h=$(xdotool getdisplaygeometry | cut -d' ' -f2)
                win_w=$(xdotool getwindowgeometry "$wid" | grep Geometry | cut -d' ' -f2 | cut -d'x' -f1)
                win_h=$(xdotool getwindowgeometry "$wid" | grep Geometry | cut -d' ' -f2 | cut -d'x' -f2)
                new_x=$(( (screen_w - win_w) / 2 ))
                new_y=$(( (screen_h - win_h) / 2 ))
                xdotool windowmove "$wid" "$new_x" "$new_y"
                log_info "Centered window $wid"
            done
            ;;
        *)
            log_warn "Unknown action: $action"
            ;;
    esac
}

# Apply all default rules
apply_default_rules() {
    log_section "Applying DWM Window Rules"
    
    # Float dialogs and popups
    apply_rule "dialog" "float"
    apply_rule "popup" "float"
    
    # Float specific applications
    apply_rule "pavucontrol" "float"
    apply_rule "blueman-manager" "float"
    apply_rule "nm-connection-editor" "float"
    
    # Center some applications
    apply_rule "rofi" "center"
    
    log_success "Window rules applied"
}

# Main execution
case "${1:-apply}" in
    "apply")
        apply_default_rules
        ;;
    "rule")
        if [ $# -lt 3 ]; then
            echo "Usage: $0 rule <window_class> <action> [tag]"
            exit 1
        fi
        apply_rule "$2" "$3" "${4:-}"
        ;;
    "list")
        log_info "Active window rules:"
        echo "  - dialog: float"
        echo "  - popup: float"
        echo "  - pavucontrol: float"
        echo "  - blueman-manager: float"
        echo "  - nm-connection-editor: float"
        echo "  - rofi: center"
        ;;
    *)
        echo "Usage: $0 [apply|rule <class> <action>|list]"
        exit 1
        ;;
esac
