#!/bin/bash
#  LOG CLEAN - Clean system logs
#  Dependencies: journalctl
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
DEFAULT_DAYS=30

# Clean journal logs
clean_journal() {
    local days="${1:-$DEFAULT_DAYS}"
    
    log_info "Cleaning journal logs (last $days days)..."
    
    journalctl --vacuum-time="${days}d"
    
    log_success "Journal logs cleaned (last $days days)"
}

# Clean S1Bs1stem logs
clean_s1b_logs() {
    log_info "Cleaning S1Bs1stem logs..."
    
    local log_dir="$HOME/.local/share/s1b/logs"
    
    if [ -d "$log_dir" ]; then
        # Keep last 7 days of S1Bs1stem logs
        find "$log_dir" -type f -mtime +7d -delete 2>/dev/null || true
        log_success "S1Bs1stem logs cleaned (last 7 days kept)"
    else
        log_warn "S1Bs1stem logs directory not found: $log_dir"
    fi
}

# Show disk usage of journal
show_journal_size() {
    log_info "Checking journal disk usage..."
    
    du -sh /var/log/journal | head -5
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --journal|-j)
            if [ -n "$2" ]; then
                clean_journal "$2"
                shift 2
            else
                clean_journal "$DEFAULT_DAYS"
                shift
            fi
            ;;
        --s1b)
            clean_s1b_logs
            shift
            ;;
        --size)
            show_journal_size
            shift
            ;;
        --all)
            clean_journal "$DEFAULT_DAYS"
            clean_s1b_logs
            show_journal_size
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--journal|--s1b|--size|--all|--days <n>|--help]"
            echo ""
            echo "Options:"
            echo "  --journal, -j     Clean journal logs (default: 30 days)"
            echo "  --journal, -j <n>    Clean last N days"
            echo "  --s1b              Clean S1Bs1stem logs (keep 7 days)"
            echo "  --size              Show journal disk usage"
            echo "  --all               Clean all logs"
            echo "  --days, -d <n>       Set journal cleanup days (default: 30)"
            echo "  --help, -h          Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Default: clean all logs (journal + s1b)
clean_journal "$DEFAULT_DAYS"
clean_s1b_logs
show_journal_size

log_success "Log cleanup completed"
