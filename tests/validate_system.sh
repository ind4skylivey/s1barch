#!/bin/bash
# ============================================================
#  VALIDATE SYSTEM - Post-installation validation
#  Usage: ./tests/validate_system.sh [--fix]
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

FIX_MODE=false
if [[ "${1:-}" == "--fix" ]]; then
    FIX_MODE=true
    echo "${COLOR_YELLOW}Running in FIX mode${COLOR_RESET}"
    echo ""
fi

echo "${COLOR_BOLD}${COLOR_Mauve}╔════════════════════════════════════╗${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}║   S1Bs1stem System Validation   ║${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}╚════════════════════════════════════╝${COLOR_RESET}"
echo ""

ISSUES_FOUND=0

# Validate Executables
echo "${COLOR_BOLD}${COLOR_Mauve}Validating Executables:${COLOR_RESET}"

NON_EXEC_S1B=$(find "$S1B_ROOT/scripts" -name "*.sh" ! -executable | wc -l)
readonly NON_EXEC_S1B
if [ "$NON_EXEC_S1B" -gt 0 ]; then
    echo "${COLOR_RED}✗${COLOR_RESET} $NON_EXEC_S1B non-executable scripts in S1Bs1stem"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    if [ "$FIX_MODE" == true ]; then
        find "$S1B_ROOT/scripts" -name "*.sh" ! -executable -exec chmod +x {} \;
        echo "${COLOR_GREEN}  Fixed${COLOR_RESET}"
    fi
fi

NON_EXEC_LOCAL=$(find "$HOME/.local/bin" -type f ! -executable | wc -l)
readonly NON_EXEC_LOCAL
if [ "$NON_EXEC_LOCAL" -gt 0 ]; then
    echo "${COLOR_RED}✗${COLOR_RESET} $NON_EXEC_LOCAL non-executable files in .local/bin"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    if [ "$FIX_MODE" == true ]; then
        find "$HOME/.local/bin" -type f ! -executable -exec chmod +x {} \;
        echo "${COLOR_GREEN}  Fixed${COLOR_RESET}"
    fi
fi

# Validate Permissions
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Validating Permissions:${COLOR_RESET}"

# SSH keys
if [ -f "$HOME/.ssh/id_rsa" ]; then
    if [ "$(stat -c %a "$HOME/.ssh/id_rsa" 2>/dev/null || echo "000")" != "600" ]; then
        echo "${COLOR_RED}✗${COLOR_RESET} SSH key id_rsa has incorrect permissions (should be 600)"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        if [ "$FIX_MODE" == true ]; then
            chmod 600 "$HOME/.ssh/id_rsa"
            echo "${COLOR_GREEN}  Fixed${COLOR_RESET}"
        fi
    fi
fi

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    if [ "$(stat -c %a "$HOME/.ssh/id_ed25519" 2>/dev/null || echo "000")" != "600" ]; then
        echo "${COLOR_RED}✗${COLOR_RESET} SSH key id_ed25519 has incorrect permissions (should be 600)"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        if [ "$FIX_MODE" == true ]; then
            chmod 600 "$HOME/.ssh/id_ed25519"
            echo "${COLOR_GREEN}  Fixed${COLOR_RESET}"
        fi
    fi
fi

# GPG keys
if [ -d "$HOME/.gnupg" ]; then
    if [ "$(stat -c %a "$HOME/.gnupg" 2>/dev/null || echo "000")" != "700" ]; then
        echo "${COLOR_RED}✗${COLOR_RESET} GPG directory has incorrect permissions (should be 700)"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        if [ "$FIX_MODE" == true ]; then
            chmod 700 "$HOME/.gnupg"
            echo "${COLOR_GREEN}  Fixed${COLOR_RESET}"
        fi
    fi
fi

# Validate Configuration Structure
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Validating Configuration:${COLOR_RESET}"

REQUIRED_DIRS=(
    "$HOME/.config"
    "$HOME/.config/dwm"
    "$HOME/.config/waybar"
    "$S1B_ROOT/scripts"
    "$S1B_ROOT/install"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "${COLOR_RED}✗${COLOR_RESET} Missing directory: $dir"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
        if [ "$FIX_MODE" == true ]; then
            mkdir -p "$dir"
            echo "${COLOR_GREEN}  Created${COLOR_RESET}"
        fi
    fi
done

# Validate Dependencies
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Validating Dependencies:${COLOR_RESET}"

CRITICAL_DEPS=(bash git sudo)
OPTIONAL_DEPS=(stow)

for dep in "${CRITICAL_DEPS[@]}"; do
    if ! command -v $dep &>/dev/null; then
        echo "${COLOR_RED}✗${COLOR_RESET} Missing critical dependency: $dep"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

for dep in "${OPTIONAL_DEPS[@]}"; do
    if ! command -v $dep &>/dev/null; then
        echo "${COLOR_YELLOW}⚠${COLOR_RESET} Missing optional dependency: $dep"
    fi
done

# Validate dotfiles-s1b
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Validating dotfiles-s1b:${COLOR_RESET}"

if [ ! -d "$HOME/Desktop/dotfiles-s1b" ]; then
    echo "${COLOR_RED}✗${COLOR_RESET} dotfiles-s1b not found at $HOME/Desktop/dotfiles-s1b"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    if [ ! -d "$HOME/Desktop/dotfiles-s1b/.git" ]; then
        echo "${COLOR_YELLOW}⚠${COLOR_RESET} dotfiles-s1b is not a git repository"
    fi
fi

# Summary
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Validation Summary ━━━${COLOR_RESET}"
echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    echo "${COLOR_BOLD}${COLOR_GREEN}✓ No Issues Found!${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}S1Bs1stem is properly configured.${COLOR_RESET}"
    exit 0
elif [ "$FIX_MODE" == true ]; then
    echo "${COLOR_BOLD}${COLOR_YELLOW}⚠  Some Issues Auto-Fixed${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}Run again without --fix to verify all issues are resolved.${COLOR_RESET}"
    exit 1
else
    echo "${COLOR_BOLD}${COLOR_RED}✗ Found $ISSUES_FOUND Issue(s)${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}Run with --fix flag to auto-fix:${COLOR_RESET}"
    echo "  $0 --fix"
    echo ""
    exit 2
fi
