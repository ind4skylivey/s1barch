#!/bin/bash
# ============================================================
#  WIFI TOGGLE - Toggle WiFi ON/OFF
#  Dependencies: nmcli
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Get WiFi status
get_wifi_status() {
    local wifi_state
    wifi_state=$(nmcli radio wifi | head -n 1)
    echo "$wifi_state"
}

# Toggle WiFi
toggle_wifi() {
    local current_status
    current_status=$(get_wifi_status)
    
    if [ "$current_status" = "enabled" ]; then
        log_info "Disabling WiFi..."
        nmcli radio wifi off
        log_success "WiFi disabled"
        notify-send "WiFi" "Disabled" 2>/dev/null || true
    else
        log_info "Enabling WiFi..."
        nmcli radio wifi on
        log_success "WiFi enabled"
        notify-send "WiFi" "Enabled" 2>/dev/null || true
    fi
}

# List available networks
list_networks() {
    log_info "Scanning for available networks..."
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}AVAILABLE NETWORKS${COLOR_RESET}"
    echo "═════════════════════════════════════"
    echo ""
    
    nmcli device wifi list | while read -r line; do
        ssid=$(echo "$line" | awk '{print $2}')
        bssid=$(echo "$line" | awk '{print $3}')
        signal=$(echo "$line" | awk '{print $7}')
        
        local signal_bars
        signal_bars=$(printf '█%.0s' $((signal / 10)))
        
        if [ "$ssid" = "--" ]; then
            continue
        fi
        
        echo -e "${COLOR_GREEN}●${COLOR_RESET} $ssid ($bssid)"
        echo "  Signal: $signal_bars ($signal%)"
        echo ""
    done
    
    echo ""
}

# Connect to network
connect_network() {
    local network_ssid="$1"
    
    log_info "Connecting to $network_ssid..."
    
    nmcli device wifi connect "$network_ssid"
    
    log_success "Connection initiated"
    notify-send "WiFi" "Connecting to $network_ssid" 2>/dev/null || true
}

# Disconnect current network
disconnect_network() {
    log_info "Disconnecting from current network..."
    
    local active_conn
    active_conn=$(nmcli -t fields active connection | head -n 1)
    
    if [ -n "$active_conn" ] && [ "$active_conn" != "--" ]; then
        nmcli connection down "$active_conn"
        log_success "Disconnected from $active_conn"
        notify-send "WiFi" "Disconnected" 2>/dev/null || true
    else
        log_warn "No active connection to disconnect"
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --toggle|-t)
            toggle_wifi
            shift
            ;;
        --list|-l)
            list_networks
            shift
            ;;
        --connect|-c)
            if [ -n "$2" ]; then
                connect_network "$2"
                shift 2
            else
                log_error "Please specify network SSID"
                echo "Usage: $0 --connect <ssid>"
                exit 1
            fi
            ;;
        --disconnect|-d)
            disconnect_network
            shift
            ;;
        --status|-s)
            get_wifi_status
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--toggle|--list|--connect|--disconnect|--status|--help]"
            echo ""
            echo "Options:"
            echo "  --toggle, -t         Toggle WiFi ON/OFF"
            echo "  --list, -l           List available networks"
            echo "  --connect, -c <ssid>  Connect to network"
            echo "  --disconnect, -d    Disconnect current network"
            echo "  --status, -s          Show WiFi status"
            echo "  --help, -h           Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--toggle|--list|--connect|--disconnect|--status|--help]"
            exit 1
            ;;
    esac
done

# Default: show status
get_wifi_status

log_success "WiFi operation completed"
