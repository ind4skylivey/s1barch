#!/bin/bash
# ============================================================
#  TEST ALL - Complete test suite for S1Bs1stem
#  Usage: ./tests/test_all.sh [--verbose] [--report]
#  ============================================================

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common/functions.sh"
source "$SCRIPT_DIR/../scripts/common/logger.sh"
source "$SCRIPT_DIR/../scripts/common/colors.sh"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0
WARNING_TESTS=0

# Report file
REPORT_FILE="$HOME/.s1b_test_report_$(date +%Y%m%d_%H%M%S).txt"

# Helper functions
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
    echo "  └─ ${COLOR_TEXT}Reason:${COLOR_RESET} $1" >> "$REPORT_FILE"
}

test_skip() {
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    echo "${COLOR_YELLOW}SKIP${COLOR_RESET} - $1"
}

test_warn() {
    WARNING_TESTS=$((WARNING_TESTS + 1))
    echo "${COLOR_YELLOW}WARN${COLOR_RESET} - $1"
}

# Start test suite
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}╔══════════════════════════════════════════╗${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}║      S1Bs1stem Complete Test Suite      ║${COLOR_RESET}"
echo "${COLOR_BOLD}${COLOR_Mauve}╚══════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Clear previous reports
cat > "$REPORT_FILE" << EOF
========================================
 S1Bs1stem Test Report
========================================

Test Date: $(date)
System: $(uname -sr)
Kernel: $(uname -r)
Shell: $SHELL
User: ${USER:-unknown}

========================================

EOF

# === SECTION 1: System Requirements ===
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ System Requirements ━━━${COLOR_RESET}"

test_start "Bash 4.0+ installed"
if [ "${BASH_VERSION%%.*}" -ge 4 ]; then
    test_pass "Bash ${BASH_VERSION}"
else
    test_fail "Bash version too old: ${BASH_VERSION}"
fi

test_start "Sudo available"
if command -v sudo &>/dev/null; then
    test_pass "Sudo is available"
else
    test_fail "Sudo not found"
fi

test_start "Git installed"
if command -v git &>/dev/null; then
    test_pass "Git is available"
else
    test_fail "Git not found"
fi

test_start "GNU Stow installed"
if command -v stow &>/dev/null; then
    test_pass "GNU Stow is available"
else
    test_warn "GNU Stow not found (optional)"
fi

# === SECTION 2: S1Bs1stem Core ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ S1Bs1stem Core Components ━━━${COLOR_RESET}"

test_start "S1Bs1stem directory exists"
if [ -d "$SCRIPT_DIR/.." ]; then
    test_pass "S1Bs1stem directory found"
else
    test_fail "S1Bs1stem directory not found"
fi

test_start "Scripts directory exists"
if [ -d "$SCRIPT_DIR/../scripts" ]; then
    test_pass "Scripts directory found"
else
    test_fail "Scripts directory not found"
fi

test_start "Common functions available"
if [ -f "$SCRIPT_DIR/../scripts/common/functions.sh" ]; then
    test_pass "functions.sh exists"
else
    test_fail "functions.sh not found"
fi

test_start "Logger system available"
if [ -f "$SCRIPT_DIR/../scripts/common/logger.sh" ]; then
    test_pass "logger.sh exists"
else
    test_fail "logger.sh not found"
fi

test_start "Color system available"
if [ -f "$SCRIPT_DIR/../scripts/common/colors.sh" ]; then
    test_pass "colors.sh exists"
else
    test_fail "colors.sh not found"
fi

# === SECTION 3: Detection Layer ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Detection Layer ━━━${COLOR_RESET}"

