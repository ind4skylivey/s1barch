#!/bin/bash
# ============================================================
#  CHARGE LIMIER - Limit battery charge level
#  Dependencies: asusctl (for ASUS laptops only)
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
LIMIT_FILE="$HOME/.s1b_charge_limiter"
# shellcheck disable=SC2034
CHARGE_STOP_THRESHOLD="1"  # Stop charging at 1%

# Battery percentage limits
readonly PERCENTAGE_LIMITS=(5 20 40 60 80)

# ASUS specific
ASUSCTL="/usr/sbin/asusctl"
IS_ASUS_LAPTOP=false

# Check if ASUS laptop
detect_asus_laptop() {
    # Check for ASUS-specific tools
    if [ -f "$ASUSCTL" ]; then
        IS_ASUS_LAPTOP=true
        log_info "ASUS laptop detected"
    fi
}

# Get current charge percentage
get_charge_level() {
    # Check for asusctl if ASUS laptop
    if [ "$IS_ASUS_LAPTOP" = true ]; then
        # Try asusctl first
        local charge
        charge=$("$ASUSCTL" -c 1)
        echo "$charge"
    else
        # Fallback to upower
        upower -e | grep -E "percentage" | awk '{print $3}'
    fi
}

# Set charge limit
set_limit() {
    local limit="$1"
    
    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
        log_error "Invalid percentage limit: $limit"
        echo "Valid range: 5, 20, 40, 60, 80"
        exit 1
    fi
    
    echo "$limit" > "$LIMIT_FILE"
    log_info "Charge limit set to $limit%"
}

# Get current limit
get_limit() {
    if [ -f "$LIMIT_FILE" ]; then
        cat "$LIMIT_FILE"
    else
        echo "100"  # Default: 100%
    fi
}

# Check and limit charging
check_and_limit_charge() {
    local limit
    limit=$(get_limit)
    local current
    current=$(get_charge_level)
    
    if [ "$current" -ge "$limit" ]; then
        log_warn "Battery at $current% - Exceeded limit ($limit%)"
        
        # Stop charging if possible
        if [ "$IS_ASUS_LAPTOP" = true ]; then
            # Stop charging with asusctl
            "$ASUSCTL" -c 1
            log_warn "Charging stopped (ASUS laptop)"
            notify-send "Battery" "Charging stopped (limit reached)" 2>/dev/null || true
        fi
        
        # Log event
        echo "$(date +"%Y-%m-%d %H:%M:%S")" >> "$HOME/.s1b_charge_history"
    fi
}

# Show current status
show_status() {
    local limit
    limit=$(get_limit)
    local current
    current=$(get_charge_level)
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}CHARGE LIMITER STATUS${COLOR_RESET}"
    echo "═════════════════════════════════════════════════════════════════════"
    echo ""
    echo "Limit: $limit%"
    echo "Current: $current%"
    echo ""
    echo "Available limits: ${PERCENTAGE_LIMITS[*]}"
    echo ""
    
    local limit_int
    for limit_int in "${PERCENTAGE_LIMITS[@]}"; do
        if [ "$limit" = "$limit" ]; then
            echo -e "${COLOR_GREEN}$limit_int%${COLOR_RESET} (current)"
        else
            echo -e "  $limit_int%${COLOR_RESET}"
        fi
    done
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --show|-s)
            show_status
            shift
            ;;
        --set)
            set_limit "$2"
            shift
            ;;
        --get)
            get_limit
            shift
            ;;
        --check)
            check_and_limit_charge
            ;;
        --reset)
            rm -f "$LIMIT_FILE"
            log_info "Charge limit removed (reset to 100%)"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--show|--set <limit>|--get|--check|--reset|--help]"
            echo ""
            echo "Options:"
            echo "  --show, -s            Show charge limit and current status"
            echo "  --set <limit>            Set charge limit (5, 20, 40, 60, 80, 100)"
            echo "  --get                  Get current charge limit"
            echo "  --check                 Check if charging needs to be stopped"
            echo "  --reset               Remove limit (reset to 100%)"
            echo "  --help, -h              Show this help"
            exit 0
            ;;
    esac
    shift
done

# Default: show status
show_status

log_success "Charge limiter ready"
