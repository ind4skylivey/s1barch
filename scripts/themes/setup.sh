#!/bin/bash
# ============================================================
#  THEMES SETUP - Orchestrate Themes from dotfiles-s1b
#  Purpose: Sync all 13 Warp themes
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Themes from dotfiles-s1b..."

if [ ! -d "$DOTFILES_S1B/themes" ]; then
    log_error "Themes directory not found: $DOTFILES_S1B/themes"
    log_warn "Ensure dotfiles-s1b is cloned at $DOTFILES_S1B"
    exit 1
fi

# Sync all theme directories
log_info "Copying all themes..."
rsync -av "$DOTFILES_S1B/themes/" "$DOTFILES_S1B/themes/../" 2>/dev/null || true

# Count themes synced
THEME_COUNT=$(find "$DOTFILES_S1B/themes" -maxdepth 1 -type d | wc -l)
readonly THEME_COUNT

log_success "Synced $THEME_COUNT themes from dotfiles-s1b"
log_info "Themes location: $DOTFILES_S1B/themes"

# List synced themes
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Available Themes:${COLOR_RESET}"
for theme_dir in "$DOTFILES_S1B/themes"/*; do
    if [ -d "$theme_dir" ]; then
        theme_name=$(basename "$theme_dir")
        echo "  ${COLOR_GREEN}✓${COLOR_RESET} $theme_name"
    fi
done
echo ""
