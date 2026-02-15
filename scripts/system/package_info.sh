#!/bin/bash
# ============================================================
#  PACKAGE INFO - Display installed packages information
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"
source "$SCRIPT_DIR/../common/logger.sh"
source "$SCRIPT_DIR/../common/colors.sh"

log_info "Gathering package information..."

# Package count
echo ""
echo -e "${COLOR_BOLD}${COLOR_Mauve}PACKAGE INFORMATION${COLOR_RESET}"
echo "═════════════════════════════════════"
echo ""

if command -v pacman &>/dev/null; then
    official_count=$(pacman -Q | wc -l)
    echo -e "${COLOR_GREEN}Official packages:${COLOR_RESET} $official_count"
fi

if command -v yay &>/dev/null; then
    aur_count=$(pacman -Qm | yay -Qmq | wc -l)
    echo -e "${COLOR_GREEN}AUR packages:${COLOR_RESET} $aur_count"
fi

if command -v pacman &>/dev/null; then
    total_count=$(pacman -Q | wc -l)
    echo -e "${COLOR_GREEN}Total packages:${COLOR_RESET} $total_count"
fi

echo ""

# Largest packages
echo -e "${COLOR_GREEN}Largest packages (top 10):${COLOR_RESET}"
if command -v pacman &>/dev/null; then
    pacman -Qi | awk '/^Name/ {name=$3} /^Installed Size/ {size=$4} END {print size, name}' | sort -rn | head -10 | while read size pkg; do
        size_mb=$((size / 1024 / 1024))
        printf "  - %s (%.2f MB)\n" "$pkg" "$size_mb"
    done
fi

echo ""

# Orphan packages
echo -e "${COLOR_GREEN}Orphan packages (no required by any other package):${COLOR_RESET}"
if command -v pacman &>/dev/null; then
    orphans=$(pacman -Qtdq | wc -l)
    echo "Count: $orphans"
    echo ""
    pacman -Qtdq | head -20 | while read pkg; do
        echo "  - $pkg"
    done
fi

echo ""

# Explicitly installed packages
echo -e "${COLOR_GREEN}Explicitly installed packages (top 20):${COLOR_RESET}"
if command -v pacman &>/dev/null; then
    pacman -Qeq | head -20 | while read pkg; do
        echo "  - $pkg"
    done
fi

echo ""

log_success "Package information collected"
