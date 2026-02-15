#!/bin/bash
# ============================================================
#  DISPLAY SETUP - Orchestrate Display scripts from dotfiles-s1b
#  Purpose: Sync wallpaper and display scripts from dotfiles-s1b
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"
readonly AUTOSTART_SOURCE="$DOTFILES_S1B/.config/autostart"
readonly AUTOSTART_TARGET="$HOME/.config/autostart"

# Ensure directories exist
ensure_dir_exists "$AUTOSTART_TARGET"

# Sync display scripts
log_info "Syncing Display scripts from dotfiles-s1b..."

if [ ! -d "$AUTOSTART_SOURCE" ]; then
    log_error "Autostart source directory not found: $AUTOSTART_SOURCE"
    log_warn "Ensure dotfiles-s1b is cloned at $DOTFILES_S1B"
    exit 1
fi

# Copy autostart scripts
log_info "Copying autostart scripts..."
rsync -av "$AUTOSTART_SOURCE/" "$AUTOSTART_TARGET/"

# Set executable permissions
find "$AUTOSTART_TARGET" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

log_success "Display scripts synced from dotfiles-s1b"
log_info "Autostart scripts: $AUTOSTART_TARGET"
