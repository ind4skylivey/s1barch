#!/bin/bash
# ============================================================
#  ROI SETUP - Orchestrate Rofi installation from dotfiles-s1b
#  Purpose: Sync and configure Rofi scripts from dotfiles-s1b
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

# Configuration
readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"
readonly ROFI_SOURCE="$DOTFILES_S1B/.config/rofi"
readonly ROFI_TARGET="$HOME/.config/rofi"

# Ensure directories exist
ensure_dir_exists "$ROFI_TARGET/scripts"

# Sync Rofi scripts
log_info "Syncing Rofi scripts from dotfiles-s1b..."

if [ ! -d "$ROFI_SOURCE" ]; then
    log_error "Rofi source directory not found: $ROFI_SOURCE"
    log_warn "Ensure dotfiles-s1b is cloned at $DOTFILES_S1B"
    exit 1
fi

# Backup existing config
backup_file "$ROFI_TARGET/powermenu.sh" 2>/dev/null || true

# Copy Rofi powermenu and scripts
log_info "Copying Rofi powermenu..."
cp "$ROFI_SOURCE/powermenu.sh" "$ROFI_TARGET/" || log_warn "powermenu.sh not found"

log_info "Copying Rofi scripts..."
if [ -d "$ROFI_SOURCE/scripts" ]; then
    rsync -av "$ROFI_SOURCE/scripts/" "$ROFI_TARGET/scripts/"
else
    log_warn "Rofi scripts directory not found"
fi

# Set executable permissions
chmod +x "$ROFI_TARGET/powermenu.sh" 2>/dev/null || true
find "$ROFI_TARGET/scripts" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

log_success "Rofi scripts synced from dotfiles-s1b"
log_info "Location: $ROFI_TARGET"
