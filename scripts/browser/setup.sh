#!/bin/bash
# ============================================================
#  BROWSER SETUP - Orchestrate Browser configs from dotfiles-s1b
#  Purpose: Sync Zen Browser configuration
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Browser configurations from dotfiles-s1b..."

# --- ZEN BROWSER ---
if [ -d "$DOTFILES_S1B/.zen-browser-config" ]; then
    log_info "Syncing Zen Browser..."
    
    # Backup existing
    backup_file "$HOME/.zen-browser-config" 2>/dev/null || true
    
    # Copy Zen Browser config
    rsync -av "$DOTFILES_S1B/.zen-browser-config/" "$HOME/.zen-browser-config/"
    
    log_success "Zen Browser synced"
else
    log_warn "Zen Browser config not found in dotfiles-s1b"
fi

log_success "Browser configurations synced from dotfiles-s1b!"
