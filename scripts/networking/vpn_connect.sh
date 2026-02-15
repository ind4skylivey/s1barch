#!/bin/bash
# ============================================================
#  VPN CONNECT - Connect to VPN (Tailscale, WireGuard, OpenVPN)
#  Dependencies: nmcli, notify-send
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
# VPN_CONFIG_DIR="$HOME/.config/vpn"  # Reserved for future use

# Get active VPN connection
get_active_vpn() {
    nmcli -t active | grep -i vpn
}

# List VPN connections
list_vpns() {
    nmcli connection show | grep -iE "vpn|tailscale|wireguard" | awk -F: '{print $1}'
}

# Connect to VPN
connect_vpn() {
    local vpn_name="$1"
    
    log_info "Connecting to VPN: $vpn_name"
    notify-send "VPN" "Connecting to $vpn_name..." 2>/dev/null || true
    
    nmcli connection up "$vpn_name"
    
    local active
    sleep 2
    active=$(get_active_vpn)
    
    if [ -n "$active" ]; then
        log_success "VPN connected: $active"
        notify-send "VPN" "Connected to $active" 2>/dev/null || true
    else
        log_error "Failed to connect to VPN"
        notify-send "VPN" "Connection failed" 2>/dev/null || true
    fi
}

# Disconnect VPN
disconnect_vpn() {
    local active
    active=$(get_active_vpn)
    
    if [ -z "$active" ]; then
        log_info "No active VPN connection"
        return 0
    fi
    
    log_info "Disconnecting from VPN: $active"
    nmcli connection down "$active"
    
    log_success "VPN disconnected: $active"
    notify-send "VPN" "Disconnected from $active" 2>/dev/null || true
}

# Toggle VPN
toggle_vpn() {
    local active
    active=$(get_active_vpn)
    
    if [ -n "$active" ]; then
        disconnect_vpn
    else
        local vpns
        vpns=$(list_vpns)
        
        if [ -z "$vpns" ]; then
            log_error "No VPN connections found"
            echo "Available VPN types:"
            echo "  1. Tailscale"
            echo "  2. WireGuard"
            echo "  3. OpenVPN"
            exit 1
        fi
        
        local choice
        choice=$(echo "$vpns" | rofi -dmenu -p "Select VPN:" -theme "$HOME/.config/rofi/cyberpunk")
        
        if [ -n "$choice" ]; then
            connect_vpn "$choice"
        fi
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            list_vpns
            shift
            ;;
        --connect|-c)
            if [ -n "$2" ]; then
                connect_vpn "$2"
                shift 2
            fi
            ;;
        --disconnect|-d)
            disconnect_vpn
            shift
            ;;
        --toggle|-t)
            toggle_vpn
            shift
            ;;
        --status|-s)
            active_vpn_status=$(get_active_vpn)
            if [ -n "$active_vpn_status" ]; then
                log_info "Active VPN: $active_vpn_status"
                echo "$active_vpn_status"
            else
                log_info "No active VPN connection"
            fi
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--list|--connect <vpn>|--disconnect|--toggle|--status|--help]"
            echo ""
            echo "Options:"
            echo "  --list       List all VPN connections"
            echo "  --connect, -c <vpn>  Connect to specific VPN"
            echo "  --disconnect, -d   Disconnect current VPN"
            echo "  --toggle, -t      Toggle VPN connection"
            echo "  --status, -s       Show VPN connection status"
            echo "  --help, -h        Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default: show menu
toggle_vpn

log_success "VPN operation completed"
