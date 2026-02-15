#!/bin/bash
# ============================================================
#  DETECT SERVICES - Detect active services
#  Usage: source ~/Desktop/S1Bs1stem/scripts/detection/detect_services.sh
#  Output: List of active services
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Detect active services
detect_active_services() {
    declare -a services
    
    # Window managers
    pgrep -x "dwm" &>/dev/null && services+=("dwm")
    pgrep -x "hyprland" &>/dev/null && services+=("hyprland")
    pgrep -x "waybar" &>/dev/null && services+=("waybar")
    
    # Compositors
    pgrep -x "picom" &>/dev/null && services+=("picom")
    
    # Notification daemons
    pgrep -x "dunst" &>/dev/null && services+=("dunst")
    
    # Network managers
    pgrep -x "NetworkManager" &>/dev/null && services+=("NetworkManager")
    pgrep -x "nm-applet" &>/dev/null && services+=("nm-applet")
    
    # Bluetooth
    pgrep -x "blueman-applet" &>/dev/null && services+=("bluetooth")
    
    # Audio
    pgrep -x "pipewire" &>/dev/null && services+=("pipewire")
    pgrep -x "pulseaudio" &>/dev/null && services+=("pulseaudio")
    
    # Print services
    for service in "${services[@]}"; do
        echo "$service"
    done
}

# Get service status
get_service_status() {
    local service="$1"
    
    if [ -z "$service" ]; then
        log_error "Service name required"
        return 1
    fi
    
    if pgrep -x "$service" &>/dev/null; then
        echo "running"
        return 0
    else
        echo "stopped"
        return 1
    fi
}

# Kill service
kill_service() {
    local service="$1"
    local signal="${2:-TERM}"
    
    if [ -z "$service" ]; then
        log_error "Service name required"
        return 1
    fi
    
    log_info "Killing service: $service (signal: $signal)"
    
    if pgrep -x "$service" &>/dev/null; then
        pkill -"$signal" "$service"
        log_success "Service killed: $service"
        return 0
    else
        log_warn "Service not running: $service"
        return 1
    fi
}

# Main function
main() {
    local action="${1:-list}"
    local service="$2"
    local signal="$3"
    
    case "$action" in
        list|ls|active)
            detect_active_services
            ;;
        status|get|check)
            get_service_status "$service"
            ;;
        kill|stop|terminate)
            kill_service "$service" "$signal"
            ;;
        *)
            log_error "Invalid action: $action"
            echo "Usage: $0 [list|status|kill] [service] [signal]"
            exit 1
            ;;
    esac
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Export functions for sourcing
export -f detect_active_services
export -f get_service_status
export -f kill_service
export -f main
