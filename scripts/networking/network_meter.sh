#!/bin/bash
# ============================================================
#  NETWORK METER - Network bandwidth meter daemon
#  Dependencies: speedtest-cli
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
SPEEDTEST_INTERVAL=300  # 5 minutes
HISTORY_DIR="$HOME/.local/share/s1b/networking"
HISTORY_FILE="$HISTORY_DIR/network_meter_history.csv"

# Create directory
ensure_dir_exists "$HISTORY_DIR"

# Create history file
if [ ! -f "$HISTORY_FILE" ]; then
    echo "timestamp,download_mbps,upload_mbps,download_mbps,upload_mbps,download_ms,upload_ms" > "$HISTORY_FILE"
fi

# Run speed test
run_speedtest() {
    log_info "Running speed test..."
    
    if ! command -v speedtest-cli &>/dev/null; then
        log_error "speedtest-cli not found. Install with: yay -S speedtest-cli"
        return 1
    fi
    
    # Run speed test
    local result
    result=$(speedtest-cli --secure --json 2>/dev/null)
    
    local download
    local upload
    local ping
    
    download=$(echo "$result" | jq -r '.download.bandwidth')
    upload=$(echo "$result" | jq -r '.upload.bandwidth')
    ping=$(echo "$result" | jq -r '.ping.latency')
    
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_Mauve}SPEED TEST RESULTS${COLOR_RESET}"
    echo "═════════════════════════════════"
    echo ""
    echo -e "${COLOR_GREEN}DOWNLOAD${COLOR_RESET}"
    echo "  Rate: $download"
    echo -e "${COLOR_GREEN}UPLOAD${COLOR_RESET}"
    echo "  Rate: $upload"
    echo -e "${COLOR_GREEN}LATENCY${COLOR_RESET}"
    echo "  Ping: $ping"
    echo ""
    
    # Save to history
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp,$download,$upload" >> "$HISTORY_FILE"
    
    log_success "Speed test completed and saved to history"
}

# Show history
show_history() {
    log_info "Network meter history:"
    echo ""
    
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "No history available"
        return 0
    fi
    
    echo "History file: $HISTORY_FILE"
    echo ""
    tail -20 "$HISTORY_FILE"
    echo ""
    
    local count
    count=$(wc -l < "$HISTORY_FILE")
    echo "Total measurements: $count"
}

# Clear history
clear_history() {
    log_info "Clearing network meter history..."

    : > "$HISTORY_FILE"

    log_success "History cleared"
}

# Start daemon
start_daemon() {
    log_info "Starting network meter daemon..."
    log_info "Running speed test every $((SPEEDTEST_INTERVAL / 60)) minutes..."
    
    # Create PID file
    local pid_file="$HISTORY_DIR/daemon.pid"
    echo $$ > "$pid_file"
    
    # Run speed tests in loop
    while true; do
        run_speedtest
        sleep "$SPEEDTEST_INTERVAL"
    done
}

# Stop daemon
stop_daemon() {
    local pid_file="$HISTORY_DIR/daemon.pid"
    
    if [ ! -f "$pid_file" ]; then
        log_warn "No running daemon found"
        return 0
    fi
    
    local pid
    pid=$(cat "$pid_file")
    
    log_info "Stopping network meter daemon (PID: $pid)..."
    kill "$pid"  2>/dev/null || true
    rm -f "$pid_file"
    
    log_success "Daemon stopped"
}

# Check daemon status
daemon_status() {
    local pid_file="$HISTORY_DIR/daemon.pid"
    
    if [ -f "$pid_file" ] && ps -p "$(cat "$pid_file")" &>/dev/null; then
        log_info "Network meter daemon is running (PID: $(cat $pid_file))"
        return 0
    else
        log_info "Network meter daemon is not running"
        return 1
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --test|-t)
            run_speedtest
            shift
            ;;
        --history|-h)
            show_history
            shift
            ;;
        --clear|-c)
            clear_history
            shift
            ;;
        --start)
            start_daemon
            ;;
        --stop)
            stop_daemon
            ;;
        --status)
            daemon_status
            ;;
        --help)
            echo "Usage: $0 [--test|--history|--clear|--start|--stop|--status|--help]"
            echo ""
            echo "Options:"
            echo "  --test, -t          Run single speed test"
            echo "  --history, -h       Show test history"
            echo "  --clear, -c         Clear test history"
            echo "  --start              Start daemon (runs tests every 5 min)"
            echo "  --stop               Stop daemon"
            echo "  --status             Check daemon status"
            echo "  --help               Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Default: run single test
run_speedtest

log_success "Network meter operation completed"
