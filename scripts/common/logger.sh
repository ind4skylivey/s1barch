#!/bin/bash
# ============================================================
#  S1Bs1stem - ADVANCED LOGGING SYSTEM
#  ============================================================
#  Usage: source ~/Desktop/S1Bs1stem/scripts/common/logger.sh
#  Features: Color logging, file logging, log rotation
#  Inspired by: S1B dotfiles
#  License: MIT
#  Version: 1.0.0
#  ============================================================

# --- CONSTANTS ---
readonly LOG_DIR="$HOME/.s1b_logs"
readonly LOG_FILE="$LOG_DIR/s1b_system.log"
readonly LOG_MAX_SIZE=$((10 * 1024 * 1024))  # 10MB
readonly LOG_RETENTION_DAYS=30

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# --- COLOR DEFINITIONS ---
if [[ -t 1 ]]; then
    readonly COLOR_RED='\033[0;31m'
    readonly COLOR_GREEN='\033[0;32m'
    readonly COLOR_YELLOW='\033[1;33m'
    readonly COLOR_BLUE='\033[0;34m'
    readonly COLOR_MAGENTA='\033[0;35m'
    readonly COLOR_CYAN='\033[0;36m'
    readonly COLOR_BOLD='\033[1m'
    readonly COLOR_RESET='\033[0m'
else
    readonly COLOR_RED=''
    readonly COLOR_GREEN=''
    readonly COLOR_YELLOW=''
    readonly COLOR_BLUE=''
    readonly COLOR_MAGENTA=''
    readonly COLOR_CYAN=''
    readonly COLOR_BOLD=''
    readonly COLOR_RESET=''
fi

# --- LOGGING FUNCTIONS ---
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    # Console output with colors
    case "$level" in
        INFO)
            echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $message"
            ;;
        SUCCESS)
            echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $message"
            ;;
        WARN)
            echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $message"
            ;;
        ERROR)
            echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $message" >&2
            ;;
        DEBUG)
            echo -e "${COLOR_CYAN}[DEBUG]${COLOR_RESET} $message"
            ;;
        RUN)
            echo -e "${COLOR_BOLD}[RUN]${COLOR_RESET} $message"
            ;;
    esac
    
    # File output (no colors)
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Alias functions for convenience
log_info()    { log INFO "$*"; }
log_success() { log SUCCESS "$*"; }
log_warn()    { log WARN "$*"; }
log_error()   { log ERROR "$*"; }
log_debug()   { log DEBUG "$*"; }
log_run()     { log RUN "$*"; }

# --- LOG ROTATION ---
rotate_logs() {
    # Check if log file exists
    if [ ! -f "$LOG_FILE" ]; then
        return 0
    fi
    
    # Check file size
    local file_size
    file_size="$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null)"
    
    if [ "$file_size" -gt "$LOG_MAX_SIZE" ]; then
        log_info "Rotating log file..."
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"
    fi
    
    # Delete old logs
    find "$LOG_DIR" -name "*.log" -mtime +$LOG_RETENTION_DAYS -delete
}

# --- LOG QUERY FUNCTIONS ---
log_last_errors() {
    local count="${1:-10}"
    grep "ERROR" "$LOG_FILE" | tail -n "$count"
}

log_last_warns() {
    local count="${1:-10}"
    grep "WARN" "$LOG_FILE" | tail -n "$count"
}

log_recent() {
    local count="${1:-20}"
    tail -n "$count" "$LOG_FILE"
}

log_tail() {
    tail -f "$LOG_FILE"
}

# --- SESSION LOGGING ---
start_log_session() {
    local session_name="$1"
    local timestamp
    timestamp="$(date '+%Y%m%d_%H%M%S')"
    
    local session_log="$LOG_DIR/sessions/${session_name}_${timestamp}.log"
    mkdir -p "$(dirname "$session_log")"
    
    echo "=== Session started at $(date) ===" > "$session_log"
    echo "$session_log"
}

end_log_session() {
    local session_log="$1"
    if [ -f "$session_log" ]; then
        echo "=== Session ended at $(date) ===" >> "$session_log"
    fi
}

# --- LOG ANALYSIS ---
log_stats() {
    local info_count warn_count error_count debug_count
    
    info_count=$(grep -c "\[INFO\]" "$LOG_FILE" 2>/dev/null || echo "0")
    warn_count=$(grep -c "\[WARN\]" "$LOG_FILE" 2>/dev/null || echo "0")
    error_count=$(grep -c "\[ERROR\]" "$LOG_FILE" 2>/dev/null || echo "0")
    debug_count=$(grep -c "\[DEBUG\]" "$LOG_FILE" 2>/dev/null || echo "0")
    
    echo "=== S1Bs1stem Log Statistics ==="
    echo "Total lines: $(wc -l < "$LOG_FILE")"
    echo "INFO: $info_count"
    echo "WARN: $warn_count"
    echo "ERROR: $error_count"
    echo "DEBUG: $debug_count"
}

# --- CLEANUP ---
clean_old_logs() {
    log_info "Cleaning logs older than $LOG_RETENTION_DAYS days..."
    find "$LOG_DIR" -name "*.log*" -mtime +$LOG_RETENTION_DAYS -delete
    log_success "Old logs cleaned"
}

# Initialize: Rotate old logs
rotate_logs

# Export functions for use in other scripts
export -f log
export -f log_info
export -f log_success
export -f log_warn
export -f log_error
export -f log_debug
export -f log_run
export -f rotate_logs
export -f log_last_errors
export -f log_last_warns
export -f log_recent
export -f log_tail
export -f log_stats
export -f start_log_session
export -f end_log_session
export -f clean_old_logs
