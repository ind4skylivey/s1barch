#!/bin/bash
# ============================================================
#  FILE MANAGER SETUP - Orchestrate File Manager configs from dotfiles-s1b
#  Purpose: Sync Yazi, PCManFM-Qt file managers
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing File Manager configurations from dotfiles-s1b..."

# --- YAZI ---
if [ -d "$DOTFILES_S1B/.config/yazi" ]; then
    log_info "Syncing Yazi file manager..."
    ensure_dir_exists "$HOME/.config/yazi"
    
    # Copy Yazi config
    rsync -av "$DOTFILES_S1B/.config/yazi/" "$HOME/.config/yazi/"
    
    log_success "Yazi synced"
else
    log_warn "Yazi config not found in dotfiles-s1b"
fi

# --- PCMANFM-QT ---
if [ -d "$DOTFILES_S1B/.config/pcmanfm-qt" ]; then
    log_info "Syncing PCManFM-Qt..."
    ensure_dir_exists "$HOME/.config/pcmanfm-qt"
    
    # Copy PCManFM-Qt config
    rsync -av "$DOTFILES_S1B/.config/pcmanfm-qt/" "$HOME/.config/pcmanfm-qt/"
    
    # Set executable permissions for actions
    find "$HOME/.config/pcmanfm-qt/default/actions" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    log_success "PCManFM-Qt synced"
else
    log_warn "PCManFM-Qt config not found in dotfiles-s1b"
fi

log_success "File Manager configurations synced from dotfiles-s1b!"
