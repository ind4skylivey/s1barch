#!/bin/bash
# ============================================================
#  DWM WINDOW RULES - Apply window rules for applications
#  Dependencies: xdotool, wmctrl, xprop
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check if DWM is running
if ! check_dwm_running; then
    log_error "DWM is not running"
    log_info "This script requires a running DWM session"
    exit 1
fi

# Configuration
readonly RULES_FILE="$HOME/.config/dwm/window_rules.conf"
readonly RULES_DIR="$HOME/.config/dwm/rules.d"

# Ensure directories exist
ensure_dir_exists "$RULES_DIR"

# Window rule structure:
# RULES[<class_name>]=<action>:<parameters>

# Default rules (can be overridden by user)
declare -A DEFAULT_RULES
DEFAULT_RULES["mpv"]="floating"
DEFAULT_RULES["ffmpeg"]="floating"
DEFAULT_RULES["pavucontrol"]="floating"
DEFAULT_RULES["blueman-manager"]="floating"
DEFAULT_RULES["nm-connection-editor"]="floating"
DEFAULT_RULES["steam"]="floating"
DEFAULT_RULES["discord"]="floating"
DEFAULT_RULES["slack"]="floating"
DEFAULT_RULES["zoom"]="floating"
DEFAULT_RULES["obs"]="floating"
DEFAULT_RULES["gimp"]="floating"
DEFAULT_RULES["inkscape"]="floating"
DEFAULT_RULES["vlc"]="floating"

