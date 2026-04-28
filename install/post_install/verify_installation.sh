#!/bin/bash
# ============================================================
#  VERIFY INSTALLATION - Complete system health check
#  Purpose: Verify all components are properly installed and configured
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

# Verification counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Helper functions
check_passed() {
    ((PASSED_CHECKS++))
    ((TOTAL_CHECKS++))
    echo "${COLOR_GREEN}✓${COLOR_RESET} $1"
}

check_failed() {
    ((FAILED_CHECKS++))
    ((TOTAL_CHECKS++))
    echo "${COLOR_RED}✗${COLOR_RESET} $1"
}

check_warn() {
    ((WARNINGS++))
    ((TOTAL_CHECKS++))
    echo "${COLOR_YELLOW}⚠${COLOR_RESET} $1"
}

check_section() {
    echo ""
    echo "${COLOR_BOLD}${COLOR_Mauve}━━━ $1 ━━━${COLOR_RESET}"
}

# Start verification
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}╔══════════════════════════════════════════╗${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}║   S1Bs1stem Installation Verification      ║${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}╚══════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Check 1: System Information
check_section "System Information"
echo "${COLOR_TEXT}OS: ${COLOR_RESET}$(uname -sr)"
echo "${COLOR_TEXT}Kernel: ${COLOR_RESET}$(uname -r)"
echo "${COLOR_TEXT}Shell: ${COLOR_RESET}$SHELL"
echo "${COLOR_TEXT}User: ${COLOR_RESET}$USER"
echo "${COLOR_TEXT}Home: ${COLOR_RESET}$HOME"
check_passed "System information collected"

# Check 2: Required Dependencies
check_section "Required Dependencies"

DEPENDENCIES=(
    "bash:Bash"
    "git:Git"
    "sudo:Sudo"
    "stow:GNU Stow"
)

for dep in "${DEPENDENCIES[@]}"; do
    IFS=: read -r cmd name <<< "$dep"
    if command -v $cmd &>/dev/null; then
        check_passed "$name installed"
    else
        check_failed "$name NOT installed"
    fi
done

# Check 3: Configurations
check_section "Configuration Files"

CONFIG_FILES=(
    "$HOME/.config/dwm: DWM config"
    "$HOME/.config/waybar: Waybar config"
    "$HOME/.config/rofi: Rofi config"
    "$HOME/.config/kitty: Kitty config"
    "$HOME/.config/zellij: Zellij config"
)

for config in "${CONFIG_FILES[@]}"; do
    IFS=: read -r path name <<< "$config"
    if [ -d "$path" ] || [ -f "$path" ]; then
        check_passed "$name exists"
    else
        check_warn "$name not found"
    fi
done

# Check 4: Shell Configuration
check_section "Shell Configuration"

if [ -f "$HOME/.zshrc" ]; then
    check_passed "ZSH config exists"
else
    check_warn "ZSH config not found"
fi

if [ -d "$HOME/.config/zsh" ]; then
    check_passed "ZSH config directory exists"
else
    check_warn "ZSH config directory not found"
fi

if [ -d "$HOME/.config/fish" ]; then
    check_passed "Fish config directory exists"
else
    check_warn "Fish config directory not found"
fi

# Check 5: S1Bs1stem Scripts
check_section "S1Bs1stem Components"

S1B_SCRIPTS=(
    "$S1B_ROOT/scripts/common/functions.sh: Common functions"
    "$S1B_ROOT/scripts/common/logger.sh: Logger"
    "$S1B_ROOT/scripts/detection/detect_env.sh: Detection"
    "$S1B_ROOT/scripts/sync/sync_from_s1b.sh: Sync layer"
)

for script in "${S1B_SCRIPTS[@]}"; do
    IFS=: read -r path name <<< "$script"
    if [ -f "$path" ]; then
        if [ -x "$path" ]; then
            check_passed "$name (executable)"
        else
            check_warn "$name (not executable)"
        fi
    else
        check_failed "$name missing"
    fi
done

# Check 6: Orchestration Scripts
check_section "Orchestration Scripts"

ORCHESTRATION=(
    "$S1B_ROOT/scripts/rofi/setup.sh: Rofi setup"
    "$S1B_ROOT/scripts/waybar/setup.sh: Waybar setup"
    "$S1B_ROOT/scripts/display/setup.sh: Display setup"
    "$S1B_ROOT/scripts/workflow/setup.sh: Workflow setup"
)

