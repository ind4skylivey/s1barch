#!/bin/bash
# ============================================================
#  DWM WINDOW MANAGEMENT - Window manipulation utilities for DWM
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

# Toggle window floating state
toggle_floating() {
    log_info "Toggling window floating state..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        log_info "Install: sudo pacman -S xdotool"
        exit 1
    fi

    # Send DWM floating toggle (usually Super+Shift+Space)
    xdotool key --window "$(xdotool getactivewindow)" Super+Shift+space

    log_success "Window floating state toggled"
    notify-send "DWM" "Toggled floating state" 2>/dev/null || true
}

# Toggle window fullscreen
toggle_fullscreen() {
    log_info "Toggling window fullscreen..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        log_info "Install: sudo pacman -S xdotool"
        exit 1
    fi

    # Send DWM fullscreen toggle (usually Super+f)
    xdotool key --window "$(xdotool getactivewindow)" Super+f

    log_success "Window fullscreen toggled"
    notify-send "DWM" "Toggled fullscreen" 2>/dev/null || true
}

# Move window to next tag
move_to_tag() {
    local tag="$1"

    if [ -z "$tag" ] || [ "$tag" -lt 1 ] || [ "$tag" -gt 9 ]; then
        log_error "Invalid tag: $tag (must be 1-9)"
        echo "Usage: $0 move-to-tag <1-9>"
        exit 1
    fi

    log_info "Moving window to tag $tag..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    # Send DWM move to tag (usually Super+Shift+<tag number>)
    xdotool key --window "$(xdotool getactivewindow)" Super+Shift+$tag

    log_success "Window moved to tag $tag"
}

# Switch to tag
switch_tag() {
    local tag="$1"

    if [ -z "$tag" ] || [ "$tag" -lt 1 ] || [ "$tag" -gt 9 ]; then
        log_error "Invalid tag: $tag (must be 1-9)"
        echo "Usage: $0 switch-tag <1-9>"
        exit 1
    fi

    log_info "Switching to tag $tag..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    # Send DWM tag switch (usually Super+<tag number>)
    xdotool key Super+$tag

    log_success "Switched to tag $tag"
}

# Kill focused window
kill_window() {
    log_info "Killing focused window..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    # Send DWM kill window (usually Super+Shift+c)
    xdotool key --window "$(xdotool getactivewindow)" Super+Shift+c

    log_success "Window killed"
}

# Focus next window
focus_next() {
    log_info "Focusing next window..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    # Send DWM focus next (usually Super+j)
    xdotool key Super+j

    log_success "Focused next window"
}

# Focus previous window
focus_prev() {
    log_info "Focusing previous window..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    # Send DWM focus prev (usually Super+k)
    xdotool key Super+k

    log_success "Focused previous window"
}

# Swap window with master
swap_master() {
    log_info "Swapping window with master..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    # Send DWM swap with master (usually Super+Enter)
    xdotool key --window "$(xdotool getactivewindow)" Super+Return

    log_success "Swapped with master"
}

# Zoom focused window
zoom() {
    log_info "Zooming focused window..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    # Send DWM zoom (usually Super+Shift+j)
    xdotool key --window "$(xdotool getactivewindow)" Super+Shift+j

    log_success "Zoomed window"
}

# Resize master area
resize_master() {
    local direction="$1"
    local amount="${2:-5}"

    if [ -z "$direction" ]; then
        log_error "Direction required"
        echo "Usage: $0 resize-master <left|right> <amount>"
        exit 1
    fi

    log_info "Resizing master area: $direction by $amount..."

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    case "$direction" in
        left|decrease|-)
            # Send DWM resize master (usually Super+h)
            for ((i=0; i<amount; i++)); do
                xdotool key Super+h
                sleep 0.05
            done
            ;;
        right|increase|+)
            # Send DWM resize master (usually Super+l)
            for ((i=0; i<amount; i++)); do
                xdotool key Super+l
                sleep 0.05
            done
            ;;
        *)
            log_error "Invalid direction: $direction (use left/right)"
            exit 1
            ;;
    esac

    log_success "Master area resized"
}

# Get window info
window_info() {
    log_info "Window information:"

    if ! command -v xdotool &>/dev/null; then
        log_error "xdotool not found"
        exit 1
    fi

    local window_id
    window_id=$(xdotool getactivewindow)

    echo ""
    echo "  Window ID: $window_id"

    local window_name
    window_name=$(xdotool getwindowname "$window_id" 2>/dev/null || echo "Unknown")
    echo "  Name: ${COLOR_TEXT}${window_name}${COLOR_RESET}"

    local window_class
    window_class=$(xdotool getwindowclassname "$window_id" 2>/dev/null || echo "Unknown")
    echo "  Class: ${COLOR_TEXT}${window_class}${COLOR_RESET}"

    if command -v xprop &>/dev/null; then
        local window_pid
        window_pid=$(xprop -id "$window_id" _NET_WM_PID 2>/dev/null | grep -oP '\d+' || echo "Unknown")
        echo "  PID: ${COLOR_TEXT}${window_pid}${COLOR_RESET}"
    fi

    echo ""
}

# Main function
main() {
    local action="${1:-info}"
    local param="$2"

    case "$action" in
        toggle-float|float|tf)
            toggle_floating
            ;;
        toggle-fullscreen|fullscreen|fs)
            toggle_fullscreen
            ;;
        move-to-tag|mt)
            move_to_tag "$param"
            ;;
        switch-tag|tag|st)
            switch_tag "$param"
            ;;
        kill|close|kc)
            kill_window
            ;;
        focus-next|fn)
            focus_next
            ;;
        focus-prev|fp)
            focus_prev
            ;;
        swap-master|sm)
            swap_master
            ;;
        zoom)
            zoom
            ;;
        resize-master|rm)
            resize_master "$param" "${3:-5}"
            ;;
        info|list)
            window_info
            ;;
        *)
            log_error "Invalid action: $action"
            echo ""
            echo "Usage: $0 <action> [options]"
            echo ""
            echo "Actions:"
            echo "  toggle-float        Toggle window floating state"
            echo "  toggle-fullscreen   Toggle window fullscreen"
            echo "  move-to-tag <1-9>   Move window to tag"
            echo "  switch-tag <1-9>    Switch to tag"
            echo "  kill                Kill focused window"
            echo "  focus-next          Focus next window"
            echo "  focus-prev          Focus previous window"
            echo "  swap-master         Swap window with master"
            echo "  zoom                Zoom focused window"
            echo "  resize-master <dir>  Resize master (left/right)"
            echo "  info                Show window information"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"

log_success "DWM window management ready"
