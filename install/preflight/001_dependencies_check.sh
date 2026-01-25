#!/bin/bash
# ============================================================
#  DEPENDENCIES CHECK
#  Validate core and optional dependencies
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/common/functions.sh"
source "$SCRIPT_DIR/../../scripts/common/logger.sh"
source "$SCRIPT_DIR/../../scripts/common/colors.sh"

log_info "Checking dependencies..."

# Core dependencies
local core_deps=(
    "bash"
    "git"
    "grep"
    "sed"
    "awk"
    "curl"
    "wget"
    "tar"
    "gzip"
    "make"
    "gcc"
)

local missing_core=()
for cmd in "${core_deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        missing_core+=("$cmd")
    fi
done

if [ ${#missing_core[@]} -gt 0 ]; then
    log_error "Missing core dependencies: ${missing_core[*]}"
    log_error "Please install missing dependencies:"
    echo "  sudo pacman -S ${missing_core[*]}"
    exit 1
fi
log_success "Core dependencies OK"

# Optional dependencies
local optional_deps=(
    "pacman"         # Package manager
    "nvidia-smi"      # NVIDIA GPU
    "xrandr"          # Display management
    "systemctl"       # Systemd
)

local missing_optional=()
for cmd in "${optional_deps[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        missing_optional+=("$cmd")
    fi
done

if [ ${#missing_optional[@]} -gt 0 ]; then
    log_warn "Missing optional dependencies: ${missing_optional[*]}"
    log_warn "Some features may not work without these"
else
    log_success "Optional dependencies OK"
fi

log_success "Dependencies check passed"
exit 0
