#!/bin/bash
# ============================================================
#  QT SETUP - Orchestrate Qt configs from dotfiles-s1b
#  Purpose: Sync Kvantum, qt5ct configs
#           Configure environment variables
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

log_info "Syncing Qt configurations from dotfiles-s1b..."

# --- KVANTUM ---
if [ -d "$DOTFILES_S1B/.config/Kvantum" ]; then
    log_info "Syncing Kvantum..."
    ensure_dir_exists "$HOME/.config/Kvantum"
    
    backup_file "$HOME/.config/Kvantum/kvantum.kvconfig" 2>/dev/null || true

    rsync -av "$DOTFILES_S1B/.config/Kvantum/" "$HOME/.config/Kvantum/"
    
    log_success "Kvantum synced"
else
    log_warn "Kvantum config not found in dotfiles-s1b"
fi

# --- QT5CT ---
if [ -d "$DOTFILES_S1B/.config/qt5ct" ]; then
    log_info "Syncing qt5ct..."
    ensure_dir_exists "$HOME/.config/qt5ct"
    
    backup_file "$HOME/.config/qt5ct/qt5ct.conf" 2>/dev/null || true

    rsync -av "$DOTFILES_S1B/.config/qt5ct/" "$HOME/.config/qt5ct/"
    
    log_success "qt5ct synced"
else
    log_warn "qt5ct config not found in dotfiles-s1b"
fi

# --- CONFIGURE ENVIRONMENT VARIABLES ---
log_info "Configuring Qt environment variables..."

QT_ENV_VARS='
# Qt Theme Configuration (S1Bs1stem)
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
'

if ! grep -q "QT_QPA_PLATFORMTHEME=qt5ct" "$HOME/.xprofile" 2>/dev/null; then
    log_info "Adding Qt variables to ~/.xprofile..."
    echo "$QT_ENV_VARS" >> "$HOME/.xprofile"
    log_success "Qt variables added to ~/.xprofile"
else
    log_success "Qt variables already configured in ~/.xprofile"
fi

if ! grep -q "QT_QPA_PLATFORMTHEME=qt5ct" "$HOME/.bashrc" 2>/dev/null; then
    log_info "Adding Qt variables to ~/.bashrc..."
    echo "$QT_ENV_VARS" >> "$HOME/.bashrc"
    log_success "Qt variables added to ~/.bashrc"
else
    log_success "Qt variables already configured in ~/.bashrc"
fi

if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "QT_QPA_PLATFORMTHEME=qt5ct" "$HOME/.zshrc" 2>/dev/null; then
        log_info "Adding Qt variables to ~/.zshrc..."
        echo "$QT_ENV_VARS" >> "$HOME/.zshrc"
        log_success "Qt variables added to ~/.zshrc"
    else
        log_success "Qt variables already configured in ~/.zshrc"
    fi
fi

log_success "Qt configurations synced from dotfiles-s1b!"
log_info "Qt environment variables configured in .xprofile, .bashrc, and .zshrc"
