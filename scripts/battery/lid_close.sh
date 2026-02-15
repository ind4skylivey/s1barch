#!/bin/bash
# ============================================================
#  LID CLOSE - Handle laptop lid close events
#  Dependencies: acpi, notify-send
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Check if lid exists
if ! has_lid; then
    log_info "No lid detected (desktop PC). Lid close monitoring disabled."
    exit 0
fi

# Configuration
LID_STATE_FILE="$HOME/.s1b_lid_state"

# Lid state values
readonly LID_STATE_OPEN="open"
readonly LID_STATE_CLOSED="closed"
readonly ACTION_SUSPEND="suspend"
readonly ACTION_LOCK="lock"
readonly ACTION_NONE="nothing"

# Configure lid close action
LID_CLOSE_ACTION="${ACTION_SUSPEND}"  # suspend, lock, lock, nothing

# Get lid state
get_lid_state() {
    cat /proc/acpi/button/lid/LID/state 2>/dev/null || echo "unknown"
}

# Get current lid action
get_lid_action() {
    local state
    state=$(get_lid_state)
    
    case "$state" in
        open)
            echo "$LID_STATE_OPEN"
            ;;
        closed)
            echo "$LID_STATE_CLOSED"
            ;;
        *)
            echo "$state"
            ;;
    esac
}

# Handle lid close event
handle_lid_close() {
    local action="$1"
    local reason="$2"
    
    log_info "Lid closed: Action=$action"
    
    case "$action" in
        suspend)
            log_info "Suspending system..."
            notify-send "Lid" "Lid closed - Suspending..." 2>/dev/null || true
            systemctl suspend
            ;;
        lock)
            log_info "Locking session..."
            notify-send "Lid" "Lid closed - Locking..." 2>/dev/null || true
            loginctl lock-session
            ;;
        nothing)
            log_info "No action - just logging lid close event"
            ;;
        *)
            log_warn "Unknown lid close action: $action"
            ;;
    esac
    
    # Save lid state
    echo "closed" > "$LID_STATE_FILE"
}

# Monitor lid state
monitor_lid() {
    local current_state
    local prev_state="unknown"
    
    while true; do
        current_state=$(get_lid_state)
        
        if [ "$current_state" = "$prev_state" ]; then
            # No change, wait
            sleep 1
            prev_state="$current_state"
            continue
        fi
        
        case "$prev_state" in
            open)
                # Lid is open
                prev_state="open"
                ;;
            closed)
                # Lid is closed
                handle_lid_close "$LID_CLOSE_ACTION" "Lid closed"
                prev_state="closed"
                ;;
        esac
    done
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --monitor)
            monitor_lid
            ;;
        --set-action)
            LID_CLOSE_ACTION="$2"
            shift 2
            ;;
        --action)
            LID_CLOSE_ACTION="$2"
            shift
            ;;
        --state)
            state=$(get_lid_state)
            echo "Current lid state: $state"
            echo ""
            echo "Available actions: suspend, lock, nothing"
            ;;
        --help|-h)
            echo "Usage: $0 [--monitor|--set-action <action>|--action <action>|--state|--help]"
            echo ""
            echo "Options:"
            echo "  --monitor           Monitor lid state continuously"
            echo "  --set-action <action>  Set lid close action (suspend, lock, nothing)"
            "  --action <action>   Execute lid close action manually"
            "  --state            Show current lid state"
            echo "  --help, -h           Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--monitor|--set-action <action>|--action <action>|--state|--help]"
            exit 1
            ;;
        esac
    shift
done

# Default: show lid state
current=$(get_lid_state)
echo "Current lid state: $current"

log_success "Lid close handler ready"
