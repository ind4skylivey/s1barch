#!/bin/bash
# ============================================================
#  SCREENSHOT MANAGER - Take screenshots with various options
#  Dependencies: maim (recommended), scrot, or gnome-screenshot
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/screenshots}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly TIMESTAMP

# Ensure screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

# Detect screenshot tool
if command -v maim &>/dev/null; then
    SCREENSHOT_TOOL="maim"
elif command -v scrot &>/dev/null; then
    SCREENSHOT_TOOL="scrot"
elif command -v gnome-screenshot &>/dev/null; then
    SCREENSHOT_TOOL="gnome-screenshot"
else
    log_error "No screenshot tool found"
    log_info "Install one of: maim (recommended), scrot, or gnome-screenshot"
    exit 1
fi

log_info "Using: $SCREENSHOT_TOOL"

# Full screen screenshot
screenshot_full() {
    local filename="${SCREENSHOT_DIR}/screenshot_${TIMESTAMP}.png"
    
    log_info "Taking full screen screenshot..."
    
    case "$SCREENSHOT_TOOL" in
        "maim")
            maim "$filename"
            ;;
        "scrot")
            scrot "$filename"
            ;;
        "gnome-screenshot")
            gnome-screenshot -f "$filename"
            ;;
    esac
    
    if [ -f "$filename" ]; then
        log_success "Screenshot saved: $filename"
        copy_to_clipboard "$filename"
    else
        log_error "Failed to save screenshot"
        return 1
    fi
}

# Selection screenshot
screenshot_selection() {
    local filename="${SCREENSHOT_DIR}/screenshot_selection_${TIMESTAMP}.png"
    
    log_info "Select area for screenshot..."
    
    case "$SCREENSHOT_TOOL" in
        "maim")
            maim -s "$filename"
            ;;
        "scrot")
            scrot -s "$filename"
            ;;
        "gnome-screenshot")
            gnome-screenshot -a -f "$filename"
            ;;
    esac
    
    if [ -f "$filename" ]; then
        log_success "Screenshot saved: $filename"
        copy_to_clipboard "$filename"
    else
        log_warn "Selection cancelled or failed"
        return 1
    fi
}

# Active window screenshot
screenshot_window() {
    local filename="${SCREENSHOT_DIR}/screenshot_window_${TIMESTAMP}.png"
    
    log_info "Taking active window screenshot..."
    
    case "$SCREENSHOT_TOOL" in
        "maim")
            maim -i "$(xdotool getactivewindow)" "$filename"
            ;;
        "scrot")
            scrot -u "$filename"
            ;;
        "gnome-screenshot")
            gnome-screenshot -w -f "$filename"
            ;;
    esac
    
    if [ -f "$filename" ]; then
        log_success "Screenshot saved: $filename"
        copy_to_clipboard "$filename"
    else
        log_error "Failed to save screenshot"
        return 1
    fi
}

# Copy to clipboard
copy_to_clipboard() {
    local file="$1"
    
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard -t image/png -i "$file"
        log_info "Copied to clipboard"
    elif command -v xsel &>/dev/null; then
        xsel --clipboard < "$file"
        log_info "Copied to clipboard"
    fi
}

# Show menu
show_menu() {
    local options="Full Screen
Selection
Active Window
View Screenshots
Open Screenshot Directory"
    
    local choice
    choice=$(echo "$options" | rofi -dmenu -p "Screenshot:" -theme "$HOME/.config/rofi/cyberpunk" 2>/dev/null || echo "")
    
    case "$choice" in
        "Full Screen")
            screenshot_full
            ;;
        "Selection")
            screenshot_selection
            ;;
        "Active Window")
            screenshot_window
            ;;
        "View Screenshots")
            if command -v feh &>/dev/null; then
                feh "$SCREENSHOT_DIR" &
            else
                xdg-open "$SCREENSHOT_DIR"
            fi
            ;;
        "Open Screenshot Directory")
            xdg-open "$SCREENSHOT_DIR"
            ;;
        *)
            log_info "No action taken"
            ;;
    esac
}

# Main
log_section "Screenshot Manager"

case "${1:-menu}" in
    "full")
        screenshot_full
        ;;
    "selection"|"sel"|"area")
        screenshot_selection
        ;;
    "window"|"win")
        screenshot_window
        ;;
    "menu")
        show_menu
        ;;
    *)
        echo "Usage: $0 [full|selection|window|menu]"
        exit 1
        ;;
esac
