#!/bin/bash
# ============================================================
#  BATTERY MONITOR - Show battery status with JSON output
#  Dependencies: upower, jq
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Checking battery status..."

# Check if battery exists
if ! has_battery; then
    log_info "No battery detected (desktop PC). Skipping battery monitoring."
    exit 0
fi

# Check battery
if ! command -v upower &>/dev/null; then
    log_error "upower not found. Install: sudo pacman -S upower"
    exit 1
fi

# Get battery info
get_battery_info() {
    # Get all batteries
    local battery_name
    battery_name=$(upower -e | grep "BAT" | head -1 | awk '{print $2}')
    
    # Get percentage
    local percentage
    percentage=$(upower -i "$battery_name" | grep percentage | awk '{print $2}')
    
    # Get state
    local state
    state=$(upower -i "$battery_name" | grep state | awk '{print $2}')
    
    # Get time to empty/full
    local time_empty
    time_empty=$(upower -i "$battery_name" | grep time to empty | awk '{print $3 " "$4}')
    
    local time_full
    time_full=$(upower -i "$battery_name" | grep time to full | awk '{print $3 " "$4}')
    
    # Get power usage
    local power_usage
    power_usage=$(upower -i "$battery_name" | grep "energy rate" | awk '{print $2} " watt')
    
    echo "Percentage: $percentage"
    echo "State: $state"
    echo "Time to empty: $time_empty"
    echo "Time to full: $time_full"
    echo "Power usage: $power_usage"
}

# Display status
display_status() {
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}BATTERY STATUS${COLOR_RESET}"
    echo "═════════════════════════════════"
    echo ""
    
    # Get info
    local battery_info
    battery_info=$(get_battery_info)
    
    echo "$battery_info"
    echo ""
    
    # Get percentage for color
    local percentage
    percentage=$(upower -e | grep "percentage" | awk '{print $2}')
    
    local color
    if [ "${percentage%\%}" -ge 80 ]; then
        color="$COLOR_GREEN"
    elif [ "${percentage%\%}" -ge 20 ]; then
        color="$COLOR_YELLOW"
    else
        color="$COLOR_RED"
    fi
    
    echo -e "Battery Level: ${color}${percentage}${COLOR_RESET}"
    
    # State
    local state
    state=$(upower -e | grep "state" | head -1 | awk '{print $2}')
    
    if [ "$state" = "discharging" ]; then
        echo -e "Status: ${COLOR_YELLOW}Discharging${COLOR_RESET}"
    elif [ "$state" = "charging" ]; then
        echo -e "Status: ${COLOR_GREEN}Charging${COLOR_RESET}"
    elif [ "$state" = "fully-charged" ]; then
        echo -e "Status: ${COLOR_GREEN}Fully Charged${COLOR_RESET}"
    else
        echo -e "Status: $COLOR_Mauve}${state}${COLOR_RESET}"
    fi
    
    echo ""
}

# JSON output
json_output() {
    echo "{"
    
    upower -e -j | jq -r '
        map(
            if .state == "discharging" then
                .percentage + " | " + .time_to_empty
            else
                .percentage + " | " + .time_to_full
            end
        ) + " | " + .energy_rate
    '
    
    echo "}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --json|-j)
            json_output
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--json|--help]"
            echo ""
            echo "Options:"
            echo "  --json, -j    Output in JSON format"
            echo "  --help, -h    Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Default: display status
display_status

log_success "Battery status retrieved"
