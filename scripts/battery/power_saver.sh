#!/bin/bash
# ============================================================
#  POWER SAVER - Activate battery power saving mode
#  Dependencies: tlp, notify-send
# ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check if battery exists
if ! has_battery; then
    log_info "No battery detected (desktop PC). Power saver mode not needed."
    exit 0
fi

# Configuration
MODE_FILE="$HOME/.local/share/s1b/battery/mode"

# Get current mode
get_current_mode() {
    if [ -f "$MODE_FILE" ]; then
        cat "$MODE_FILE"
    else
        echo "off"
    fi
}

# Set power saving mode
set_power_saver() {
    local mode="on"
    
    log_info "Activating power saving mode..."
    
    # Enable TLP if available
    if command -v tlp &>/dev/null; then
        sudo tlp start
    else
        log_warn "TLP not found. Install with: yay -S tlp"
    fi
    
    # Save mode
    ensure_dir_exists "$HOME/.local/share/s1b/battery"
    echo "$mode" > "$MODE_FILE"
    
    log_success "Power saving mode activated"
    notify-send "Battery" "Power saving mode ON" 2>/dev/null || true
    
    # Suggest power management
    echo ""
    echo "Power saving tips:"
    echo "  • Lower screen brightness"
    echo "  • Close unused applications"
    echo "  • Disable Bluetooth when not in use"
    echo "  • Reduce keyboard backlight"
    echo ""
}

# Turn off power saving
set_power_saver_off() {
    local mode="off"
    
    log_info "Deactivating power saving mode..."
    
    # Restore normal TLP settings if available
    if command -v tlp &>/dev/null; then
        sudo tlp start
    else
        log_warn "TLP not found. Install with: yay -S tlp"
    fi
    
    # Save mode
    ensure_dir_exists "$HOME/.local/share/s1b/battery"
    echo "$mode" > "$MODE_FILE"
    
    log_success "Power saving mode deactivated"
    notify-send "Battery" "Power saving mode OFF" 2>/dev/null || true
}

# Toggle power saving mode
toggle_power_saver() {
    local current
    current=$(get_current_mode)
    
    if [ "$current" = "on" ]; then
        set_power_saver_off
    else
        set_power_saver
    fi
}

# Show current status
show_status() {
    local current
    current=$(get_current_mode)
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}POWER SAVER${COLOR_RESET}"
    echo "══════════════════════════════════"
    echo ""
    
    if [ "$current" = "on" ]; then
        echo -e "Status: ${COLOR_GREEN}Active${COLOR_RESET}"
        echo "Power saving tips enabled"
    else
        echo -e "Status: ${COLOR_RED}Inactive${COLOR_RESET}"
        echo "Normal performance mode"
    fi
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --on)
            set_power_saver
            shift
            ;;
        --off)
            set_power_saver_off
            shift
            ;;
        --toggle|-t)
            toggle_power_saver
            shift
            ;;
        --status|-s)
            show_status
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--on|--off|--toggle|--status|--help]"
            echo ""
            echo "Options:"
            echo "  --on              Activate power saving mode"
            echo "  --off             Deactivate power saving mode"
            echo "  --toggle, -t      Toggle power saving mode"
            echo "  --status, -s       Show power saver status"
            echo "  --help, -h        Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--on|--off|--toggle|--status|--help]"
            exit 1
            ;;
    esac
    shift
done

# Default: show status
show_status

log_success "Power saver operation completed"
