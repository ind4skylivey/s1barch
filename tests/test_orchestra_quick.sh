#!/bin/bash
# Test rápido de ORCHESTRA.sh

ORCHESTRA_DIR="$(cd "$(dirname "$0")/../install" && pwd)"
PASSED=0
FAILED=0

echo "🧪 ORCHESTRA Quick Test Suite"
echo ""

# Test 1: Script exists
if [[ -f "$ORCHESTRA_DIR/ORCHESTRA.sh" ]]; then
    echo "✓ Script exists"
    PASSED=$((PASSED + 1))
else
    echo "✗ Script exists"
    FAILED=$((FAILED + 1))
fi

# Test 2: Syntax check
if bash -n "$ORCHESTRA_DIR/ORCHESTRA.sh" 2>/dev/null; then
    echo "✓ Syntax check"
    PASSED=$((PASSED + 1))
else
    echo "✗ Syntax check"
    FAILED=$((FAILED + 1))
fi

# Test 3: Help message
if timeout 5 "$ORCHESTRA_DIR/ORCHESTRA.sh" --help 2>&1 | grep -q "Usage:"; then
    echo "✓ Help message"
    PASSED=$((PASSED + 1))
else
    echo "✗ Help message"
    FAILED=$((FAILED + 1))
fi

# Test 4: Dry-run mode
if timeout 5 "$ORCHESTRA_DIR/ORCHESTRA.sh" --dry-run 2>&1 | grep -q "DRY RUN"; then
    echo "✓ Dry-run mode"
    PASSED=$((PASSED + 1))
else
    echo "✗ Dry-run mode"
    FAILED=$((FAILED + 1))
fi

# Test 5: Check preflight scripts
preflight_ok=true
for script in 000_environment_selector.sh 001_dependencies_check.sh 002_disk_space_check.sh 003_network_check.sh; do
    if [[ ! -f "$ORCHESTRA_DIR/preflight/$script" ]]; then
        preflight_ok=false
    fi
done

if $preflight_ok; then
    echo "✓ Preflight scripts"
    PASSED=$((PASSED + 1))
else
    echo "✗ Preflight scripts"
    FAILED=$((FAILED + 1))
fi

# Test 6: Count modules
module_count=$(find "$ORCHESTRA_DIR/modules" -name "*.sh" 2>/dev/null | wc -l)
if [[ $module_count -ge 5 ]]; then
    echo "✓ Module scripts ($module_count found)"
    PASSED=$((PASSED + 1))
else
    echo "✗ Module scripts (only $module_count found)"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "═══════════════════════════════════"
echo "Results: $PASSED passed, $FAILED failed"
echo "═══════════════════════════════════"

if [[ $FAILED -eq 0 ]]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed"
    exit 1
fi
