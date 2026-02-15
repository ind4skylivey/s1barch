#!/bin/bash
# ============================================================
#  DISK SPACE CHECK
#  Validate available disk space for installation
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Checking disk space..."

# Check available space in home directory
available_gb=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | tr -d 'G')
total_gb=$(df -BG "$HOME" | awk 'NR==2 {print $2}' | tr -d 'G')
used_gb=$(df -BG "$HOME" | awk 'NR==2 {print $3}' | tr -d 'G')

log_info "Disk space usage:"
echo "  Total: ${total_gb}GB"
echo "  Used: ${used_gb}GB"
echo "  Available: ${available_gb}GB"
echo ""

# Minimum space requirements
min_required_gb=5
recommended_gb=10

if [ "$available_gb" -lt "$min_required_gb" ]; then
    log_error "Insufficient disk space!"
    log_error "Available: ${available_gb}GB (min required: ${min_required_gb}GB)"
    log_error "Please free up at least $((min_required_gb - available_gb))GB"
    exit 1
elif [ "$available_gb" -lt "$recommended_gb" ]; then
    log_warn "Low disk space warning"
    log_warn "Available: ${available_gb}GB (recommended: ${recommended_gb}GB)"
    log_warn "Installation may succeed, but you'll have limited space"
else
    log_success "Disk space OK: ${available_gb}GB available"
fi

# Check inode usage if available
if command -v df &>/dev/null && df -i "$HOME" &>/dev/null; then
    inodes_available=$(df -i "$HOME" | awk 'NR==2 {print $4}')
    inodes_total=$(df -i "$HOME" | awk 'NR==2 {print $2}')

    # Only calculate if inodes_total > 0
    if [ "$inodes_total" -gt 0 ] 2>/dev/null; then
        inodes_used_percent=$(echo "scale=0; ($inodes_total - $inodes_available) * 100 / $inodes_total" | bc 2>/dev/null || echo "0")

        log_info "Inode usage: ${inodes_used_percent}%"

        if [ "${inodes_used_percent%.*}" -gt 90 ] 2>/dev/null; then
            log_warn "High inode usage detected (>90%)"
            log_warn "This may cause issues with small files"
        fi
    else
        log_debug "Inode count not available for this filesystem"
    fi
fi

log_success "Disk space check passed"
exit 0
