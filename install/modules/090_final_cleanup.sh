#!/bin/bash
# ============================================================
#  FINAL CLEANUP - Post-installation cleanup
#  Purpose: Remove temporary files, clean caches, finalize setup
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

log_info "Starting final cleanup..."

# Clean temporary files
log_info "Cleaning temporary files..."
TEMP_DIRS=(
    "/tmp/s1b_*"
    "/tmp/orchestra*"
    "$HOME/.s1b_temp*"
)

for temp_dir in "${TEMP_DIRS[@]}"; do
    rm -rf $temp_dir 2>/dev/null || true
done

log_success "Temporary files cleaned"

# Clean package cache
log_info "Cleaning package caches..."

# Pacman cache (if exists)
if command -v pacman &>/dev/null; then
    sudo pacman -Sc --noconfirm 2>/dev/null || log_warn "Pacman cache cleanup failed"
fi

# Paru cache (if exists)
if command -v paru &>/dev/null; then
    paru -Sc --noconfirm 2>/dev/null || log_warn "Paru cache cleanup failed"
fi

# Yay cache (if exists)
if command -v yay &>/dev/null; then
    yay -Sc --noconfirm 2>/dev/null || log_warn "Yay cache cleanup failed"
fi

log_success "Package caches cleaned"

# Clean shell cache
log_info "Cleaning shell caches..."

# Zsh cache
if [ -d "$HOME/.cache/zsh" ]; then
    rm -rf "$HOME/.cache/zsh"/*
    log_success "Zsh cache cleaned"
fi

# Fish cache
if command -v fish &>/dev/null && [ -d "$HOME/.local/share/fish" ]; then
    fish -c "fish_update_completions" 2>/dev/null || true
    log_success "Fish cache updated"
fi

# Clean editor caches
log_info "Cleaning editor caches..."

# Neovim cache
if [ -d "$HOME/.local/share/nvim/swap" ]; then
    rm -f "$HOME/.local/share/nvim/swap"/*
    log_success "Neovim swap files cleaned"
fi

# Emacs cache
if [ -d "$HOME/.emacs.d/.local/cache" ]; then
    rm -rf "$HOME/.emacs.d/.local/cache"/*
    log_success "Emacs cache cleaned"
fi

# Clean logs older than 7 days
log_info "Cleaning old logs..."

if [ -d "$HOME/.s1b_logs" ]; then
    find "$HOME/.s1b_logs" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    log_success "Old logs cleaned"
fi

# Clean backups older than 30 days
log_info "Cleaning old backups..."

if [ -d "$HOME/.s1b_backup" ]; then
    find "$HOME/.s1b_backup" -type d -mtime +30 -delete 2>/dev/null || true
    log_success "Old backups cleaned"
fi

# Create installation summary
log_info "Creating installation summary..."

SUMMARY_FILE="$HOME/.s1b_installation_summary"
cat > "$SUMMARY_FILE" << EOF
========================================
 S1Bs1stem Installation Summary
========================================

Installation Date: $(date)
System: $(uname -sr)
Kernel: $(uname -r)
Shell: $(basename $SHELL)

Configuration Locations:
- DWM: ~/.config/dwm
- Waybar: ~/.config/waybar
- Rofi: ~/.config/rofi
- Kitty: ~/.config/kitty
- Zellij: ~/.config/zellij
- Neovim: ~/.config/nvim
- Doom Emacs: ~/.config/emacs
- Workflows: ~/Desktop/S1Bs1stem/workflow

Log Location:
- Installation Log: ~/.s1b_install_*.log
- System Log: ~/.s1b_logs/

Backup Location:
- Backups: ~/.s1b_backup*

Next Steps:
1. Restart DWM or logout/login
2. Run: s1b-doctor (to verify installation)
3. Run: ws-menu (to select workflow)

Documentation:
- Full Guide: https://github.com/ind4skylivey/S1Bs1stem/wiki
- Issues: https://github.com/ind4skylivey/S1Bs1stem/issues

========================================
Thank you for using S1Bs1stem!
========================================
EOF

log_success "Installation summary created: $SUMMARY_FILE"

# Display summary
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}========================================${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve} S1Bs1stem Installation Complete!${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}========================================${COLOR_RESET}"
echo ""
echo "${COLOR_GREEN}✓ Temporary files cleaned${COLOR_RESET}"
echo "${COLOR_GREEN}✓ Package caches cleaned${COLOR_RESET}"
echo "${COLOR_GREEN}✓ Shell caches cleaned${COLOR_RESET}"
echo "${COLOR_GREEN}✓ Editor caches cleaned${COLOR_RESET}"
echo "${COLOR_GREEN}✓ Old logs cleaned${COLOR_RESET}"
echo "${COLOR_GREEN}✓ Installation summary created${COLOR_RESET}"
echo ""
echo "${COLOR_TEXT}View summary: cat $SUMMARY_FILE${COLOR_RESET}"
echo "${COLOR_TEXT}Next steps: Restart DWM or logout/login${COLOR_RESET}"
echo ""

log_success "Final cleanup completed successfully!"
