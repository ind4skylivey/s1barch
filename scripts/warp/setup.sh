#!/bin/bash
# ============================================================
#  WARP SETUP - Orchestrate Warp configs from dotfiles-s1b
#  Purpose: Sync Warp Terminal + 12 cyberpunk themes
#           Source aliases in .zshrc
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Warp Terminal configurations from dotfiles-s1b..."

# --- WARP CONFIGS ---
if [ -d "$DOTFILES_S1B/.config/warp-terminal" ]; then
    log_info "Syncing Warp Terminal configs..."
    ensure_dir_exists "$HOME/.config/warp-terminal"
    
    backup_file "$HOME/.config/warp-terminal/ALIASES.zsh" 2>/dev/null || true
    
    rsync -av "$DOTFILES_S1B/.config/warp-terminal/" "$HOME/.config/warp-terminal/"
    
    log_success "Warp Terminal configs synced"
else
    log_warn "Warp Terminal configs not found in dotfiles-s1b"
fi

# --- WARP THEMES ---
if [ -d "$DOTFILES_S1B/.local/share/warp-terminal/themes" ]; then
    log_info "Syncing Warp Terminal themes (12 cyberpunk themes)..."
    ensure_dir_exists "$HOME/.local/share/warp-terminal/themes"
    
    rsync -av "$DOTFILES_S1B/.local/share/warp-terminal/themes/" "$HOME/.local/share/warp-terminal/themes/"
    
    log_success "Warp Terminal themes synced"
else
    log_warn "Warp Terminal themes not found in dotfiles-s1b"
fi

# --- SOURCE ALIASES IN .zshrc ---
log_info "Configuring Warp aliases in .zshrc..."

WARP_ALIAS_SOURCE='# Warp Terminal Aliases (S1Bs1stem)
# Source 40+ Red Team, Exploit Dev, and Full Stack aliases
if [ -f "$HOME/.config/warp-terminal/ALIASES.zsh" ]; then
    source "$HOME/.config/warp-terminal/ALIASES.zsh"
fi'

if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "warp-terminal/ALIASES.zsh" "$HOME/.zshrc" 2>/dev/null; then
        log_info "Adding Warp aliases to ~/.zshrc..."
        echo "$WARP_ALIAS_SOURCE" >> "$HOME/.zshrc"
        log_success "Warp aliases added to ~/.zshrc"
    else
        log_success "Warp aliases already configured in ~/.zshrc"
    fi
else
    log_warn '$HOME/.zshrc not found, skipping Warp aliases configuration'
fi

log_success "Warp Terminal configurations synced from dotfiles-s1b!"
log_info "Warp aliases (40+ commands) now available in ZSH shell"
log_info "Try: recon, burp, ghidra, pattern-gen, gdb-debug, scan-commit"
