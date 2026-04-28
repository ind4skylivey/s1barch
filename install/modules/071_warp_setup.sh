#!/bin/bash
# ============================================================
#  WARP SETUP - Warp Terminal
#  Purpose: Configure Warp Terminal + Themes
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Setting up Warp Terminal..."

# Warp Terminal is a native app (not in pacman)
log_warn "Warp Terminal must be installed manually from:"
log_warn "https://warp.dev"
log_warn "Continuing with configuration..."

# Create directories
ensure_dir_exists "$HOME/.config/warp-terminal"
ensure_dir_exists "$HOME/.local/share/warp-terminal/themes"

# Sync configs from dotfiles-s1b
if [ -d "$HOME/Desktop/dotfiles-s1b" ]; then
    log_info "Syncing Warp configs from dotfiles-s1b..."
    
    # Execute Warp orchestration script
    "$S1B_ROOT/scripts/warp/setup.sh"
else
    log_warn "dotfiles-s1b not found, skipping Warp configs..."
fi

log_success "Warp setup completed!"
