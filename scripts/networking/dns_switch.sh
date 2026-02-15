#!/bin/bash
# ============================================================
#  DNS SWITCH - Switch between DNS providers
#  Dependencies: nmcli, notify-send
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# DNS providers
DNS_CLOUDFLARE="1.1.1.1"
DNS_GOOGLE="8.8.8.8"
DNS_QUAD9="9.9.9.9"

# Get current DNS
get_current_dns() {
    nmcli dev show | grep "DNS configuration:" -A 3 | tail -1 | awk '{print $1}'
}

# Set DNS
set_dns() {
    local dns="$1"
    local dns_name="$2"
    
    log_info "Setting DNS to: $dns_name ($dns)"
    
    # Get first active connection
    local connection
    connection=$(nmcli -t connection show --active | grep -v '^NAME' | head -n 1 | cut -d: -f1)
    
    if [ -n "$connection" ]; then
        nmcli connection modify "$connection" ipv4.dns "$dns"
        nmcli connection modify "$connection" ipv6.dns "$dns"
        nmcli connection up "$connection"
        
        log_success "DNS set to: $dns_name"
        notify-send "DNS" "Switched to $dns_name" 2>/dev/null || true
    else
        log_error "No active connection found"
        exit 1
    fi
}

# Reset DNS (automatic)
reset_dns() {
    log_info "Resetting DNS to automatic..."
    
    local connection
    connection=$(nmcli -t active | grep -i connection | head -n 1 | awk -F: '{print $1}')
    
    if [ -n "$connection" ]; then
        nmcli connection modify "$connection" ipv4.ignore-auto-dns no
        nmcli connection modify "$connection" ipv6.ignore-auto-dns no
        nmcli connection up "$connection"
        
        log_success "DNS reset to automatic"
        notify-send "DNS" "Reset to automatic" 2>/dev/null || true
    else
        log_error "No active connection found"
        exit 1
    fi
}

# DNS menu
dns_menu() {
    local current_dns
    current_dns=$(get_current_dns)
    
    local options
    options="Current: $current_dns
---
1. Cloudflare ($DNS_CLOUDFLARE)
2. Google ($DNS_GOOGLE)
3. Quad9 ($DNS_QUAD9)
4. Reset (Automatic)
Exit"
    
    local choice
    choice=$(echo "$options" | rofi -dmenu -p "Select DNS Provider:" -theme "$HOME/.config/rofi/cyberpunk")
    
    case "$choice" in
        "1. Cloudflare ($DNS_CLOUDFLARE)")
            set_dns "$DNS_CLOUDFLARE" "Cloudflare"
            ;;
        "2. Google ($DNS_GOOGLE)")
            set_dns "$DNS_GOOGLE" "Google"
            ;;
        "3. Quad9 ($DNS_QUAD9)")
            set_dns "$DNS_QUAD9" "Quad9"
            ;;
        "4. Reset (Automatic)")
            reset_dns
            ;;
        "Exit")
            return 0
            ;;
        "Current: $current_dns")
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cloudflare|-1)
            set_dns "$DNS_CLOUDFLARE" "Cloudflare"
            shift
            ;;
        --google|-2)
            set_dns "$DNS_GOOGLE" "Google"
            shift
            ;;
        --quad9|-3)
            set_dns "$DNS_QUAD9" "Quad9"
            shift
            ;;
        --reset|-4)
            reset_dns
            shift
            ;;
        --menu|-m)
            dns_menu
            shift
            ;;
        --status|-s)
            current=$(get_current_dns)
            echo "$current"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--cloudflare|--google|--quad9|--reset|--menu|--status|--help]"
            echo ""
            echo "Options:"
            echo "  --cloudflare, -1  Set DNS to Cloudflare (1.1.1.1)"
            echo "  --google, -2       Set DNS to Google (8.8.8.8)"
            echo "  --quad9, -3        Set DNS to Quad9 (9.9.9.9)"
            echo "  --reset, -4         Reset DNS to automatic"
            echo "  --menu, -m         Show DNS selection menu"
            echo "  --status, -s        Show current DNS"
            echo "  --help, -h         Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default: show menu
dns_menu

log_success "DNS operation completed"

