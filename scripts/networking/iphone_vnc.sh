#!/bin/bash
# ============================================================
#  IPHONE VNC - Connect iPhone as VNC server
#  Dependencies: libimobiledevice, vncviewer
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Setting up iPhone VNC connection..."

# Check dependencies
check_dependencies() {
    local missing_deps=0
    
    if ! command -v idevicepairer &>/dev/null; then
        log_warn "idevicepairer not found. Install with: yay -S idevicepairer"
        missing_deps=$((missing_deps + 1))
    fi
    
    if ! command -v vncviewer &>/dev/null; then
        log_warn "vncviewer not found. Install with: sudo pacman -S vncviewer"
        missing_deps=$((missing_deps + 1))
    fi
    
    if [ "$missing_deps" -gt 0 ]; then
        log_warn "Missing $missing_deps dependencies"
    fi
}

# Get iPhone IP
get_iphone_ip() {
    # Get iPhone IP from network
    local ip
    ip=$(nmcli -t fields ip.address show active | head -n 1)
    
    if [ -z "$ip" ]; then
        log_error "No active network connection found"
        exit 1
    fi
    
    echo "$ip"
}

# List paired iPhones
list_iphones() {
    log_info "Searching for paired iPhones..."
    
    if command -v idevicepairer &>/dev/null; then
        idevicepairer list
    else
        log_error "idevicepairer not found. Install: yay -S idevicepairer"
        exit 1
    fi
}

# Connect to iPhone VNC
connect_iphone_vnc() {
    local iphone_ip="$1"
    
    log_info "Connecting to iPhone VNC at $iphone_ip..."
    
    # Start VNC server on iPhone (requires manual enable)
    log_warn "Make sure iPhone VNC Server is enabled in Settings > General > VNC"
    log_warn "Default password: 'iphone' (can change in iPhone Settings)"
    
    notify-send "iPhone" "Connecting to $iphone_ip..." 2>/dev/null || true
    
    # Open VNC connection
    vncviewer "$iphone_ip":5900 &
    
    log_success "VNC connection initiated to $iphone_ip"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            list_iphones
            shift
            ;;
        --connect|-c)
            if [ -n "$2" ]; then
                connect_iphone_vnc "$2"
                shift 2
            else
                ip=$(get_iphone_ip)
                connect_iphone_vnc "$ip"
                shift
            fi
            ;;
        --ip)
            if [ -n "$2" ]; then
                ip=$(get_iphone_ip)
                log_info "iPhone IP: $ip"
                shift
            fi
            ;;
        --help|-h)
            echo "Usage: $0 [--list|--connect <ip>|--ip|--help]"
            echo ""
            echo "Options:"
            echo "  --list              List all paired iPhones"
            echo "  --connect <ip>       Connect to iPhone VNC at <ip>"
            echo "  --ip                 Get current iPhone IP"
            echo "  --help, -h           Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--list|--connect <ip>|--ip|--help]"
            exit 1
            ;;
    esac
    shift
done

# Check dependencies first
check_dependencies

# Default: show help
echo "Usage: $0 [--list|--connect <ip>|--ip|--help]"
echo ""
echo "Options:"
echo "  --list              List all paired iPhones"
echo "  --connect <ip>       Connect to iPhone VNC at <ip>:5900"
echo "  --ip                 Get current iPhone IP from network"
echo "  --help, -h           Show this help"

log_info "iPhone VNC script ready. Requires idevicepairer + vncviewer"
