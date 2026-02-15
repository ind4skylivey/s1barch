#!/bin/bash
# ============================================================
#  WAYLAND SETUP - Orchestrate Wayland configs from dotfiles-s1b
#  Purpose: Sync Wofi launcher config
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Wayland configurations from dotfiles-s1b..."

# --- WOFI ---
if [ -d "$DOTFILES_S1B/.config/wofi" ] || [ -f "$DOTFILES_S1B/.config/wofi/style.css" ]; then
    log_info "Syncing Wofi launcher..."
    ensure_dir_exists "$HOME/.config/wofi"
    
    backup_file "$HOME/.config/wofi/style.css" 2>/dev/null || true
    
    rsync -av "$DOTFILES_S1B/.config/wofi/" "$HOME/.config/wofi/"
    
    log_success "Wofi synced"
else
    log_warn "Wofi config not found in dotfiles-s1b"
fi

log_success "Wayland configurations synced from dotfiles-s1b!"
