#!/bin/bash
# ============================================================
#  SCREENSHOT - Take screenshots with various modes
#  Dependencies: grim, slurp, notify-send (optional)
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly SCREENSHOT_DIR="$HOME/Pictures/screenshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly TIMESTAMP

# Ensure screenshot directory exists
ensure_dir_exists "$SCREENSHOT_DIR"

# Get screenshot tool
get_screenshot_tool() {
    if command -v grim &>/dev/null; then
        echo "grim"
    elif command -v maim &>/dev/null; then
        echo "maim"
    elif command -v scrot &>/dev/null; then
        echo "scrot"
    else
        echo "none"
    fi
}

# Get selection tool
get_selection_tool() {
    if command -v slurp &>/dev/null; then
        echo "slurp"
    elif command -v slop &>/dev/null; then
        echo "slop"
    else
        echo "none"
    fi
}

# Take full screenshot
screenshot_full() {
    local tool
    tool=$(get_screenshot_tool)
    local filename="${SCREENSHOT_DIR}/screenshot_${TIMESTAMP}.png"

    log_info "Taking full screenshot..."

    case "$tool" in
        grim)
            grim "$filename"
            ;;
        maim)
            maim "$filename"
            ;;
        scrot)
            scrot "$filename"
            ;;
        *)
            log_error "No screenshot tool found (grim/maim/scrot)"
            log_info "Install: sudo pacman -S grim"
            return 1
            ;;
    esac

    log_success "Screenshot saved: $filename"
    notify-send "Screenshot" "Full screenshot saved to $filename" 2>/dev/null || true
    echo "$filename"
}

# Take selection screenshot
screenshot_selection() {
    local screenshot_tool
    screenshot_tool=$(get_screenshot_tool)
    local selection_tool
    selection_tool=$(get_selection_tool)

    if [ "$screenshot_tool" = "none" ]; then
        log_error "No screenshot tool found (grim/maim/scrot)"
        log_info "Install: sudo pacman -S grim slurp"
        return 1
    fi

    if [ "$selection_tool" = "none" ]; then
        log_error "No selection tool found (slurp/slop)"
        log_info "Install: sudo pacman -S slurp"
        return 1
    fi

    log_info "Select area to screenshot..."

    local filename="${SCREENSHOT_DIR}/selection_${TIMESTAMP}.png"

    case "$screenshot_tool" in
        grim)
            case "$selection_tool" in
                slurp)
                    local geometry
                    geometry=$(slurp)
                    grim -g "$geometry" "$filename"
                    ;;
            esac
            ;;
        maim)
            case "$selection_tool" in
                slop)
                    maim -s "$filename"
                    ;;
            esac
            ;;
    esac

    log_success "Screenshot saved: $filename"
    notify-send "Screenshot" "Selection saved to $filename" 2>/dev/null || true
    echo "$filename"
}

# Take window screenshot
screenshot_window() {
    local tool
    tool=$(get_screenshot_tool)
    local filename="${SCREENSHOT_DIR}/window_${TIMESTAMP}.png"

    log_info "Taking window screenshot..."

    case "$tool" in
        grim)
            # Get focused window geometry with xdotool
            if command -v xdotool &>/dev/null; then
                local geometry
                geometry=$(xdotool getactivewindow getwindowgeometry | grep -oP 'Geometry: \K\d+x\d+\+\d+\+\d+')
                grim -g "$geometry" "$filename"
            else
                log_warn "xdotool not found, falling back to full screenshot"
                grim "$filename"
            fi
            ;;
        maim)
            maim -i "$(xdotool getactivewindow)" "$filename" 2>/dev/null || maim "$filename"
            ;;
        scrot)
            scrot -u "$filename" 2>/dev/null || scrot "$filename"
            ;;
        *)
            log_error "No screenshot tool found (grim/maim/scrot)"
            return 1
            ;;
    esac

    log_success "Screenshot saved: $filename"
    notify-send "Screenshot" "Window screenshot saved to $filename" 2>/dev/null || true
    echo "$filename"
}

# Take clipboard screenshot
screenshot_clipboard() {
    local tool
    tool=$(get_screenshot_tool)
    local selection_tool
    selection_tool=$(get_selection_tool)

    if [ "$tool" = "none" ]; then
        log_error "No screenshot tool found (grim/maim/scrot)"
        return 1
    fi

    log_info "Taking screenshot to clipboard..."

    case "$tool" in
        grim)
            if [ "$selection_tool" = "slurp" ]; then
                local geometry
                geometry=$(slurp)
                grim -g "$geometry" - | wl-copy 2>/dev/null || grim -g "$geometry" - | xclip -selection clipboard -t image/png 2>/dev/null
            else
                grim - | wl-copy 2>/dev/null || grim - | xclip -selection clipboard -t image/png 2>/dev/null
            fi
            ;;
        maim)
            maim -s | xclip -selection clipboard -t image/png 2>/dev/null
            ;;
        *)
            log_error "Clipboard not supported with this tool"
            return 1
            ;;
    esac

    log_success "Screenshot copied to clipboard"
    notify-send "Screenshot" "Copied to clipboard" 2>/dev/null || true
}

# List recent screenshots
list_screenshots() {
    log_info "Recent screenshots:"
    echo ""

    if [ ! -d "$SCREENSHOT_DIR" ]; then
        log_warn "No screenshot directory found"
        return 0
    fi

    find "$SCREENSHOT_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) -printf '%T+ %p\n' | sort -r | head -20 | while read -r line; do
        local timestamp filepath
        timestamp=$(echo "$line" | awk '{print $1, $2}')
        filepath=$(echo "$line | cut -d' ' -f3-")
        local basename
        basename=$(basename "$filepath")
        echo "  ${COLOR_GREEN}${basename}${COLOR_RESET}"
        echo "    ${COLOR_SUBTEXT}${timestamp}${COLOR_RESET}"
        echo ""
    done
}

# Main logic
main() {
    local action="${1:-full}"

    case "$action" in
        full|screen)
            screenshot_full
            ;;
        selection|select|area)
            screenshot_selection
            ;;
        window|win)
            screenshot_window
            ;;
        clipboard|clip|copy)
            screenshot_clipboard
            ;;
        list|ls)
            list_screenshots
            ;;
        *)
            log_error "Invalid action: $action"
            echo ""
            echo "Usage: $0 [full|selection|window|clipboard|list]"
            echo ""
            echo "Options:"
            echo "  full       Take full screenshot"
            echo "  selection  Select area to screenshot"
            echo "  window     Take screenshot of focused window"
            echo "  clipboard  Copy screenshot to clipboard"
            echo "  list       List recent screenshots"
            exit 1
            ;;
    esac
}

main "$@"

log_success "Screenshot tool ready"