test_start "Detection scripts available"
if [ -d "$SCRIPT_DIR/../scripts/detection" ]; then
    DETECTION_SCRIPTS=(
        "detect_env.sh"
        "detect_services.sh"
        "get_active_env.sh"
    )
    
    ALL_PRESENT=0
    for script in "${DETECTION_SCRIPTS[@]}"; do
        if [ -f "$SCRIPT_DIR/../scripts/detection/$script" ]; then
            ALL_PRESENT=$((ALL_PRESENT + 1))
        fi
    done
    
    if [ $ALL_PRESENT -eq ${#DETECTION_SCRIPTS[@]} ]; then
        test_pass "All detection scripts available"
    else
        test_fail "Missing detection scripts ($ALL_PRESENT/${#DETECTION_SCRIPTS[@]})"
    fi
else
    test_fail "Detection directory not found"
fi

# === SECTION 4: Sync Layer ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Sync Layer ━━━${COLOR_RESET}"

test_start "Sync scripts available"
if [ -d "$SCRIPT_DIR/../scripts/sync" ]; then
    SYNC_SCRIPTS=(
        "sync_from_s1b.sh"
        "verify_sync.sh"
    )
    
    ALL_PRESENT=0
    for script in "${SYNC_SCRIPTS[@]}"; do
        if [ -f "$SCRIPT_DIR/../scripts/sync/$script" ]; then
            ALL_PRESENT=$((ALL_PRESENT + 1))
        fi
    done
    
    if [ $ALL_PRESENT -eq ${#SYNC_SCRIPTS[@]} ]; then
        test_pass "All sync scripts available"
    else
        test_fail "Missing sync scripts ($ALL_PRESENT/${#SYNC_SCRIPTS[@]})"
    fi
else
    test_fail "Sync directory not found"
fi

# === SECTION 5: Orchestration Scripts ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Orchestration Scripts ━━━${COLOR_RESET}"

test_start "Rofi setup script available"
if [ -f "$SCRIPT_DIR/../scripts/rofi/setup.sh" ] && [ -x "$SCRIPT_DIR/../scripts/rofi/setup.sh" ]; then
    test_pass "rofi/setup.sh available and executable"
else
    test_fail "rofi/setup.sh not found or not executable"
fi

test_start "Waybar setup script available"
if [ -f "$SCRIPT_DIR/../scripts/waybar/setup.sh" ] && [ -x "$SCRIPT_DIR/../scripts/waybar/setup.sh" ]; then
    test_pass "waybar/setup.sh available and executable"
else
    test_fail "waybar/setup.sh not found or not executable"
fi

test_start "Display setup script available"
if [ -f "$SCRIPT_DIR/../scripts/display/setup.sh" ] && [ -x "$SCRIPT_DIR/../scripts/display/setup.sh" ]; then
    test_pass "display/setup.sh available and executable"
else
    test_fail "display/setup.sh not found or not executable"
fi

test_start "Workflow setup script available"
if [ -f "$SCRIPT_DIR/../scripts/workflow/setup.sh" ] && [ -x "$SCRIPT_DIR/../scripts/workflow/setup.sh" ]; then
    test_pass "workflow/setup.sh available and executable"
else
    test_fail "workflow/setup.sh not found or not executable"
fi

# === SECTION 6: Rollback System ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Rollback System ━━━${COLOR_RESET}"

test_start "Rollback scripts available"
if [ -d "$SCRIPT_DIR/../scripts/rollback" ]; then
    ROLLBACK_SCRIPTS=(
        "snapshot_create.sh"
        "snapshot_restore.sh"
        "snapshot_list.sh"
        "snapshot_delete.sh"
    )
    
    ALL_PRESENT=0
    for script in "${ROLLBACK_SCRIPTS[@]}"; do
        if [ -f "$SCRIPT_DIR/../scripts/rollback/$script" ] && [ -x "$SCRIPT_DIR/../scripts/rollback/$script" ]; then
            ALL_PRESENT=$((ALL_PRESENT + 1))
        fi
    done
    
    if [ $ALL_PRESENT -eq ${#ROLLBACK_SCRIPTS[@]} ]; then
        test_pass "All rollback scripts available and executable"
    else
        test_fail "Missing or non-executable rollback scripts ($ALL_PRESENT/${#ROLLBACK_SCRIPTS[@]})"
    fi
else
    test_fail "Rollback directory not found"
fi

test_start "Snapshots directory writable"
SNAPSHOTS_DIR="$HOME/.s1b_snapshots"
if [ -w "$SNAPSHOTS_DIR" ] || mkdir -p "$SNAPSHOTS_DIR" && [ -w "$SNAPSHOTS_DIR" ]; then
    test_pass "Snapshots directory writable"
else
    test_fail "Snapshots directory not writable"
fi

# === SECTION 7: Installation Scripts ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Installation Scripts ━━━${COLOR_RESET}"

test_start "ORCHESTRA.sh available"
if [ -f "$SCRIPT_DIR/../install/ORCHESTRA.sh" ] && [ -x "$SCRIPT_DIR/../install/ORCHESTRA.sh" ]; then
    test_pass "ORCHESTRA.sh available and executable"
else
    test_fail "ORCHESTRA.sh not found or not executable"
fi

test_start "Module scripts available"
MODULE_DIRS=("preflight" "modules" "post_install")
ALL_PRESENT=0
for module_dir in "${MODULE_DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/../install/$module_dir" ]; then
        ALL_PRESENT=$((ALL_PRESENT + 1))
    fi
done

if [ $ALL_PRESENT -eq ${#MODULE_DIRS[@]} ]; then
    test_pass "All module directories available"
else
    test_fail "Missing module directories ($ALL_PRESENT/${#MODULE_DIRS[@]})"
fi

# === SECTION 8: Configuration Files ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Configuration Files ━━━${COLOR_RESET}"

test_start ".config directory exists"
if [ -d "$HOME/.config" ]; then
    test_pass ".config directory found"
else
    test_fail ".config directory not found"
fi

test_start "DWM config exists"
if [ -f "$HOME/.config/dwm/config.h" ] || [ -d "$HOME/.config/dwm" ]; then
    test_pass "DWM config found"
else
    test_warn "DWM config not found"
fi

test_start "Waybar config exists"
if [ -d "$HOME/.config/waybar" ]; then
    test_pass "Waybar config found"
else
    test_warn "Waybar config not found"
fi

# === SECTION 9: dotfiles-s1b Integration ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ dotfiles-s1b Integration ━━━${COLOR_RESET}"

test_start "dotfiles-s1b directory exists"
if [ -d "$HOME/Desktop/dotfiles-s1b" ]; then
    test_pass "dotfiles-s1b directory found"
else
    test_fail "dotfiles-s1b directory not found"
fi

test_start "dotfiles-s1b is git repository"
if [ -d "$HOME/Desktop/dotfiles-s1b/.git" ]; then
    test_pass "dotfiles-s1b is a git repository"
else
    test_warn "dotfiles-s1b not a git repository"
fi

# === SECTION 10: Utility Commands ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Utility Commands ━━━${COLOR_RESET}"

UTILITIES=(
    "s1b-stow:Stow management"
    "s1b-check-perms:Permission check"
    "s1b-fix-perms:Permission fix"
    "s1b-snapshot:Snapshot management"
    "s1b-restore:Snapshot restore"
    "s1b-list:Snapshot list"
    "s1b-delete:Snapshot delete"
)

for util in "${UTILITIES[@]}"; do
    IFS=: read -r cmd name <<< "$util"
    
    test_start "$name command available"
    if [ -f "$HOME/.local/bin/$cmd" ] && [ -x "$HOME/.local/bin/$cmd" ]; then
        test_pass "$name available"
    else
        test_warn "$name not available"
    fi
done

# === TEST SUMMARY ===
echo ""
echo "${COLOR_BOLD}${COLOR_Mauve}━━━ Test Summary ━━━${COLOR_RESET}"
echo ""

echo "${COLOR_TEXT}Total Tests:${COLOR_RESET} $TOTAL_TESTS"
echo "${COLOR_GREEN}Passed:${COLOR_RESET} $PASSED_TESTS"
echo "${COLOR_RED}Failed:${COLOR_RESET} $FAILED_TESTS"
echo "${COLOR_YELLOW}Warnings:${COLOR_RESET} $WARNING_TESTS"
echo "${COLOR_TEXT}Skipped:${COLOR_RESET} $SKIPPED_TESTS"
echo ""

# Calculate percentage
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_PERCENT=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "${COLOR_TEXT}Success Rate:${COLOR_RESET} ${SUCCESS_PERCENT}%"
    echo ""
fi

# Append summary to report
cat >> "$REPORT_FILE" << EOF

========================================
Test Summary
========================================

Total Tests: $TOTAL_TESTS
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Warnings: $WARNING_TESTS
Skipped: $SKIPPED_TESTS

Success Rate: ${SUCCESS_PERCENT:-0}%

========================================

EOF

# Final verdict
echo "${COLOR_TEXT}Detailed report saved to:${COLOR_RESET} $REPORT_FILE"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo "${COLOR_BOLD}${COLOR_GREEN}✓ All Tests Passed!${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}S1Bs1stem is ready to use!${COLOR_RESET}"
    exit 0
elif [ $FAILED_TESTS -lt 5 ]; then
    echo "${COLOR_BOLD}${COLOR_YELLOW}⚠  Tests Passed with Minor Issues${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}Review the report for details:${COLOR_RESET} $REPORT_FILE"
    exit 1
else
    echo "${COLOR_BOLD}${COLOR_RED}✗ Multiple Tests Failed${COLOR_RESET}"
    echo ""
    echo "${COLOR_TEXT}Review the report and fix issues:${COLOR_RESET} $REPORT_FILE"
    exit 2
fi
