#!/bin/bash
# ============================================================
#  TEST MODULES - Test individual S1Bs1stem modules
#  Usage: ./tests/test_modules.sh [module_name] [--verbose]
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

echo "${COLOR_BOLD}${COLOR_Mauve}╔════════════════════════════════════╗${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}║   S1Bs1stem Module Tests       ║${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}╚════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Test Common Functions
echo "${COLOR_BOLD}${COLOR_Mauve}Common Functions:${COLOR_RESET}"
for func in functions logger colors rollback; do
    test_start "$func.sh"
    if [ -f "$HOME/Desktop/S1Bs1stem/scripts/common/$func.sh" ]; then
        test_pass
    else
        test_fail "File not found"
    fi
done

# Test Detection Layer
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Detection Layer:${COLOR_RESET}"
for script in detect_env detect_services get_active_env; do
    test_start "$script.sh"
    if [ -f "$HOME/Desktop/S1Bs1stem/scripts/detection/$script.sh" ] && [ -x "$HOME/Desktop/S1Bs1stem/scripts/detection/$script.sh" ]; then
        test_pass
    else
        test_fail "Not executable"
    fi
done

# Test Sync Layer
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Sync Layer:${COLOR_RESET}"
for script in sync_from_s1b verify_sync; do
    test_start "$script.sh"
    if [ -f "$HOME/Desktop/S1Bs1stem/scripts/sync/$script.sh" ] && [ -x "$HOME/Desktop/S1Bs1stem/scripts/sync/$script.sh" ]; then
        test_pass
    else
        test_fail "Not executable"
    fi
done

# Test Orchestration
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Orchestration:${COLOR_RESET}"
for category in rofi waybar display workflow; do
    test_start "$category/setup.sh"
    if [ -f "$HOME/Desktop/S1Bs1stem/scripts/$category/setup.sh" ] && [ -x "$HOME/Desktop/S1Bs1stem/scripts/$category/setup.sh" ]; then
        test_pass
    else
        test_fail "Not executable"
    fi
done

# Test Rollback
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}Rollback:${COLOR_RESET}"
for script in snapshot_create snapshot_restore snapshot_list snapshot_delete; do
    test_start "$script.sh"
    if [ -f "$HOME/Desktop/S1Bs1stem/scripts/rollback/$script.sh" ] && [ -x "$HOME/Desktop/S1Bs1stem/scripts/rollback/$script.sh" ]; then
        test_pass
    else
        test_fail "Not executable"
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