# Load user rules
load_rules() {
    local rules_file="${1:-$RULES_FILE}"

    if [ -f "$rules_file" ]; then
        log_info "Loading rules from: $rules_file"
        # Source rules file
        # shellcheck source=/dev/null
        source "$rules_file"
    else
        log_info "No user rules file found, using defaults"
    fi

    # Load rules from rules.d directory
    if [ -d "$RULES_DIR" ]; then
        log_info "Loading rules from: $RULES_DIR"
        for rule_file in "$RULES_DIR"/*.conf; do
            if [ -f "$rule_file" ]; then
                log_debug "Loading: $rule_file"
                # shellcheck source=/dev/null
                source "$rule_file"
            fi
        done
    fi
}

# Apply rule to current window
apply_rule() {
    local window_class="$1"
    local action="$2"
    local params="${3:-}"

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        log_info "Install: sudo pacman -S xdotool"
        return 1
    fi

    log_info "Applying rule: $window_class -> $action"

    case "$action" in
        floating|float)
            toggle_floating
            ;;
        tag)
            if [ -n "$params" ]; then
                move_window_to_tag "$params"
            fi
            ;;
        fullscreen|fs)
            toggle_fullscreen
            ;;
        center)
            center_window
            ;;
        size)
            set_window_size "$params"
            ;;
        position)
            set_window_position "$params"
            ;;
        *)
            log_warn "Unknown action: $action"
            return 1
            ;;
    esac

    log_success "Rule applied: $window_class -> $action"
}

# Toggle floating
toggle_floating() {
    xdotool key --window "$(xdotool getactivewindow)" Super+Shift+space
}

# Move window to tag
move_window_to_tag() {
    local tag="$1"
    if [ "$tag" -ge 1 ] && [ "$tag" -le 9 ]; then
        xdotool key --window "$(xdotool getactivewindow)" Super+Shift+$tag
    fi
}

# Toggle fullscreen
toggle_fullscreen() {
    xdotool key --window "$(xdotool getactivewindow)" Super+f
}

# Center window
center_window() {
    log_debug "Centering window"
    # This requires xdotool geometry calculations
    # For now, just toggle floating
    toggle_floating
}

# Set window size
set_window_size() {
    local size="$1"  # Format: WIDTHxHEIGHT
    local width height
    width=$(echo "$size" | cut -d'x' -f1)
    height=$(echo "$size" | cut -d'x' -f2)

    if [ -n "$width" ] && [ -n "$height" ]; then
        log_debug "Setting window size: ${width}x${height}"
        # Use wmctrl to resize
        if command -v wmctrl &>/dev/null; then
            wmctrl -r :ACTIVE: -e 0,0,0,"$width","$height"
        fi
    fi
}

# Set window position
set_window_position() {
    local position="$1"  # Format: X,Y
    local x y
    x=$(echo "$position" | cut -d',' -f1)
    y=$(echo "$position" | cut -d',' -f2)

    if [ -n "$x" ] && [ -n "$y" ]; then
        log_debug "Setting window position: ${x},${y}"
        if command -v wmctrl &>/dev/null; then
            # Get current window geometry
            local window_id
            window_id=$(xdotool getactivewindow)
            local geometry
            geometry=$(xdotool getwindowgeometry "$window_id" | grep Geometry)
            local width height
            width=$(echo "$geometry" | grep -oP '\d+(?=x\d+)')
            height=$(echo "$geometry" | grep -oP '(?<=x)\d+')
            wmctrl -i -r "$window_id" -e 0,"$x","$y","$width","$height"
        fi
    fi
}

# Get window class
get_window_class() {
    local window_id="$1"

    if [ -z "$window_id" ]; then
        window_id=$(xdotool getactivewindow)
    fi

    if command -v xprop &>/dev/null; then
        xprop -id "$window_id" WM_CLASS 2>/dev/null | grep -oP '"[^"]+"$' | tr -d '"'
    else
        echo "unknown"
    fi
}

# Apply rules to current window
apply_to_current() {
    local window_id
    window_id=$(xdotool getactivewindow)

    if [ -z "$window_id" ]; then
        log_error "No active window found"
        return 1
    fi

    local window_class
    window_class=$(get_window_class "$window_id")

    log_info "Active window class: $window_class"

    # Check if rule exists
    if [ -n "${RULES[$window_class]:-}" ]; then
        local rule_action
        local rule_params
        rule_action=$(echo "${RULES[$window_class]}" | cut -d':' -f1)
        rule_params=$(echo "${RULES[$window_class]}" | cut -d':' -f2- -s)

        apply_rule "$window_class" "$rule_action" "$rule_params"
    elif [ -n "${DEFAULT_RULES[$window_class]:-}" ]; then
        local rule_action
        local rule_params
        rule_action="${DEFAULT_RULES[$window_class]}"
        rule_params=""

        apply_rule "$window_class" "$rule_action" "$rule_params"
    else
        log_debug "No rule found for: $window_class"
    fi
}

# List all rules
list_rules() {
    echo ""
    echo -e "${COLOR_BOLD}Window Rules${COLOR_RESET}"
    echo "═════════════════════════════════"
    echo ""

    echo -e "${COLOR_MAuve}Default Rules:${COLOR_RESET}"
    for class in "${!DEFAULT_RULES[@]}"; do
        echo "  ${COLOR_TEXT}${class}${COLOR_RESET} -> ${COLOR_GREEN}${DEFAULT_RULES[$class]}${COLOR_RESET}"
    done

    echo ""
    echo -e "${COLOR_MAuve}User Rules (${RULES_FILE}):${COLOR_RESET}"
    if [ -f "$RULES_FILE" ]; then
        grep -v '^#' "$RULES_FILE" | grep '=' | while read -r line; do
            echo "  $line"
        done
    else
        echo "  (none)"
    fi

    echo ""
}

# Generate sample rules file
generate_sample_rules() {
    log_info "Generating sample rules file..."

    cat > "$RULES_FILE" << 'EOF'
# DWM Window Rules Configuration
# Format: RULES["class_name"]="action:parameters"
#
# Actions:
#   floating    - Make window floating
#   tag:N       - Move window to tag N (1-9)
#   fullscreen  - Make window fullscreen
#   center      - Center window
#   size:WxH    - Set window size (WIDTHxHEIGHT)
#   position:X,Y - Set window position

# Example user rules
# RULES["firefox"]="tag:1"
# RULES["discord"]="tag:2:float"
# RULES["terminal"]=""

# To disable a default rule, add it with empty action
# RULES["mpv"]=""
EOF

    log_success "Sample rules created: $RULES_FILE"
}

# Main function
main() {
    local action="${1:-apply}"

    case "$action" in
        apply|a)
            load_rules
            apply_to_current
            ;;
        list|ls)
            load_rules
            list_rules
            ;;
        generate|gen|sample)
            generate_sample_rules
            ;;
        reload)
            load_rules
            log_success "Rules reloaded"
            ;;
        *)
            log_error "Invalid action: $action"
            echo ""
            echo "Usage: $0 <action>"
            echo ""
            echo "Actions:"
            echo "  apply       Apply rules to current window"
            echo "  list        List all rules"
            echo "  generate    Generate sample rules file"
            echo "  reload      Reload rules from files"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"

log_success "DWM window rules ready"
