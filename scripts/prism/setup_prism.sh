#!/bin/bash
# ============================================================
#  PRISM SETUP - Setup Iridex Prism Terminal (NOT from dotfiles-s1b)
#  Purpose: Install Iridex Prism Terminal if not installed
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

readonly CARGO_BIN="$HOME/.cargo/bin"
readonly PRISM_REPO="https://github.com/ind4skylivey/iridex-prism-terminal"
readonly PRISM_DIR="$HOME/.config/prism"

log_info "Setting up Iridex Prism Terminal..."

# Check if already installed
if [ -x "$CARGO_BIN/prism" ]; then
    VERSION=$("$CARGO_BIN/prism" --version 2>/dev/null || echo "unknown")
    log_success "Iridex Prism Terminal is already installed (v$VERSION)"
    log_info "Using configuration from: $PRISM_DIR"
    echo ""
    # shellcheck disable=SC2154
    echo "${COLOR_TEXT}Configuration location:${COLOR_RESET} $PRISM_DIR"
    # shellcheck disable=SC2154
    echo "${COLOR_TEXT}Backup/Restore:${COLOR_RESET} scripts/prism/backup_prism.sh"
    echo ""
    log_info "No action needed. Iridex Prism Terminal is already installed."
    exit 0
fi

# Check if cargo is available
if ! command -v cargo &>/dev/null; then
    log_warn "Cargo not found. Installing Rust toolchain..."
    log_info "Run: curl https://sh.rustup.rs | sh"
    exit 1
fi

# Clone and install Iridex Prism Terminal
log_info "Installing Iridex Prism Terminal from $PRISM_REPO..."

# Check if repo exists locally
if [ -d "$HOME/Desktop/iridex-prism-terminal" ]; then
    log_info "Found local clone, building from source..."
    cd "$HOME/Desktop/iridex-prism-terminal"
    
    if [ -f "Cargo.toml" ]; then
        log_info "Building Iridex Prism Terminal..."
        cargo build --release --bins
        sudo cp "target/release/prism" "$CARGO_BIN/prism"
        sudo chmod +x "$CARGO_BIN/prism"
        log_success "Iridex Prism Terminal installed to: $CARGO_BIN/prism"
    else
        log_error "Cargo.toml not found in local clone"
        exit 1
    fi
else
    # Clone repository
    cd "$HOME/Desktop"
    log_info "Cloning Iridex Prism Terminal..."
    git clone "$PRISM_REPO" "$HOME/Desktop/iridex-prism-terminal"
    
    if [ ! -d "$HOME/Desktop/iridex-prism-terminal" ]; then
        log_error "Failed to clone repository"
        exit 1
    fi
    
    cd "$HOME/Desktop/iridex-fire-terminal"
    
    if [ -f "Cargo.toml" ]; then
        log_info "Building Iridex Prism Terminal..."
        cargo build --release --bins
        sudo cp "target/release/prism" "$CARGO_BIN/prism"
        sudo chmod +x "$CARGO_BIN/prism"
        log_success "Iridex Prism Terminal installed to: $CARGO_BIN/prism"
    else
        log_error "Cargo.toml not found"
        exit 1
    fi
fi

# Launch Iridex Prism Terminal
log_info "Launching Iridex Prism Terminal..."

if command -v "$CARGO_BIN/prism" &>/dev/null; then
    "$CARGO_BIN/prism" &
    log_info "Iridex Prism Terminal launched"
else
    log_warn "Iridex Prism Terminal failed to launch"
    echo "${COLOR_TEXT}Try running manually:${COLOR_RESET}"
    echo "  $CARGO_BIN/prism"
fi

log_success "Iridex Prism Terminal setup completed!"
