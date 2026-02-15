#!/bin/bash
# ============================================================
#  MULTIPLEXER SETUP - Orchestrate Terminal Multiplexers from dotfiles-s1b
#  Purpose: Sync Tmux, Zellij multiplexers
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Terminal Multiplexer configurations from dotfiles-s1b..."

# --- TMUX ---
if [ -d "$DOTFILES_S1B/.config/tmux" ] || [ -f "$DOTFILES_S1B/.tmux.conf" ]; then
    log_info "Syncing Tmux..."
    ensure_dir_exists "$HOME/.config/tmux"

    # Copy Tmux config
    if [ -d "$DOTFILES_S1B/.config/tmux" ]; then
        rsync -av "$DOTFILES_S1B/.config/tmux/" "$HOME/.config/tmux/"
    fi
    
    if [ -f "$DOTFILES_S1B/.tmux.conf" ]; then
        cp "$DOTFILES_S1B/.tmux.conf" "$HOME/.tmux.conf"
    fi
    
    log_success "Tmux synced"
else
    log_warn "Tmux config not found in dotfiles-s1b"
fi

# --- ZELLIJ ---
if [ -d "$DOTFILES_S1B/.config/zellij" ]; then
    log_info "Syncing Zellij..."
    ensure_dir_exists "$HOME/.config/zellij"
    
    # Backup existing
    backup_file "$HOME/.config/zellij/config.kdl" 2>/dev/null || true
    
    # Copy Zellij config
    rsync -av "$DOTFILES_S1B/.config/zellij/" "$HOME/.config/zellij/"
    
    log_success "Zellij synced"
else
    log_warn "Zellij config not found in dotfiles-s1b"
fi

log_success "Terminal Multiplexer configurations synced from dotfiles-s1b!"
