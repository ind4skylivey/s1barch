#!/bin/bash
# ============================================================
#  SHELL SETUP
#  Configure ZSH shell and common utilities
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Setting up shell environment..."

# Install ZSH if not installed
if ! command -v zsh &>/dev/null; then
    log_info "ZSH not found, installing..."
    sudo pacman -S --needed --noconfirm zsh
    log_success "ZSH installed"
else
    log_success "ZSH is already installed"
fi

# Install Oh My ZSH (optional)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My ZSH not found, installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My ZSH installed"
else
    log_success "Oh My ZSH is already installed"
fi

# Install Powerlevel10k (optional)
if [ ! -f "$HOME/.p10k.zsh" ]; then
    log_info "Powerlevel10k not found, installing..."
    
    # Copy from dotfiles-s1b if available
    if [ -f "$HOME/Desktop/dotfiles-s1b/.p10k.zsh" ]; then
        cp "$HOME/Desktop/dotfiles-s1b/.p10k.zsh" "$HOME/.p10k.zsh"
        log_success "Powerlevel10k copied from dotfiles-s1b"
    else
        log_warn "Powerlevel10k not found in dotfiles-s1b, skipping..."
    fi
else
    log_success "Powerlevel10k is already installed"
fi

# Install Starship prompt (alternative to p10k)
if ! command -v starship &>/dev/null; then
    log_info "Starship not found, installing..."
    curl -fsSL https://starship.rs/install.sh | sh
    log_success "Starship installed"
else
    log_success "Starship is already installed"
fi

# Copy Starship config
if [ -f "$S1B_ROOT/starship.toml" ]; then
    log_info "Copying Starship config..."
    backup_file "$HOME/.config/starship.toml"
    cp "$S1B_ROOT/starship.toml" "$HOME/.config/starship.toml"
    log_success "Starship config copied"
fi

# Install Zoxide (better cd)
if ! command -v zoxide &>/dev/null; then
    log_info "Zoxide not found, installing..."
    cargo install zoxide || sudo pacman -S zoxide
    log_success "Zoxide installed"
else
    log_success "Zoxide is already installed"
fi

# Install FZF (fuzzy finder)
if ! command -v fzf &>/dev/null; then
    log_info "FZF not found, installing..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin
    log_success "FZF installed"
else
    log_success "FZF is already installed"
fi

# Install useful shell utilities
log_info "Installing shell utilities..."

shell_utils=(
    "ripgrep"      # Better grep
    "fd"           # Better find
    "bat"          # Better cat
    "eza"          # Better ls
    "jq"           # JSON processor
    "exa"          # Alternative to eza
    "tree"         # Directory tree
)

for util in "${shell_utils[@]}"; do
    if ! command -v "$util" &>/dev/null; then
        log_info "Installing $util..."
        install_package_if_missing "$util"
    else
        log_success "$util is already installed"
    fi
done

# Setup shell aliases
log_info "Setting up shell aliases..."

ZSHRC_FILE="$HOME/.zshrc"

# Backup existing .zshrc
if [ -f "$ZSHRC_FILE" ]; then
    backup_file "$ZSHRC_FILE"
fi

# Source S1Bs1stem functions in .zshrc
if ! grep -q "S1Bs1stem" "$ZSHRC_FILE" 2>/dev/null; then
    echo "" >> "$ZSHRC_FILE"
    echo "# S1Bs1stem Common Functions" >> "$ZSHRC_FILE"
    echo "source $HOME/Desktop/S1Bs1stem/scripts/common/functions.sh" >> "$ZSHRC_FILE"
    echo "source $HOME/Desktop/S1Bs1stem/scripts/common/logger.sh" >> "$ZSHRC_FILE"
    echo "source $HOME/Desktop/S1Bs1stem/scripts/common/colors.sh" >> "$ZSHRC_FILE"
    log_success "S1Bs1stem functions added to .zshrc"
fi

# Set default shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
    log_info "Setting ZSH as default shell..."
    echo "$(which zsh)" | sudo tee -a /etc/shells &>/dev/null || true
    chsh -s "$(which zsh)"
    log_success "ZSH set as default shell (logout required)"
else
    log_success "ZSH is already the default shell"
fi

log_success "Shell setup completed"
exit 0