for script in "${ORCHESTRATION[@]}"; do
    IFS=: read -r path name <<< "$script"
    if [ -f "$path" ] && [ -x "$path" ]; then
        check_passed "$name"
    else
        check_failed "$name missing or not executable"
    fi
done

# Check 7: Workflows
check_section "Workflows"

if [ -d "$S1B_ROOT/workflow" ]; then
    check_passed "Workflow directory exists"
    
    if [ -d "$S1B_ROOT/workflow/profiles" ]; then
        check_passed "Workflow profiles exist"
    else
        check_warn "Workflow profiles not found"
    fi
    
    if [ -d "$S1B_ROOT/workflow/zellij/layouts" ]; then
        check_passed "Zellij layouts exist"
    else
        check_warn "Zellij layouts not found"
    fi
else
    check_failed "Workflow directory not found"
fi

# Check 8: dotfiles-s1b Sync
check_section "dotfiles-s1b Integration"

DOTFILES_S1B="$HOME/Desktop/dotfiles-s1b"

if [ -d "$DOTFILES_S1B" ]; then
    check_passed "dotfiles-s1b directory exists"
    
    if [ -f "$DOTFILES_S1B/.git/config" ]; then
        check_passed "dotfiles-s1b is a git repository"
    else
        check_warn "dotfiles-s1b git config not found"
    fi
else
    check_failed "dotfiles-s1b directory not found"
fi

# Check 9: Permissions
check_section "File Permissions"

# Check if S1Bs1stem scripts are executable
if [ -d "$S1B_ROOT/scripts" ]; then
    NON_EXEC=$(find "$S1B_ROOT/scripts" -name "*.sh" ! -executable | wc -l)
    if [ "$NON_EXEC" -eq 0 ]; then
        check_passed "All scripts executable"
    else
        check_warn "$NON_EXEC script(s) not executable"
    fi
fi

# Check SSH permissions
if [ -f "$HOME/.ssh/id_rsa" ]; then
    SSH_PERM=$(stat -c %a "$HOME/.ssh/id_rsa" 2>/dev/null || echo "000")
    if [ "$SSH_PERM" == "600" ]; then
        check_passed "SSH key permissions correct (600)"
    else
        check_warn "SSH key permissions incorrect ($SSH_PERM, should be 600)"
    fi
fi

# Check 10: Utilities
check_section "Utility Commands"

UTILITIES=(
    "s1b-stow: Stow management"
    "s1b-check-perms: Permission check"
    "s1b-fix-perms: Permission fix"
)

for util in "${UTILITIES[@]}"; do
    IFS=: read -r cmd name <<< "$util"
    if [ -f "$HOME/.local/bin/$cmd" ] && [ -x "$HOME/.local/bin/$cmd" ]; then
        check_passed "$name available"
    else
        check_warn "$name not available"
    fi
done

# Summary
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Verification Summary ━━━${COLOR_RESET}"
echo ""
echo "${COLOR_TEXT}Total Checks: ${COLOR_RESET}$TOTAL_CHECKS"
echo "${COLOR_GREEN}Passed: ${COLOR_RESET}$PASSED_CHECKS"
echo "${COLOR_RED}Failed: ${COLOR_RESET}$FAILED_CHECKS"
echo "${COLOR_YELLOW}Warnings: ${COLOR_RESET}$WARNINGS"
echo ""

# Calculate percentage
if [ $TOTAL_CHECKS -gt 0 ]; then
    PERCENT=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    echo "${COLOR_TEXT}Success Rate: ${COLOR_RESET}${PERCENT}%"
fi

echo ""

# Final verdict
if [ $FAILED_CHECKS -eq 0 ]; then
    echo "${COLOR_BOLD}${COLOR_GREEN}✓ Installation Verified Successfully!${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}Next Steps:${COLOR_RESET}"
    echo "  1. Restart DWM or logout/login"
    echo "  2. Run: ws-menu (to select workflow)"
    echo "  3. Read docs: https://github.com/ind4skylivey/S1Bs1stem/wiki"
    echo ""
    exit 0
elif [ $FAILED_CHECKS -lt 3 ]; then
    echo "${COLOR_BOLD}${COLOR_YELLOW}⚠ Installation Verified with Minor Issues${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}Run this to fix:${COLOR_RESET}"
    echo "  s1b-fix-perms"
    echo "  s1b-stow restow"
    echo ""
    exit 1
else
    echo "${COLOR_BOLD}${COLOR_RED}✗ Installation Verification Failed${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}Review failed checks above and re-run installation.${COLOR_RESET}"
    echo ""
    exit 2
fi
