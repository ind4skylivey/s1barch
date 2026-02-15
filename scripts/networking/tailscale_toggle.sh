#!/bin/bash
# ============================================================
#  TAILSCALE TOGGLE - Toggle Tailscale VPN
#  Dependencies: tailscale (from yay/AUR)
#  ============================================================

set -euo pipefail

# Show help and exit early if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [--status|--up|--down|--toggle|--help]"
    echo ""
    echo "Options:"
    echo "  --status     Show current Tailscale status"
    echo "  --up         Start Tailscale"
    echo "  --down       Stop Tailscale"
    echo "  --toggle     Toggle Tailscale on/off"
    echo "  --help, -h   Show this help message"
    exit 0
fi

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Checking Tailscale status..."

# Check if tailscale is installed
if ! command -v tailscale &>/dev/null; then
    log_error "Tailscale not found. Install with: yay -S tailscale"
    exit 1
fi

# Get Tailscale status
get_status() {
    tailscale status
}

# Toggle Tailscale
toggle_tailscale() {
    local status
    status=$(get_status | grep -i "status:" | awk '{print $2}')
    
    if [ "$status" = "Running" ]; then
        log_info "Stopping Tailscale..."
        tailscale down
        
        sleep 2
        
        status=$(get_status | grep -i "status:" | awk '{print $2}')
        
        if [ "$status" = "Stopped" ]; then
            log_success "Tailscale stopped"
            notify-send "Tailscale" "Stopped" 2>/dev/null || true
        else
            log_error "Failed to stop Tailscale"
        fi
    else
        log_info "Starting Tailscale..."
        tailscale up
        
        sleep 2
        
        status=$(get_status | grep -i "status:" | awk '{print $2}')
        
        if [ "$status" = "Running" ]; then
            log_success "Tailscale started"
            notify-send "Tailscale" "Started" 2>/dev/null || true
        else
            log_error "Failed to start Tailscale"
        fi
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --status|-s)
            get_status
            shift
            ;;
        --toggle|-t)
            toggle_tailscale
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--status|--toggle|--help]"
            echo ""
            echo "Options:"
            echo "  --status, -s         Show Tailscale status"
            echo "  --toggle, -t         Toggle Tailscale ON/OFF"
            echo "  --help, -h          Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--status|--toggle|--help]"
            exit 1
            ;;
    esac
done

# Default: show status
get_status

log_success "Tailscale operation completed"
