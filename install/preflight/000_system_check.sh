#!/bin/bash
# ============================================================
#  SYSTEM CHECK
#  Validate Linux distribution and kernel
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Performing system check..."

# Check if running on Linux
if [ "$(uname)" != "Linux" ]; then
    log_error "Not running on Linux: $(uname)"
    exit 1
fi
log_success "Running on Linux: $(uname -r)"

# Check if Arch Linux
if ! is_arch; then
    log_error "Not Arch Linux: /etc/arch-release not found"
    log_error "S1Bs1stem is designed for Arch Linux (or Arch-based distros)"
    exit 1
fi
log_success "Arch Linux detected"

# Check kernel version
local kernel_version
kernel_version=$(uname -r)
log_info "Kernel version: $kernel_version"

# Check shell
if [ -z "$BASH_VERSION" ]; then
    log_warn "Not running in bash, some scripts may not work"
else
    log_success "Bash version: $BASH_VERSION"
fi

# Check systemd
if command -v systemctl &>/dev/null; then
    log_success "Systemd detected: $(systemctl --version)"
else
    log_warn "Systemd not found"
fi

# Check display server
if [ -n "$WAYLAND_DISPLAY" ]; then
    log_info "Display server: Wayland ($WAYLAND_DISPLAY)"
elif [ -n "$DISPLAY" ]; then
    log_info "Display server: X11 ($DISPLAY)"
else
    log_warn "No display server detected (headless system?)"
fi

log_success "System check passed"
exit 0
