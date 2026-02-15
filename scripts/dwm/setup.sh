#!/bin/bash
# ============================================================
#  DWM SETUP - Orchestrate DWM configuration from dotfiles-s1b
#  Purpose: Sync DWM window manager configuration
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing DWM configuration from dotfiles-s1b..."

# Check if DWM source exists
if [ ! -d "$DOTFILES_S1B/.config/dwm" ]; then
    log_error "DWM configuration not found in dotfiles-s1b"
    log_warn "Expected path: $DOTFILES_S1B/.config/dwm"
    log_info "Skipping DWM configuration sync"
    exit 1
fi

# Ensure DWM config directory exists
ensure_dir_exists "$HOME/.config/dwm"

# Backup existing DWM config
log_info "Backing up existing DWM configuration..."
backup_file "$HOME/.config/dwm" 2>/dev/null || true

# Copy DWM configuration
log_info "Copying DWM configuration..."

# Copy main config files
cp "$DOTFILES_S1B/.config/dwm/config.h" "$HOME/.config/dwm/" 2>/dev/null || log_warn "config.h not found"
cp "$DOTFILES_S1B/.config/dwm/config.def.h" "$HOME/.config/dwm/" 2>/dev/null || log_warn "config.def.h not found"
cp "$DOTFILES_S1B/.config/dwm/config.mk" "$HOME/.config/dwm/" 2>/dev/null || log_warn "config.mk not found"
cp "$DOTFILES_S1B/.config/dwm/Makefile" "$HOME/.config/dwm/" 2>/dev/null || log_warn "Makefile not found"

# Copy .xinitrc
cp "$DOTFILES_S1B/.config/dwm/.xinitrc" "$HOME/.config/dwm/" 2>/dev/null || log_warn ".xinitrc not found"

# Copy backgrounds directory
if [ -d "$DOTFILES_S1B/.config/dwm/backgrounds" ]; then
    log_info "Copying DWM backgrounds..."
    rsync -av "$DOTFILES_S1B/.config/dwm/backgrounds/" "$HOME/.config/dwm/backgrounds/"
fi

# Copy DWM-specific terminal configs
if [ -d "$DOTFILES_S1B/.config/dwm/config" ]; then
    log_info "Copying DWM terminal configs..."
    rsync -av "$DOTFILES_S1B/.config/dwm/config/" "$HOME/.config/dwm/config/"
fi

# Copy slstatus (if exists)
if [ -d "$DOTFILES_S1B/.config/dwm/slstatus" ]; then
    log_info "Copying slstatus..."
    rsync -av "$DOTFILES_S1B/.config/dwm/slstatus/" "$HOME/.config/dwm/slstatus/"
fi

# Copy drw.c (DWM source patch)
if [ -f "$DOTFILES_S1B/.config/dwm/drw.c" ]; then
    cp "$DOTFILES_S1B/.config/dwm/drw.c" "$HOME/.config/dwm/"
    log_success "drw.c copied"
fi

# Copy drw.h (DWM header patch)
if [ -f "$DOTFILES_S1B/.config/dwm/drw.h" ]; then
    cp "$DOTFILES_S1B/.config/dwm/drw.h" "$HOME/.config/dwm/"
    log_success "drw.h copied"
fi

log_success "DWM configuration synced from dotfiles-s1b"
log_info "Location: $HOME/.config/dwm"

# Check if DWM needs compilation
if [ -f "$HOME/.config/dwm/config.h" ] && [ -f "$HOME/.config/dwm/Makefile" ]; then
    log_info "DWM configuration files present"
    log_info "To compile DWM with new configuration:"
    echo "  cd ~/.config/dwm"
    echo "  sudo make clean install"
fi
