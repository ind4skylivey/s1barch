#!/bin/bash
# ============================================================
#  TERMINAL SETUP - Orchestrate Terminal configs from dotfiles-s1b
#  Purpose: Sync Kitty, Alacritty, Helix terminal configs
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Terminal configurations from dotfiles-s1b..."

# --- KITTY ---
if [ -d "$DOTFILES_S1B/.config/kitty" ]; then
    log_info "Syncing Kitty terminal..."
    ensure_dir_exists "$HOME/.config/kitty"
    
    # Backup existing
    backup_file "$HOME/.config/kitty/kitty.conf" 2>/dev/null || true
    
    # Copy Kitty config
    rsync -av "$DOTFILES_S1B/.config/kitty/" "$HOME/.config/kitty/"
    
    # Set executable permissions for kitty scripts
    find "$HOME/.config/kitty" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    
    log_success "Kitty synced"
else
    log_warn "Kitty config not found in dotfiles-s1b"
fi

# --- ALACRITTY ---
if [ -d "$DOTFILES_S1B/.config/alacritty" ]; then
    log_info "Syncing Alacritty terminal..."
    ensure_dir_exists "$HOME/.config/alacritty"
    
    # Copy Alacritty config
    rsync -av "$DOTFILES_S1B/.config/alacritty/" "$HOME/.config/alacritty/"
    
    log_success "Alacritty synced"
else
    log_warn "Alacritty config not found in dotfiles-s1b"
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

# --- KVANTUM ---
if [ -d "$DOTFILES_S1B/.config/Kvantum" ]; then
    log_info "Syncing Kvantum theme..."
    ensure_dir_exists "$HOME/.config/Kvantum"
    
    # Copy Kvantum theme
    rsync -av "$DOTFILES_S1B/.config/Kvantum/" "$HOME/.config/Kvantum/"
    
    log_success "Kvantum synced"
else
    log_warn "Kvantum config not found in dotfiles-s1b"
fi

# --- WARP TERMINAL ---
if [ -d "$DOTFILES_S1B/.config/warp-terminal" ]; then
    log_info "Syncing Warp Terminal..."
    ensure_dir_exists "$HOME/.config/warp-terminal"
    
    # Copy Warp config
    rsync -av "$DOTFILES_S1B/.config/warp-terminal/" "$HOME/.config/warp-terminal/"
    
    log_success "Warp Terminal synced"
else
    log_warn "Warp Terminal config not found in dotfiles-s1b"
fi

# --- PRISM TERMINAL ---
if [ -f "$HOME/.cargo/bin/prism" ]; then
    log_info "Prism Terminal is already installed (~/.cargo/bin/prism)"
    log_info "Theme directory: ~/.config/prism/themes/"
    log_info "Current theme: Check with: prism list"
    log_info "Apply theme with: prism apply <theme-name>"
    log_success "Prism Terminal ready (installed & configured)"
else
    log_warn "Prism Terminal not found - Install with: cargo install prism-term"
fi

log_success "All terminal configurations synced from dotfiles-s1b!"
