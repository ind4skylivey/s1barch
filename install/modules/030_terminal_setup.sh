#!/bin/bash
# ============================================================
#  TERMINAL SETUP
#  Install and configure terminal emulators
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Setting up terminal emulators..."

# Install Kitty
if ! command -v kitty &>/dev/null; then
    log_info "Kitty not found, installing..."
    sudo pacman -S --needed --noconfirm kitty
    log_success "Kitty installed"
else
    log_success "Kitty is already installed"
fi

# Configure Kitty
KITTY_CONFIG_DIR="$HOME/.config/kitty"
KITTY_SOURCE_DIR="$S1B_ROOT/configs/kitty"

ensure_dir_exists "$KITTY_CONFIG_DIR"

if [ -d "$KITTY_SOURCE_DIR" ]; then
    log_info "Configuring Kitty..."
    
    # Backup existing config
    if [ -f "$KITTY_CONFIG_DIR/kitty.conf" ]; then
        backup_file "$KITTY_CONFIG_DIR/kitty.conf"
    fi
    
    # Copy Kitty config
    cp -r "$KITTY_SOURCE_DIR/"* "$KITTY_CONFIG_DIR/"
    log_success "Kitty configuration copied"
else
    log_warn "Kitty source config not found, skipping..."
fi

# Install Alacritty (alternative terminal)
if ! command -v alacritty &>/dev/null; then
    log_info "Alacritty not found, installing..."
    sudo pacman -S --needed --noconfirm alacritty
    log_success "Alacritty installed"
else
    log_success "Alacritty is already installed"
fi

# Configure Alacritty
ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"
ALACRITTY_SOURCE_DIR="$S1B_ROOT/configs/alacritty"

ensure_dir_exists "$ALACRITTY_CONFIG_DIR"

if [ -d "$ALACRITTY_SOURCE_DIR" ]; then
    log_info "Configuring Alacritty..."
    
    # Backup existing config
    if [ -f "$ALACRITTY_CONFIG_DIR/alacritty.toml" ]; then
        backup_file "$ALACRITTY_CONFIG_DIR/alacritty.toml"
    fi
    
    # Copy Alacritty config
    cp -r "$ALACRITTY_SOURCE_DIR/"* "$ALACRITTY_CONFIG_DIR/"
    log_success "Alacritty configuration copied"
else
    log_warn "Alacritty source config not found, skipping..."
fi

# Install terminal tools
log_info "Installing terminal tools..."

term_tools=(
    "tmux"         # Terminal multiplexer
    "zellij"        # Modern terminal multiplexer
    "neovim"        # Modern editor
    "vim"           # Classic editor
    "htop"          # Process viewer
    "btop"          # Better process viewer
    "glances"       # System monitoring
)

for tool in "${term_tools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        log_info "Installing $tool..."
        install_package_if_missing "$tool"
    else
        log_success "$tool is already installed"
    fi
done

# Configure TMUX
TMUX_CONFIG_DIR="$HOME/.config/tmux"

ensure_dir_exists "$TMUX_CONFIG_DIR"

# Install TPM (TMUX Plugin Manager)
if [ ! -d "$TMUX_CONFIG_DIR/plugins/tpm" ]; then
    log_info "Installing TMUX Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TMUX_CONFIG_DIR/plugins/tpm"
    log_success "TPM installed"
else
    log_success "TPM is already installed"
fi

# Configure Zellij
ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"
ZELLIJ_SOURCE_DIR="$S1B_ROOT/configs/zellij"

ensure_dir_exists "$ZELLIJ_CONFIG_DIR"

if [ -d "$ZELLIJ_SOURCE_DIR" ]; then
    log_info "Configuring Zellij..."
    
    # Backup existing config
    if [ -f "$ZELLIJ_CONFIG_DIR/config.kdl" ]; then
        backup_file "$ZELLIJ_CONFIG_DIR/config.kdl"
    fi
    
    # Copy Zellij config
    cp -r "$ZELLIJ_SOURCE_DIR/"* "$ZELLIJ_CONFIG_DIR/"
    log_success "Zellij configuration copied"
else
    log_warn "Zellij source config not found, skipping..."
fi

# Configure Neovim
NEOVIM_CONFIG_DIR="$HOME/.config/nvim"

ensure_dir_exists "$NEOVIM_CONFIG_DIR"

if [ ! -d "$NEOVIM_CONFIG_DIR/autoload" ]; then
    log_info "Setting up Neovim autoload directory..."
    mkdir -p "$NEOVIM_CONFIG_DIR/autoload"
    curl -fLo "$NEOVIM_CONFIG_DIR/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    log_success "Vim-plug installed for Neovim"
fi

# Set default terminal
log_info "Setting default terminal..."
if command -v update-alternatives &>/dev/null; then
    sudo update-alternatives --set x-terminal-emulator "$(which kitty)" || true
    log_success "Default terminal set to Kitty"
else
    log_warn "update-alternatives not available, manual setup may be needed"
fi

log_success "Terminal setup completed"
exit 0
