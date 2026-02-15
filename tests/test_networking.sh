#!/bin/bash
# ============================================================
#  NETWORKING SCRIPTS TEST SUITE
#  ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NETWORKING_DIR="$SCRIPT_DIR/../scripts/networking"
REPORT_FILE="$HOME/.s1b_network_test_$(date +%Y%m%d_%H%M%S).txt"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Helper functions
test_start() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Testing: $1 ... "
}

test_pass() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo "PASS"
}

test_fail() {
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo "FAIL - $1"
    echo "  └─ Reason: $1" >> "$REPORT_FILE"
}

test_skip() {
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    echo "SKIP - $1"
}

# Start test suite
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   Networking Scripts Test Suite            ║"
echo "╚══════════════════════════════════════════╝"
echo ""

cat > "$REPORT_FILE" << EOF
========================================
 S1Bs1stem Networking Scripts Test Report
========================================

Test Date: $(date)
System: $(uname -sr)
User: ${USER:-github}

========================================

EOF

# === SECTION 1: File Existence ===
echo "━━━ File Existence Checks ━━━"

SCRIPTS=(
    "dns_switch.sh"
    "network_meter.sh"
    "network_status.sh"
    "tailscale_toggle.sh"
    "vpn_connect.sh"
    "wifi_toggle.sh"
    "iphone_vnc.sh"
)

for script in "${SCRIPTS[@]}"; do
    test_start "$script exists"
    if [ -f "$NETWORKING_DIR/$script" ]; then
        test_pass
    else
        test_fail "$script not found"
    fi
done

echo ""

# === SECTION 2: Script Permissions ===
echo "━━━ Script Permissions ━━━"

for script in "${SCRIPTS[@]}"; do
    test_start "$script is executable"
    if [ -x "$NETWORKING_DIR/$script" ]; then
        test_pass
    else
        test_fail "$script is not executable"
    fi
done

echo ""

# === SECTION 3: Syntax Validation ===
echo "━━━ Syntax Validation ━━━"

for script in "${SCRIPTS[@]}"; do
    test_start "$script syntax"
    if bash -n "$NETWORKING_DIR/$script" 2>/dev/null; then
        test_pass
    else
        test_fail "Syntax error in $script"
    fi
done

echo ""

# === SECTION 4: Dependency Checks ===
echo "━━━ Dependency Checks ━━━"

test_start "nmcli available"
if command -v nmcli &>/dev/null; then
    test_pass
else
    test_skip "nmcli not installed"
fi

test_start "curl available"
if command -v curl &>/dev/null; then
    test_pass
else
    test_fail "curl not found"
fi

test_start "jq available"
if command -v jq &>/dev/null; then
    test_pass
else
    test_skip "jq not installed (optional)"
fi

test_start "speedtest-cli available"
if command -v speedtest-cli &>/dev/null; then
    test_pass
else
    test_skip "speedtest-cli not installed (optional)"
fi

echo ""

# === SECTION 5: Network Status Script ===
echo "━━━ Network Status Script Tests ━━━"

test_start "network_status.sh --help"
if bash "$NETWORKING_DIR/network_status.sh" --help &>/dev/null; then
    test_pass
else
    test_fail "network_status.sh --help failed"
fi

echo ""

# === SECTION 6: WiFi Toggle Script ===
echo "━━━ WiFi Toggle Script Tests ━━━"

test_start "wifi_toggle.sh --help"
if bash "$NETWORKING_DIR/wifi_toggle.sh" --help &>/dev/null; then
    test_pass
else
    test_fail "wifi_toggle.sh --help failed"
fi

if command -v nmcli &>/dev/null; then
    test_start "wifi_toggle.sh --status"
    if bash "$NETWORKING_DIR/wifi_toggle.sh" --status &>/dev/null; then
        test_pass
    else
        test_fail "wifi_toggle.sh --status failed"
    fi
fi

echo ""

# === SECTION 7: VPN Script ===
echo "━━━ VPN Script Tests ━━━"

test_start "vpn_connect.sh --help"
if bash "$NETWORKING_DIR/vpn_connect.sh" --help &>/dev/null; then
    test_pass
else
    test_fail "vpn_connect.sh --help failed"
fi

if command -v nmcli &>/dev/null; then
    test_start "vpn_connect.sh --list"
    if bash "$NETWORKING_DIR/vpn_connect.sh" --list &>/dev/null; then
        test_pass
    else
        test_fail "vpn_connect.sh --list failed"
    fi
fi

echo ""

# === SECTION 8: DNS Script ===
echo "━━━ DNS Script Tests ━━━"

test_start "dns_switch.sh --help"
if bash "$NETWORKING_DIR/dns_switch.sh" --help &>/dev/null; then
    test_pass
else
    test_fail "dns_switch.sh --help failed"
fi

echo ""

# === SECTION 9: Network Meter Script ===
echo "━━━ Network Meter Script Tests ━━━"

test_start "network_meter.sh --help"
if bash "$NETWORKING_DIR/network_meter.sh" --help &>/dev/null; then
    test_pass
else
    test_fail "network_meter.sh --help failed"
fi

test_skip "Skipping actual speed test (takes too long)"

echo ""

# === SECTION 10: Tailscale Script ===
echo "━━━ Tailscale Script Tests ━━━"

if [ -f "$NETWORKING_DIR/tailscale_toggle.sh" ]; then
    test_start "tailscale_toggle.sh --help"
    if bash "$NETWORKING_DIR/tailscale_toggle.sh" --help &>/dev/null; then
        test_pass
    else
        test_fail "tailscale_toggle.sh --help failed"
    fi
else
    test_skip "tailscale_toggle.sh not found"
fi

echo ""

# === TEST SUMMARY ===
echo "━━━ Test Summary ━━━"
echo ""
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Skipped: $SKIPPED_TESTS"
echo ""

if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_PERCENT=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "Success Rate: ${SUCCESS_PERCENT}%"
    echo ""
fi

cat >> "$REPORT_FILE" << EOF

========================================
Test Summary
========================================

Total Tests: $TOTAL_TESTS
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Skipped: $SKIPPED_TESTS

Success Rate: ${SUCCESS_PERCENT:-0}%

========================================

EOF

echo "Detailed report saved to: $REPORT_FILE"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo "✓ All Tests Passed!"
    exit 0
elif [ $FAILED_TESTS -lt 5 ]; then
    echo "⚠  Tests Passed with Minor Issues"
    echo "Review the report: $REPORT_FILE"
    exit 1
else
    echo "✗ Multiple Tests Failed"
    echo "Review the report: $REPORT_FILE"
    exit 2
fi
