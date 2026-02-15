#!/bin/bash
# ============================================================
#  DWM AUTOSTART - Manage DWM autostart applications
#  Purpose: Start applications automatically when DWM launches
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly AUTOSTART_FILE="$HOME/.config/dwm/autostart.sh"
readonly AUTOSTART_LOCK="$HOME/.s1b_autostart_lock"
readonly AUTOSTART_LOG="$HOME/.s1b_logs/autostart.log"

# Autostart applications configuration
declare -A AUTOSTART_APPS=(
    # System monitoring
    ["picom"]="picom &"                           # Compositor
    ["unclutter"]="unclutter --fork &"            # Hide mouse cursor
    ["redshift"]="redshift -t 6500:3500 &"        # Night light
    ["dunst"]="dunst &"                           # Notification daemon
    ["nm-applet"]="nm-applet &"                   # Network manager applet
    ["blueman-applet"]="blueman-applet &"         # Bluetooth applet
    ["volumeicon"]="volumeicon &"                 # Volume tray icon
    ["pasystray"]="pasystray &"                   # PulseAudio tray

    # Utility apps
    ["flameshot"]="flameshot &"                   # Screenshot tool
    ["clipmenud"]="clipmenud &"                   # Clipboard daemon
    ["xautolock"]="xautolock -time 10 -locker 'slock' &"  # Auto-lock

    # Wallpaper (if not using feh in .xinitrc)
    ["feh"]="$HOME/.fehbg &"                         # Restore wallpaper
)

# Desktop-specific (no battery/lid)
readonly DESKTOP_AUTOSTART=(
    "picom"
    "unclutter"
    "redshift"
    "dunst"
    "nm-applet"
    "blueman-applet"
    "volumeicon"
    "pasystray"
    "flameshot"
    "clipmenud"
    "feh"
)

# Laptop-specific (includes battery/lid monitoring)
readonly LAPTOP_AUTOSTART=(
    "picom"
    "unclutter"
    "redshift"
    "dunst"
    "nm-applet"
    "blueman-applet"
    "volumeicon"
    "pasystray"
    "flameshot"
    "clipmenud"
    "feh"
    # "xautolock"  # Uncomment for auto-lock
)

# Check if app is installed
is_app_installed() {
    local app="$1"
    command -v "$app" &>/dev/null
}

# Check if app is already running
is_app_running() {
    local app="$1"
    pgrep -x "$app" &>/dev/null
}

# Start application with error handling
start_app() {
    local app="$1"
    local command="${AUTOSTART_APPS[$app]}"

    if [ -z "$command" ]; then
        log_error "No command defined for: $app"
        return 1
    fi

    log_info "Starting: $app"

    # Check if already running
    if is_app_running "$app"; then
        log_debug "Already running: $app"
        return 0
    fi

    # Check if installed
    if ! is_app_installed "$app"; then
        log_debug "Not installed: $app (skipping)"
        return 0
    fi

    # Start in background
    eval "$command" &>/dev/null || log_warn "Failed to start: $app"

    # Small delay to avoid startup race conditions
    sleep 0.1
}

# Start all autostart applications
start_all() {
    log_info "Starting DWM autostart applications..."

    # Determine which profile to use (desktop vs laptop)
    local apps_to_start=()
    if has_battery; then
        log_info "Using laptop autostart profile"
        apps_to_start=("${LAPTOP_AUTOSTART[@]}")
    else
        log_info "Using desktop autostart profile"
        apps_to_start=("${DESKTOP_AUTOSTART[@]}")
    fi

    # Start each app
    for app in "${apps_to_start[@]}"; do
        start_app "$app"
    done

    log_success "Autostart completed"
}

# Start specific application
start_specific() {
    local app="$1"

    if [ -z "$app" ]; then
        log_error "Application name required"
        echo "Usage: $0 start <app_name>"
        exit 1
    fi

    if [ -z "${AUTOSTART_APPS[$app]:-}" ]; then
        log_error "Unknown application: $app"
        echo "Available applications:"
        for a in "${!AUTOSTART_APPS[@]}"; do
            echo "  - $a"
        done
        exit 1
    fi

    start_app "$app"
}

