#!/bin/bash
# ============================================================
#  WOFI SETUP - Wayland Launcher
#  Purpose: Install and configure Wofi launcher
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Setting up Wofi launcher (Wayland)..."

# Install Wofi
if ! command -v wofi &>/dev/null; then
    log_info "Wofi not found, installing..."
    sudo pacman -S --needed --noconfirm wofi
    log_success "Wofi installed"
else
    log_success "Wofi is already installed"
fi

# Configure Wofi
WOFI_CONFIG_DIR="$HOME/.config/wofi"
ensure_dir_exists "$WOFI_CONFIG_DIR"

# Sync configs from dotfiles-s1b
if [ -d "$HOME/Desktop/dotfiles-s1b/.config/wofi" ]; then
    log_info "Configuring Wofi from dotfiles-s1b..."
    
    # Backup existing config
    if [ -f "$WOFI_CONFIG_DIR/style.css" ]; then
        backup_file "$WOFI_CONFIG_DIR/style.css"
    fi
    
    # Copy Wofi config
    cp "$HOME/Desktop/dotfiles-s1b/.config/wofi/style.css" "$WOFI_CONFIG_DIR/"
    log_success "Wofi configuration synced"
else
    log_warn "Wofi config not found in dotfiles-s1b, skipping..."
fi

log_success "Wofi setup completed!"
