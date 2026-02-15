#!/bin/bash
# ============================================================
#  BATTERY NOTIFY - Battery level notifications
#  Dependencies: upower, notify-send
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check if battery exists
if ! has_battery; then
    log_info "No battery detected (desktop PC). Battery notifications disabled."
    exit 0
fi

# Configuration
WARNING_LEVEL=20
CRITICAL_LEVEL=5
NOTIFICATION_INTERVAL=5  # minutes

# Get battery percentage
get_battery_percentage() {
    upower -e | grep percentage | awk '{print $2}'
}

# Check battery and send notification
check_battery() {
    local percentage
    percentage=$(get_battery_percentage)
    
    local percentage_int
    percentage_int=${percentage%\%}
    
    log_info "Battery level: $percentage"
    
    if [ "$percentage_int" -le "$CRITICAL_LEVEL" ]; then
        notify-send "Battery Critical" "Battery is at $percentage%!" -u critical 2>/dev/null || true
        log_warn "Battery CRITICAL: $percentage%"
    elif [ "$percentage_int" -le "$WARNING_LEVEL" ]; then
        notify-send "Battery Warning" "Battery is at $percentage%" -u normal 2>/dev/null || true
        log_warn "Battery LOW: $percentage%"
    fi
}

# Start battery monitor daemon
start_daemon() {
    log_info "Starting battery notification daemon..."
    log_info "Checking battery every $NOTIFICATION_INTERVAL minutes..."
    
    # Create PID file
    local pid_file="$HOME/.local/share/s1b/battery/notify.pid"
    ensure_dir_exists "$HOME/.local/share/s1b/battery"
    echo $$ > "$pid_file"
    
    # Loop forever checking battery
    while true; do
        check_battery
        sleep $((NOTIFICATION_INTERVAL * 60))
    done
}

# Stop daemon
stop_daemon() {
    local pid_file="$HOME/.local/share/s1b/battery/notify.pid"
    
    if [ ! -f "$pid_file" ]; then
        log_warn "No running daemon found"
        return 0
    fi
    
    local pid
    pid=$(cat "$pid_file")
    
    log_info "Stopping battery notification daemon (PID: $pid)..."
    kill "$pid" 2>/dev/null || true
    rm -f "$pid_file"
    
    log_success "Battery notification daemon stopped"
}

# Check daemon status
daemon_status() {
    local pid_file="$HOME/.local/share/s1b/battery/notify.pid"
    
    if [ -f "$pid_file" ] && ps -p "$(cat "$pid_file")" &>/dev/null; then
        log_info "Battery notification daemon is running (PID: $(cat "$pid_file"))"
        return 0
    else
        log_info "Battery notification daemon is not running"
        return 1
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check|-c)
            check_battery
            shift
            ;;
        --start)
            start_daemon
            ;;
        --stop)
            stop_daemon
            ;;
        --status|-s)
            daemon_status
            ;;
        --help|-h)
            echo "Usage: $0 [--check|--start|--stop|--status|--help]"
            echo ""
            echo "Options:"
            echo "  --check, -c         Check battery level now"
            echo "  --start               Start daemon (checks every $NOTIFICATION_INTERVAL min)"
            echo "  --stop                Stop daemon"
            echo "  --status, -s           Check daemon status"
            echo "  --help, -h            Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default: check battery
check_battery

log_success "Battery notification operation completed"
