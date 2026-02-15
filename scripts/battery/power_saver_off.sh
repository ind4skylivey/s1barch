#!/bin/bash
# ============================================================
#  POWER SAVER OFF - Deactivate power saving mode
#  Dependencies: tlp, notify-send
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

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

# Deactivate power saving mode
deactivate_power_saver() {
    local mode="off"
    
    log_info "Deactivating power saving mode..."
    
    # Restore normal TLP settings if available
    if command -v tlp &>/dev/null; then
        sudo tlp start
        log_info "TLP restored to default profile"
    else
        log_warn "TLP not found. Install with: yay -S tlp"
    fi
    
    # Save mode
    ensure_dir_exists "$HOME/.local/share/s1b/battery"
    echo "$mode" > "$MODE_FILE"
    
    log_success "Power saving mode deactivated"
    notify-send "Battery" "Power saving mode OFF - Performance mode" 2>/dev/null || true
    
    # Restore performance tips
    echo ""
    echo "Performance mode active"
    echo "  • Full CPU performance"
    echo "  • No brightness limits"
    echo "  • Animations enabled"
    echo ""
}

# Show current status
show_status() {
    local current
    current=$(get_current_mode)
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}POWER SAVER${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    echo ""
    
    if [ "$current" = "on" ]; then
        echo -e "Status: ${COLOR_GREEN}Active${COLOR_RESET}"
        echo "Power saving mode enabled"
    else
        echo -e "Status: ${COLOR_RED}Inactive${COLOR_RESET}"
        echo "Performance mode"
    fi
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --status|-s)
            show_status
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--status|--help]"
            echo ""
            echo "Options:"
            echo "  --status, -s       Show power saver status"
            echo "  --help, -h        Show this help"
            exit 0
            ;;
        *)
            deactivate_power_saver
            shift
            ;;
    esac
done

# Default: deactivate
deactivate_power_saver

log_success "Power saver deactivation completed"
