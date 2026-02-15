#!/bin/bash
# ============================================================
#  TEST INTEGRATIONS - Test S1Bs1stem integration
#  Usage: ./tests/test_integrations.sh
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

test_start() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "${COLOR_TEXT}Testing:${COLOR_RESET} $1 ... "
}

test_pass() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo "${COLOR_GREEN}PASS${COLOR_RESET}"
}

test_fail() {
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo "${COLOR_RED}FAIL${COLOR_RESET} - $1"
}

test_warn() {
    echo "${COLOR_YELLOW}WARN${COLOR_RESET} - $1"
}

echo "${COLOR_BOLD}${COLOR_Mauve}╔════════════════════════════════════╗${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}║   S1Bs1stem Integration Tests   ║${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}╚════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Test dotfiles-s1b Integration
echo "${COLOR_BOLD}${COLOR_Mauve}dotfiles-s1b Integration:${COLOR_RESET}"

test_start "dotfiles-s1b directory"
if [ -d "$HOME/Desktop/dotfiles-s1b" ]; then
    test_pass
else
    test_fail "Not found"
fi

test_start "dotfiles-s1b is git repo"
if [ -d "$HOME/Desktop/dotfiles-s1b/.git" ]; then
    test_pass
else
    test_warn "Not a git repo"
fi

# Test Configuration Sync
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Configuration Sync:${COLOR_RESET}"

test_start "DWM config syncable"
if [ -d "$HOME/Desktop/dotfiles-s1b/.config/dwm" ]; then
    test_pass
else
    test_warn "DWM config not in dotfiles-s1b"
fi

test_start "Waybar config syncable"
if [ -d "$HOME/Desktop/dotfiles-s1b/.config/waybar" ]; then
    test_pass
else
    test_warn "Waybar config not in dotfiles-s1b"
fi

test_start "Rofi config syncable"
if [ -d "$HOME/Desktop/dotfiles-s1b/.config/rofi" ]; then
    test_pass
else
    test_warn "Rofi config not in dotfiles-s1b"
fi

# Test Workflow Integration
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Workflow Integration:${COLOR_RESET}"

test_start "Workflow profiles syncable"
if [ -d "$HOME/Desktop/dotfiles-s1b/workflow" ] || [ -d "$HOME/Desktop/S1Bs1stem/workflow" ]; then
    test_pass
else
    test_fail "No workflow profiles found"
fi

# Test Shell Integration
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Shell Integration:${COLOR_RESET}"

test_start ".zshrc sourced"
if grep -q "S1Bs1stem" "$HOME/.zshrc" 2>/dev/null || grep -q "dotfiles-s1b" "$HOME/.zshrc" 2>/dev/null; then
    test_pass
else
    test_warn ".zshrc may not be configured"
fi

# Test Command Availability
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Command Availability:${COLOR_RESET}"

for cmd in s1b-stow s1b-snapshot s1b-restore s1b-list s1b-delete; do
    test_start "$cmd command"
    if [ -f "$HOME/.local/bin/$cmd" ] && [ -x "$HOME/.local/bin/$cmd" ]; then
        test_pass
    else
        test_fail "Not available"
    fi
done

# Summary
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Summary ━━━${COLOR_RESET}"
echo "${COLOR_TEXT}Total:${COLOR_RESET} $TOTAL_TESTS"
echo "${COLOR_GREEN}Passed:${COLOR_RESET} $PASSED_TESTS"
echo "${COLOR_RED}Failed:${COLOR_RESET} $FAILED_TESTS"
echo ""

if [ $TOTAL_TESTS -gt 0 ]; then
    PERCENT=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "${COLOR_TEXT}Success Rate:${COLOR_RESET} ${PERCENT}%"
    echo ""
fi

[ $FAILED_TESTS -eq 0 ] && exit 0 || exit 1
