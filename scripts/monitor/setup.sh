#!/bin/bash
# ============================================================
#  MONITOR SETUP - Orchestrate Monitor configs from dotfiles-s1b
#  Purpose: Sync BTop, Cava, Fastfetch configs
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Monitor configurations from dotfiles-s1b..."

# --- BTOP ---
if [ -d "$DOTFILES_S1B/.config/btop" ]; then
    log_info "Syncing BTop..."
    ensure_dir_exists "$HOME/.config/btop"
    
    # Copy BTop config
    rsync -av "$DOTFILES_S1B/.config/btop/" "$HOME/.config/btop/"
    
    log_success "BTop synced"
else
    log_warn "BTop config not found in dotfiles-s1b"
fi

# --- CAVA ---
if [ -d "$DOTFILES_S1B/.config/cava" ]; then
    log_info "Syncing Cava..."
    ensure_dir_exists "$HOME/.config/cava"
    
    # Copy Cava config
    rsync -av "$DOTFILES_S1B/.config/cava/" "$HOME/.config/cava/"
    
    log_success "Cava synced"
else
    log_warn "Cava config not found in dotfiles-s1b"
fi

# --- FASTFETCH ---
if [ -d "$DOTFILES_S1B/.config/fastfetch" ]; then
    log_info "Syncing Fastfetch..."
    ensure_dir_exists "$HOME/.config/fastfetch"
    
    # Copy Fastfetch config
    rsync -av "$DOTFILES_S1B/.config/fastfetch/" "$HOME/.config/fastfetch/"
    
    log_success "Fastfetch synced"
else
    log_warn "Fastfetch config not found in dotfiles-s1b"
fi

log_success "All monitor configurations synced from dotfiles-s1b!"
