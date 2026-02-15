#!/bin/bash
# ============================================================
#  SETUP STOW - Configure GNU Stow for dotfiles management
#  Purpose: Create symlinks from dotfiles-s1b to home directory
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

# Configuration
readonly DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"
readonly STOW_TARGET="$HOME"

log_info "Configuring GNU Stow for dotfiles-s1b..."

# Check if Stow is installed
if ! command -v stow &>/dev/null; then
    log_error "GNU Stow is not installed"
    log_info "Installing GNU Stow..."
    sudo pacman -S --needed stow
    log_success "GNU Stow installed"
fi

# Check if dotfiles-s1b exists
if [ ! -d "$DOTFILES_S1B" ]; then
    log_error "dotfiles-s1b directory not found: $DOTFILES_S1B"
    log_warn "Ensure dotfiles-s1b is cloned at $DOTFILES_S1B"
    exit 1
fi

# Create stow directories structure
log_info "Creating Stow directories..."

STOW_DIRS=(
    ".config"
    ".local/bin"
    ".local/share"
    ".doom.d"
    ".zen-browser-config"
)

for stow_dir in "${STOW_DIRS[@]}"; do
    if [ -d "$DOTFILES_S1B/$stow_dir" ]; then
        ensure_dir_exists "$STOW_TARGET/$stow_dir"
    fi
done

log_success "Stow directories created"

# Stow configurations
log_info "Stowing dotfiles from dotfiles-s1b..."

cd "$DOTFILES_S1B"

# Stow .config directories
CONFIG_DIRS=(
    ".config/dwm"
    ".config/waybar"
    ".config/rofi"
    ".config/kitty"
    ".config/zellij"
    ".config/zsh"
    ".config/fish"
    ".config/nvim"
    ".config/emacs"
)

for config_dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES_S1B/$config_dir" ]; then
        log_info "Stowing $config_dir..."
        stow -R --target="$STOW_TARGET" --dir="$DOTFILES_S1B" $config_dir 2>/dev/null || log_warn "Failed to stow $config_dir"
    fi
done

# Stow .local/bin
if [ -d "$DOTFILES_S1B/.local/bin" ]; then
    log_info "Stowing .local/bin..."
    ensure_dir_exists "$STOW_TARGET/.local/bin"
    stow -R --target="$STOW_TARGET/.local/bin" --dir="$DOTFILES_S1B/.local/bin" . 2>/dev/null || log_warn "Failed to stow .local/bin"
fi

# Stow .local/share
if [ -d "$DOTFILES_S1B/.local/share" ]; then
    log_info "Stowing .local/share..."
    ensure_dir_exists "$STOW_TARGET/.local/share"
    stow -R --target="$STOW_TARGET/.local/share" --dir="$DOTFILES_S1B/.local/share" . 2>/dev/null || log_warn "Failed to stow .local/share"
fi

# Stow Doom Emacs config
if [ -d "$DOTFILES_S1B/.doom.d" ]; then
    log_info "Stowing Doom Emacs config..."
    stow -R --target="$STOW_TARGET" --dir="$DOTFILES_S1B" .doom.d 2>/dev/null || log_warn "Failed to stow Doom Emacs config"
fi

# Stow Zen Browser config
if [ -d "$DOTFILES_S1B/.zen-browser-config" ]; then
    log_info "Stowing Zen Browser config..."
    stow -R --target="$STOW_TARGET" --dir="$DOTFILES_S1B" .zen-browser-config 2>/dev/null || log_warn "Failed to stow Zen Browser config"
fi

# Stow home-level files (zshrc, etc.)
HOME_FILES=(
    ".zshrc"
    ".p10k.zsh"
)

for home_file in "${HOME_FILES[@]}"; do
    if [ -f "$DOTFILES_S1B/$home_file" ]; then
        log_info "Stowing $home_file..."
        if [ -L "$STOW_TARGET/$home_file" ]; then
            rm "$STOW_TARGET/$home_file"
        fi
        ln -sf "$DOTFILES_S1B/$home_file" "$STOW_TARGET/$home_file"
    fi
done

log_success "Dotfiles stowed successfully"

# Create stow management script
log_info "Creating stow management script..."

STOW_MANAGE="$HOME/.local/bin/s1b-stow"
cat > "$STOW_MANAGE" << 'EOF'
#!/bin/bash
# ============================================================
#  S1B STOW MANAGER - Manage dotfiles symlinks
#  ============================================================

DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

case "${1:-help}" in
    restow|re)
        echo "Restowing all dotfiles..."
        cd "$DOTFILES_S1B"
        stow -R .config
        stow -R .local/bin
        stow -R .doom.d
        echo "✓ Dotfiles restowed"
        ;;
    unclash|u)
        echo "Unstowing all dotfiles..."
        cd "$DOTFILES_S1B"
        stow -D .config
        stow -D .local/bin
        stow -D .doom.d
        echo "✓ Dotfiles unstowed"
        ;;
    status|s)
        echo "Stow status:"
        cd "$DOTFILES_S1B"
        stow -n .config 2>&1 | grep -E "(unstow|relink)" || echo "All symlinks up to date"
        ;;
    help|h|*)
        cat << HELP
S1B Stow Manager - Usage:
  restow|re   - Restow all dotfiles
  unstow|u    - Unstow all dotfiles
  status|s    - Check stow status
  help|h       - Show this help
HELP
        ;;
esac
EOF

chmod +x "$STOW_MANAGE"

log_success "Stow management script created: $STOW_MANAGE"

log_success "GNU Stow configuration completed!"
log_info "Manage symlinks with: s1b-stow [restow|unstow|status]"
