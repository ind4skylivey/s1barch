#!/bin/bash
# ============================================================
#  NETWORK CHECK
#  Validate internet connection and network configuration
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Checking network connection..."

# Test internet connectivity
log_info "Testing internet connection..."
if ! is_connected; then
    log_error "No internet connection detected!"
    log_error "Please check your network and try again."
    log_error "Network is required for:"
    echo "  - Installing packages from official repositories"
    echo "  - Cloning git repositories"
    echo "  - Downloading configuration files"
    exit 1
fi
log_success "Internet connection OK"

# Get local IP
local local_ip
local_ip=$(get_local_ip)
log_info "Local IP: $local_ip"

# Check DNS resolution
log_info "Testing DNS resolution..."
if host google.com &>/dev/null; then
    log_success "DNS resolution OK"
else
    log_warn "DNS resolution failed"
    log_warn "You may have issues with package downloads"
fi

# Check download speed (simple test)
log_info "Testing download speed..."
if command -v curl &>/dev/null; then
    local download_time
    download_time=$(time curl -o /dev/null -s -w '%{time_total}' http://speedtest.tele2.net/10mb.zip 2>&1 | grep real | awk '{print $2}')
    
    if [ -n "$download_time" ]; then
        log_info "Download test completed in: ${download_time}s"
    fi
fi

# Check for common network tools
local network_tools=(
    "ping"
    "curl"
    "wget"
    "ssh"
    "git"
)

for tool in "${network_tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
        log_success "$tool is installed"
    else
        log_warn "$tool is not installed (may be needed)"
    fi
done

log_success "Network check passed"
exit 0
