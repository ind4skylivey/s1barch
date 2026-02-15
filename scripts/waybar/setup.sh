#!/bin/bash
# ============================================================
#  WAYBAR SETUP - Orchestrate Waybar installation from dotfiles-s1b
#  Purpose: Sync and configure Waybar scripts from dotfiles-s1b
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"
readonly WAYBAR_SOURCE="$DOTFILES_S1B/.config/waybar"
readonly WAYBAR_TARGET="$HOME/.config/waybar"

# Ensure directories exist
ensure_dir_exists "$WAYBAR_TARGET/scripts"

# Sync Waybar scripts
log_info "Syncing Waybar scripts from dotfiles-s1b..."

if [ ! -d "$WAYBAR_SOURCE" ]; then
    log_error "Waybar source directory not found: $WAYBAR_SOURCE"
    log_warn "Ensure dotfiles-s1b is cloned at $DOTFILES_S1B"
    exit 1
fi

# Backup existing config
backup_file "$WAYBAR_TARGET/launch-multi.sh" 2>/dev/null || true

# Copy Waybar launch script
log_info "Copying Waybar launch script..."
cp "$WAYBAR_SOURCE/launch-multi.sh" "$WAYBAR_TARGET/" || log_warn "launch-multi.sh not found"

# Copy Waybar scripts
log_info "Copying Waybar scripts..."
if [ -d "$WAYBAR_SOURCE/scripts" ]; then
    rsync -av "$WAYBAR_SOURCE/scripts/" "$WAYBAR_TARGET/scripts/"
else
    log_warn "Waybar scripts directory not found"
fi

# Set executable permissions
chmod +x "$WAYBAR_TARGET/launch-multi.sh" 2>/dev/null || true
find "$WAYBAR_TARGET/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

log_success "Waybar scripts synced from dotfiles-s1b"
log_info "Location: $WAYBAR_TARGET"
