#!/bin/bash
# ============================================================
#  QT SETUP - Qt Theme Engine (Kvantum + qt5ct)
#  Purpose: Install and configure Qt theme engine
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Setting up Qt Theme Engine (Kvantum + qt5ct)..."

# Install Qt tools
if ! command -v kvantummanager &>/dev/null || ! command -v qt5ct &>/dev/null; then
    log_info "Qt tools not found, installing..."
    sudo pacman -S --needed --noconfirm kvantum qt5ct
    log_success "Qt tools installed"
else
    log_success "Qt tools are already installed"
fi

# Sync configs from dotfiles-s1b
if [ -d "$HOME/Desktop/dotfiles-s1b" ]; then
    log_info "Syncing Qt configs from dotfiles-s1b..."
    
    # Execute Qt orchestration script
    "$S1B_ROOT/scripts/qt/setup.sh"
else
    log_warn "dotfiles-s1b not found, skipping Qt configs..."
fi

log_success "Qt setup completed!"
