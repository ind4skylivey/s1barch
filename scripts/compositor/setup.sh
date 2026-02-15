#!/bin/bash
# ============================================================
#  COMPOSITOR SETUP - Orchestrate Compositor configs from dotfiles-s1b
#  Purpose: Sync Picom compositor configuration
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Compositor configurations from dotfiles-s1b..."

# --- PICOM ---
if [ -d "$DOTFILES_S1B/.config/picom" ]; then
    log_info "Syncing Picom compositor..."
    ensure_dir_exists "$HOME/.config/picom"
    
    # Backup existing
    backup_file "$HOME/.config/picom/picom.conf" 2>/dev/null || true
    
    # Copy Picom config
    rsync -av "$DOTFILES_S1B/.config/picom/" "$HOME/.config/picom/"
    
    log_success "Picom synced"
else
    log_warn "Picom config not found in dotfiles-s1b"
fi

# --- DUNST ---
if [ -d "$DOTFILES_S1B/.config/dunst" ]; then
    log_info "Syncing Dunst notifications..."
    ensure_dir_exists "$HOME/.config/dunst"
    
    # Copy Dunst config
    rsync -av "$DOTFILES_S1B/.config/dunst/" "$HOME/.config/dunst/"
    
    log_success "Dunst synced"
else
    log_warn "Dunst config not found in dotfiles-s1b"
fi

log_success "Compositor configurations synced from dotfiles-s1b!"
