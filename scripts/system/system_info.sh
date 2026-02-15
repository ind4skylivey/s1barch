#!/bin/bash
# ============================================================
#  SYSTEM INFO - Display complete system information
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Gathering system information..."

# System info
echo ""
echo -e "${COLOR_BOLD}${COLOR_Mauve}SYSTEM INFORMATION${COLOR_RESET}"
echo "═════════════════════════════════════"
echo ""
echo "OS:       $(uname -s)"
echo "Kernel:   $(uname -r)"
echo "Arch:     $(uname -m)"
echo "Hostname:  $(hostname)"
echo ""

# Uptime
echo -e "${COLOR_GREEN}UPTIME${COLOR_RESET}"
echo "$(uptime -p)"
echo ""

# CPU info
echo -e "${COLOR_GREEN}CPU${COLOR_RESET}"
lscpu | grep -E "Model name|CPU\(s\)|Thread" | head -5
echo ""

# Memory info
echo -e "${COLOR_GREEN}MEMORY${COLOR_RESET}"
free -h
echo ""

# Disk usage
echo -e "${COLOR_GREEN}DISK USAGE${COLOR_RESET}"
df -h / | grep -E "^/dev/"
echo ""

# Packages
echo -e "${COLOR_GREEN}PACKAGES${COLOR_RESET}"
if command -v pacman &>/dev/null; then
    echo "Official:  $(pacman -Q | wc -l)"
fi
if command -v yay &>/dev/null; then
    echo "AUR:        $(pacman -Qm | yay -Qmq | wc -l)"
fi
echo ""

# Hardware info
echo -e "${COLOR_GREEN}HARDWARE${COLOR_RESET}"
if command -v lspci &>/dev/null; then
    echo "GPU:"
    lspci | grep -i vga | head -3 | sed 's/^/  /'
fi
if command -v lsblk &>/dev/null; then
    echo "Storage:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | head -5
fi
echo ""

log_success "System information collected"
