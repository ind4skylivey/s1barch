#!/bin/bash
# ============================================================
#  EDITOR SETUP - Orchestrate Editor configs from dotfiles-s1b
#  Purpose: Sync Neovim, Emacs, Micro, Helix configs
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Editor configurations from dotfiles-s1b..."

# --- NEOVIM ---
if [ -d "$DOTFILES_S1B/.config/nvim" ]; then
    log_info "Syncing Neovim..."
    ensure_dir_exists "$HOME/.config/nvim"
    
    # Backup existing
    backup_file "$HOME/.config/nvim" 2>/dev/null || true
    
    # Copy Neovim config
    rsync -av "$DOTFILES_S1B/.config/nvim/" "$HOME/.config/nvim/"
    
    log_success "Neovim synced"
else
    log_warn "Neovim config not found in dotfiles-s1b"
fi

# --- DOOM EMACS ---
if [ -d "$DOTFILES_S1B/.doom.d" ]; then
    log_info "Syncing Doom Emacs..."
    ensure_dir_exists "$HOME/.doom.d"
    
    # Backup existing
    backup_file "$HOME/.doom.d" 2>/dev/null || true
    
    # Copy Doom Emacs config
    rsync -av "$DOTFILES_S1B/.doom.d/" "$HOME/.doom.d/"
    
    log_success "Doom Emacs synced"
else
    log_warn "Doom Emacs config not found in dotfiles-s1b"
fi

# --- MICRO ---
if [ -d "$DOTFILES_S1B/.config/micro" ]; then
    log_info "Syncing Micro editor..."
    ensure_dir_exists "$HOME/.config/micro"
    
    # Copy Micro config
    rsync -av "$DOTFILES_S1B/.config/micro/" "$HOME/.config/micro/"
    
    log_success "Micro synced"
else
    log_warn "Micro config not found in dotfiles-s1b"
fi

# --- HELIX ---
if [ -d "$DOTFILES_S1B/.config/helix" ]; then
    log_info "Syncing Helix editor..."
    ensure_dir_exists "$HOME/.config/helix"
    
    # Copy Helix config
    rsync -av "$DOTFILES_S1B/.config/helix/" "$HOME/.config/helix/"
    
    log_success "Helix synced"
else
    log_warn "Helix config not found in dotfiles-s1b"
fi

log_success "All editor configurations synced from dotfiles-s1b!"
