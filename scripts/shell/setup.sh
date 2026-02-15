#!/bin/bash
# ============================================================
#  SHELL SETUP - Orchestrate Shell configs from dotfiles-s1b
#  Purpose: Sync ZSH, Fish, Starship, Powerline10k configs
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Shell configurations from dotfiles-s1b..."

# --- ZSH ---
if [ -d "$DOTFILES_S1B/.config/zsh" ] || [ -f "$DOTFILES_S1B/.zshrc" ]; then
    log_info "Syncing ZSH shell..."
    
    # Backup existing
    backup_file "$HOME/.zshrc" 2>/dev/null || true
    
    # Sync .config/zsh
    if [ -d "$DOTFILES_S1B/.config/zsh" ]; then
        ensure_dir_exists "$HOME/.config/zsh"
        rsync -av "$DOTFILES_S1B/.config/zsh/" "$HOME/.config/zsh/"
        log_success "ZSH config synced"
    fi
    
    # Copy .zshrc
    if [ -f "$DOTFILES_S1B/.zshrc" ]; then
        cp "$DOTFILES_S1B/.zshrc" "$HOME/.zshrc"
        log_success ".zshrc synced"
    fi
    
    # Copy .p10k.zsh
    if [ -f "$DOTFILES_S1B/.p10k.zsh" ]; then
        cp "$DOTFILES_S1B/.p10k.zsh" "$HOME/.p10k.zsh"
        log_success ".p10k.zsh synced"
    fi
else
    log_warn "ZSH config not found in dotfiles-s1b"
fi

# --- FISH ---
if [ -d "$DOTFILES_S1B/.config/fish" ]; then
    log_info "Syncing Fish shell..."
    ensure_dir_exists "$HOME/.config/fish"
    
    # Copy Fish config
    rsync -av "$DOTFILES_S1B/.config/fish/" "$HOME/.config/fish/"
    
    log_success "Fish synced"
else
    log_warn "Fish config not found in dotfiles-s1b"
fi

# --- STARSHIP ---
if [ -f "$DOTFILES_S1B/starship.toml" ]; then
    log_info "Syncing Starship prompt..."
    
    # Backup existing
    backup_file "$HOME/.config/starship.toml" 2>/dev/null || true
    
    # Copy Starship config
    cp "$DOTFILES_S1B/starship.toml" "$HOME/.config/starship.toml"
    
    log_success "Starship synced"
else
    log_warn "Starship config not found in dotfiles-s1b"
fi

# --- STARSHIP FISH INTEGRATION ---
if [ -d "$DOTFILES_S1B/.config/fish/functions" ]; then
    log_info "Syncing Starship Fish integration..."
    ensure_dir_exists "$HOME/.config/fish/functions"
    
    # Copy Fish functions
    cp "$DOTFILES_S1B/.config/fish/functions/starship_prompt.fish" "$HOME/.config/fish/functions/" 2>/dev/null || log_warn "Starship Fish function not found"
fi

log_success "All shell configurations synced from dotfiles-s1b!"
