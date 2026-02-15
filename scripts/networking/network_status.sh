#!/bin/bash
# ============================================================
#  NETWORK STATUS - Show network connection status
#  Dependencies: nmcli, curl, jq
#  ============================================================

set -euo pipefail

# Show help and exit early if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [--internet|--dns|--help]"
    echo ""
    echo "Options:"
    echo "  --internet, -i   Check internet connectivity"
    echo "  --dns, -d        Show DNS servers"
    echo "  --help, -h       Show this help message"
    exit 0
fi

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Checking network status..."

# Check if nmcli is available
if ! command -v nmcli &>/dev/null; then
    log_error "nmcli not found. Please install networkmanager"
    exit 1
fi

# Get active connection
get_active_connection() {
    nmcli -t connection show --active | grep -v '^NAME' | head -n 1 | cut -d: -f1
}

# Get connection type
get_connection_type() {
    nmcli -t connection show --active | grep -v '^NAME' | head -n 1 | awk -F: '{print $3}'
}

# Get IP addresses
get_ips() {
    local ipv4
    local ipv6
    
    ipv4=$(nmcli -t fields -4 ip address show "$(get_active_connection)" 2>/dev/null)
    ipv6=$(nmcli -t fields -6 ip address show "$(get_active_connection)" 2>/dev/null)
    
    echo "IPv4: ${ipv4:-Not connected}"
    echo "IPv6: ${ipv6:-Not connected}"
}

# Check internet connectivity
check_internet() {
    log_info "Checking internet connectivity..."
    
    local hosts=("google.com" "cloudflare.com" "archlinux.org")
    local connected=false
    
    for host in "${hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &>/dev/null; then
            log_success "Connected to $host"
            connected=true
            break
        fi
    done
    
    if [ "$connected" = false ]; then
        log_warn "No internet connectivity detected"
    fi
}

# Get DNS servers
get_dns() {
    echo "DNS Servers:"
    nmcli dev show | grep DNS | head -3
}

# Display status
display_status() {
    local active_conn
    local conn_type
    local gateway
    
    active_conn=$(get_active_connection)
    conn_type=$(get_connection_type)
    gateway=$(nmcli -t fields IP4.GATEWAY ip show "$active_conn" 2>/dev/null)
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}NETWORK STATUS${COLOR_RESET}"
    echo "═════════════════════════════════════"
    echo ""
    echo "Status: ${COLOR_GREEN}Connected${COLOR_RESET}"
    echo "Active Connection: $active_conn"
    echo "Connection Type: $conn_type"
    echo ""
    echo "Gateway: ${gateway:-Not connected}"
    echo ""
    
    get_ips
    echo ""
    
    get_dns
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --internet|-i)
            check_internet
            shift
            ;;
        --dns|-d)
            get_dns
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--internet|--dns|--help]"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--internet|--dns|--help]"
            exit 1
            ;;
    esac
done

# Default: display full status
display_status

log_success "Network status check completed"
