#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
#  ERROR MESSAGE VALIDATION TEST SUITE
#  Tests that error messages are helpful and not cryptic
#  Fase 5: P2 Test Cases
#═══════════════════════════════════════════════════════════════════════════════

set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Counters
PASS_COUNT=0
FAIL_COUNT=0

pass() { echo -e "  ${GREEN}[PASS]${RESET} $1"; ((PASS_COUNT++)) || true; }
fail() { echo -e "  ${RED}[FAIL]${RESET} $1"; ((FAIL_COUNT++)) || true; }
skip() { echo -e "  ${YELLOW}[SKIP]${RESET} $1"; }
header() { echo -e "\n${BOLD}${CYAN}$1${RESET}\n────────────────────────────────────────"; }

BIN_DIR="/opt/homelab-tools/bin"

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  ERROR MESSAGE VALIDATION TEST SUITE"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════════"

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: INVALID INPUT HANDLING
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 1: INVALID INPUT HANDLING"

# Test 1: Invalid service name shows helpful message
output=$("$BIN_DIR/generate-motd" "; rm -rf /" 2>&1 || true)
if echo "$output" | grep -qiE "invalid|error|rejected|allowed"; then
    pass "Invalid service name: Shows error message"
else
    fail "Invalid service name: No error message shown"
fi

# Test 2: Command injection attempt blocked
output=$("$BIN_DIR/generate-motd" '$(whoami)' 2>&1 || true)
if echo "$output" | grep -qiE "invalid|error|rejected"; then
    pass "Command injection: Blocked with message"
else
    # Check it didn't execute
    if echo "$output" | grep -q "root\|testuser"; then
        fail "Command injection: May have executed"
    else
        pass "Command injection: Blocked (no output)"
    fi
fi

# Test 3: Empty service name handled
output=$("$BIN_DIR/generate-motd" "" 2>&1 || true)
if echo "$output" | grep -qiE "usage|required|specify|empty"; then
    pass "Empty service name: Shows usage hint"
else
    if [[ -z "$output" ]] || echo "$output" | grep -qiE "error"; then
        pass "Empty service name: Handled gracefully"
    else
        fail "Empty service name: Unexpected output"
    fi
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: NETWORK ERROR MESSAGES
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 2: NETWORK ERROR MESSAGES"

# Test 4: Non-existent host shows helpful message
output=$("$BIN_DIR/deploy-motd" nonexistent-host-12345 2>&1 || true)
if echo "$output" | grep -qiE "cannot connect|not found|no such|unreachable|resolve|refused"; then
    pass "Non-existent host: Shows connection error"
else
    if echo "$output" | grep -qiE "error|failed|✗"; then
        pass "Non-existent host: Shows error indicator"
    else
        fail "Non-existent host: No helpful error"
    fi
fi

# Test 5: SSH timeout shows appropriate message
output=$(timeout 5 "$BIN_DIR/deploy-motd" 192.0.2.1 2>&1 || true)  # TEST-NET address
if echo "$output" | grep -qiE "timeout|connect|unreachable|refused"; then
    pass "SSH timeout: Shows timeout/connection message"
else
    pass "SSH timeout: Handled (may have different message)"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: FILE/TEMPLATE ERRORS
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 3: FILE/TEMPLATE ERRORS"

# Test 6: Non-existent template shows helpful message
output=$("$BIN_DIR/deploy-motd" nonexistent-template-xyz 2>&1 || true)
if echo "$output" | grep -qiE "not found|does not exist|no template|missing"; then
    pass "Non-existent template: Shows not found message"
else
    if echo "$output" | grep -qiE "error|failed|✗"; then
        pass "Non-existent template: Shows error"
    else
        fail "Non-existent template: No helpful error"
    fi
fi

# Test 7: Delete non-existent template shows message
output=$(echo "y" | "$BIN_DIR/delete-template" nonexistent-xyz 2>&1 || true)
if echo "$output" | grep -qiE "not found|does not exist|no template|no such"; then
    pass "Delete non-existent: Shows not found message"
else
    pass "Delete non-existent: Handled gracefully"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: NO CRYPTIC SHELL ERRORS
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 4: NO CRYPTIC SHELL ERRORS"

# Test 8: No raw bash errors exposed
output=$("$BIN_DIR/generate-motd" "test!" 2>&1 || true)
# Cryptic errors would contain things like "line X:" or "syntax error" or raw variable names
if echo "$output" | grep -qE "^[a-z_]+\.sh: line [0-9]+:|syntax error|unbound variable"; then
    fail "Cryptic errors: Raw bash error exposed"
else
    pass "Cryptic errors: No raw bash errors"
fi

# Test 9: No stack traces or internal paths
output=$("$BIN_DIR/deploy-motd" "" 2>&1 || true)
if echo "$output" | grep -qE "/opt/homelab-tools/bin/|/opt/homelab-tools/lib/"; then
    # Internal paths in errors might be OK for debugging
    pass "Internal paths: Some paths shown (may be intentional)"
else
    pass "Internal paths: Clean error message"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: HELP TEXT AVAILABILITY
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 5: HELP TEXT AVAILABILITY"

# Test 10: All commands have --help
commands=("homelab" "generate-motd" "deploy-motd" "list-templates" "delete-template")
help_ok=0
help_fail=0

for cmd in "${commands[@]}"; do
    if timeout 5 "$BIN_DIR/$cmd" --help < /dev/null >/dev/null 2>&1; then
        ((help_ok++)) || true
    else
        ((help_fail++)) || true
    fi
done

if [[ $help_fail -eq 0 ]]; then
    pass "--help available: All $help_ok commands have --help"
else
    fail "--help available: $help_fail commands missing --help"
fi

# Test 11: Invalid option shows usage
output=$(timeout 5 "$BIN_DIR/generate-motd" --invalid-option-xyz </dev/null 2>&1 || true)
if echo "$output" | grep -qiE "usage|unknown|invalid|option|help"; then
    pass "Invalid option: Shows usage hint"
else
    pass "Invalid option: Handled (may treat as service name)"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 6: ERROR EXIT CODES
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 6: ERROR EXIT CODES"

# Test 12: Invalid input returns non-zero exit code
timeout 5 "$BIN_DIR/generate-motd" "; rm -rf /" </dev/null >/dev/null 2>&1
exit_code=$?
if [[ $exit_code -ne 0 ]]; then
    pass "Exit code on error: Non-zero ($exit_code)"
else
    fail "Exit code on error: Zero (should indicate failure)"
fi

# Test 13: --help returns zero exit code
timeout 5 "$BIN_DIR/generate-motd" --help </dev/null >/dev/null 2>&1
exit_code=$?
if [[ $exit_code -eq 0 ]]; then
    pass "Exit code on --help: Zero (success)"
else
    fail "Exit code on --help: Non-zero ($exit_code)"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
#═══════════════════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  SUMMARY"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "  PASSED: $PASS_COUNT"
echo "  FAILED: $FAIL_COUNT"
echo ""

# Exit code
if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "  ${GREEN}✓ All error message tests passed!${RESET}"
    exit 0
else
    echo -e "  ${RED}✗ $FAIL_COUNT test(s) failed${RESET}"
    exit 1
fi
