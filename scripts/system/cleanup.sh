#!/bin/bash
# ============================================================
#  SYSTEM CLEANUP - Clean system cache, logs, and temp files
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Starting system cleanup..."

# Clean pacman cache
log_info "Cleaning pacman cache..."
sudo pacman -Sc --noconfirm 2>/dev/null || log_warn "Pacman cache cleanup failed"

# Clean yay cache
if command -v yay &>/dev/null; then
    log_info "Cleaning yay cache..."
    yay -Sc --noconfirm --aur 2>/dev/null || log_warn "Yay cache cleanup failed"
fi

# Clean temp files
log_info "Cleaning temp files..."
rm -rf /tmp/* 2>/dev/null || true
rm -rf /var/tmp/* 2>/dev/null || true

# Clean old logs (keep last 30 days)
log_info "Cleaning old logs (last 30 days)..."
journalctl --vacuum-time=30d 2>/dev/null || log_warn "Journal cleanup failed"

# Clean S1Bs1stem logs (keep last 7 days)
log_info "Cleaning S1Bs1stem logs..."
find "$HOME/.local/share/s1b/logs" -type f -mtime +7d -delete 2>/dev/null || true

# Free up disk space
log_info "Running TRIM on SSD (if available)..."
# Check if any rotational file exists (indicates SSD)
for rotational in /sys/block/*/queue/rotational; do
    if [ -f "$rotational" ]; then
        sudo fstrim -av / 2>/dev/null || log_warn "TRIM failed or not supported"
        break
    fi
done

log_success "System cleanup completed"
log_info "Disk space freed:"
df -h / | grep -E "^/dev/"