# Stop application
stop_app() {
    local app="$1"

    if [ -z "$app" ]; then
        log_error "Application name required"
        exit 1
    fi

    if ! is_app_running "$app"; then
        log_warn "Not running: $app"
        return 0
    fi

    log_info "Stopping: $app"
    pkill -x "$app" || true

    log_success "Stopped: $app"
}

# Restart application
restart_app() {
    local app="$1"

    log_info "Restarting: $app"
    stop_app "$app"
    sleep 0.5
    start_app "$app"
}

# List autostart applications
list_apps() {
    echo ""
    echo -e "${COLOR_BOLD}DWM Autostart Applications${COLOR_RESET}"
    echo "═════════════════════════════════"
    echo ""

    echo -e "${COLOR_MAuve}Applications:${COLOR_RESET}"
    echo ""

    for app in "${!AUTOSTART_APPS[@]}"; do
        local status
        if is_app_installed "$app"; then
            if is_app_running "$app"; then
                status="${COLOR_GREEN}running${COLOR_RESET}"
            else
                status="${COLOR_YELLOW}stopped${COLOR_RESET}"
            fi

            echo -e "  ${COLOR_TEXT}${app}${COLOR_RESET}"
            echo -e "    Status: $status"
            echo -e "    Command: ${COLOR_SUBTEXT}${AUTOSTART_APPS[$app]}${COLOR_RESET}"
            echo ""
        else
            echo -e "  ${COLOR_TEXT}${app}${COLOR_RESET}"
            echo -e "    Status: ${COLOR_RED}not installed${COLOR_RESET}"
            echo -e "    Command: ${COLOR_SUBTEXT}${AUTOSTART_APPS[$app]}${COLOR_RESET}"
            echo ""
        fi
    done
}

# Generate autostart file
generate_autostart_file() {
    log_info "Generating autostart file: $AUTOSTART_FILE"

    cat > "$AUTOSTART_FILE" << 'EOF'
#!/bin/bash
# DWM Autostart Script
# This file is automatically generated by S1Bs1stem
# You can edit this file to customize autostart applications

# Source S1Bs1stem autostart function
source "$HOME/Desktop/S1Bs1stem/scripts/dwm/autostart.sh"

# Start all applications
start_all

# Add custom autostart commands below
# Example:
# flameshot &
# discord &
# slack &
EOF

    chmod +x "$AUTOSTART_FILE"

    log_success "Autostart file created: $AUTOSTART_FILE"
}

# Check if DWM is starting (called from .xinitrc)
is_dwm_startup() {
    # Check if we're being sourced from xinit
    if [ "${0##*/}" = "xinit" ] || [ "${0##*/}" = ".xinitrc" ]; then
        return 0
    fi

    # Check if DWM is about to start
    if check_dwm_running || pgrep -x "X" &>/dev/null; then
        return 0
    fi

    return 1
}

# Main function
main() {
    local action="${1:-start}"

    # Acquire lock to prevent multiple instances
    acquire_lock "$AUTOSTART_LOCK"

    # Logging
    mkdir -p "$(dirname "$AUTOSTART_LOG")"
    echo "=== DWM Autostart at $(date) ===" >> "$AUTOSTART_LOG"

    case "$action" in
        start|all)
            start_all
            ;;
        start-one|start-app)
            start_specific "$2"
            ;;
        stop)
            stop_app "$2"
            ;;
        restart)
            restart_app "$2"
            ;;
        list|ls)
            list_apps
            ;;
        generate|gen)
            generate_autostart_file
            ;;
        status)
            list_apps
            ;;
        *)
            log_error "Invalid action: $action"
            echo ""
            echo "Usage: $0 <action> [app_name]"
            echo ""
            echo "Actions:"
            echo "  start       Start all autostart applications"
            echo "  start-app   Start specific application"
            echo "  stop        Stop specific application"
            echo "  restart     Restart specific application"
            echo "  list        List all applications and their status"
            echo "  generate    Generate autostart file for .xinitrc"
            echo "  status      Show application status"
            echo ""
            exit 1
            ;;
    esac

    # Release lock
    release_lock "$AUTOSTART_LOCK"
}

main "$@"

log_success "DWM autostart ready"
