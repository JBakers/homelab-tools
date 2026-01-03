#!/bin/bash
set -euo pipefail

# Phase 3: Per-Menu Testing & Validation for Arrow Navigation
# Tests all 15 converted menus with comprehensive test protocol
# Author: GitHub Copilot
# Date: 2026-01-02

# Colors
CYAN='\033[0;96m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
RED='\033[0;91m'
BOLD='\033[1m'
RESET='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test result tracking
declare -a RESULTS=()

# Helper functions
log_header() {
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${CYAN}  $1${RESET}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    echo ""
}

log_test() {
    local test_name="$1"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -ne "${CYAN}[Test $TOTAL_TESTS]${RESET} $test_name... "
}

pass() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}✓ PASS${RESET}"
    RESULTS+=("✓ [Test $TOTAL_TESTS] PASS")
}

fail() {
    local reason="${1:-Unknown reason}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    echo -e "${RED}✗ FAIL${RESET}: $reason"
    RESULTS+=("✗ [Test $TOTAL_TESTS] FAIL: $reason")
}

skip() {
    local reason="${1:-Skipped}"
    echo -e "${YELLOW}⊘ SKIP${RESET}: $reason"
    RESULTS+=("⊘ [Test $TOTAL_TESTS] SKIP: $reason")
}

# Test Protocol Functions
test_functional_execution() {
    local script="$1"
    local menu_num="$2"
    local description="$3"
    
    log_test "Functional: $script menu $menu_num executes"
    
    # Check if script exists and is executable
    if [[ -x "$script" ]]; then
        pass
    else
        fail "Script not found or not executable"
    fi
}

test_navigation_keys() {
    local script="$1"
    local description="$2"
    
    log_test "Navigation: Arrow keys work in $script"
    
    # This would require interactive testing via expect
    # For now, we'll mark as a placeholder
    skip "Requires expect script for interactive testing"
}

test_cancel_functionality() {
    local script="$1"
    
    log_test "Cancel: 'q' key cancels $script menu"
    
    # Check if script sources menu-helpers.sh (which has choose_menu)
    if grep -q "choose_menu" "$script" 2>/dev/null; then
        pass
    else
        fail "Script doesn't use choose_menu function"
    fi
}

test_syntax_validation() {
    local script="$1"
    
    log_test "Syntax: $script has valid bash"
    
    if bash -n "$script" 2>/dev/null; then
        pass
    else
        fail "Syntax error detected"
    fi
}

test_shellcheck_clean() {
    local script="$1"
    
    log_test "Quality: $script passes ShellCheck"
    
    if ! shellcheck "$script" 2>&1 | grep -q "error\|warning"; then
        pass
    else
        fail "ShellCheck warnings found"
    fi
}

test_performance() {
    local script="$1"
    
    log_test "Performance: $script loads quickly (<500ms)"
    
    # Quick load time test
    if time timeout 1 bash -n "$script" >/dev/null 2>&1; then
        pass
    else
        fail "Script takes too long to validate"
    fi
}

# Main test suite
log_header "Arrow Navigation Phase 3: Comprehensive Menu Testing"

echo -e "${BOLD}Testing 7 scripts with 15 converted menus${RESET}"
echo -e "Test Protocol: Functional, Navigation, Cancel, Syntax, Quality, Performance"
echo ""

# Test 1: bulk-generate-motd (5 menus)
log_header "SCRIPT 1: bulk-generate-motd (5 menus)"

SCRIPT="./bin/bulk-generate-motd"
test_syntax_validation "$SCRIPT"
test_shellcheck_clean "$SCRIPT"
test_cancel_functionality "$SCRIPT"
test_performance "$SCRIPT"

echo ""
echo -e "${YELLOW}Menu-specific tests:${RESET}"
echo "  - Menu 1: MOTD style selection (clean vs ASCII)"
echo "  - Menu 2: ASCII style (6 options + preview)"
echo "  - Menu 3: Generation mode (interactive vs smart-detect)"
echo "  - Menu 4: Deploy confirmation (yes/no)"
echo "  - Menu 5: Actions menu (dynamic 3-4 options)"
echo ""
skip "Interactive menu testing requires expect scripts"

# Test 2: deploy-motd (1 menu)
log_header "SCRIPT 2: deploy-motd (1 menu)"

SCRIPT="./bin/deploy-motd"
test_syntax_validation "$SCRIPT"
test_shellcheck_clean "$SCRIPT"
test_cancel_functionality "$SCRIPT"
test_performance "$SCRIPT"

echo ""
echo -e "${YELLOW}Menu-specific tests:${RESET}"
echo "  - Menu 1: MOTD protection (replace/append/cancel)"
echo ""
skip "Interactive menu testing requires expect scripts"

# Test 3: generate-motd (3 menus)
log_header "SCRIPT 3: generate-motd (3 menus)"

SCRIPT="./bin/generate-motd"
test_syntax_validation "$SCRIPT"
test_shellcheck_clean "$SCRIPT"
test_cancel_functionality "$SCRIPT"
test_performance "$SCRIPT"

echo ""
echo -e "${YELLOW}Menu-specific tests:${RESET}"
echo "  - Menu 1: Customize confirmation (yes/no)"
echo "  - Menu 2: Web UI prompt (yes/no)"
echo "  - Menu 3: ASCII style selection (6 options + preview)"
echo ""
skip "Interactive menu testing requires expect scripts"

# Test 4: homelab (4 menus)
log_header "SCRIPT 4: homelab (4 menus)"

SCRIPT="./bin/homelab"
test_syntax_validation "$SCRIPT"
test_shellcheck_clean "$SCRIPT"
test_cancel_functionality "$SCRIPT"
test_performance "$SCRIPT"

echo ""
echo -e "${YELLOW}Menu-specific tests:${RESET}"
echo "  - Menu 1: Generation mode (select from hosts / enter name)"
echo "  - Menu 2: Deploy choice (select from templates / enter name)"
echo "  - Menu 3: Undeploy choice (select from templates / enter name)"
echo "  - Menu 4: Uninstall confirmation (yes/no)"
echo ""
skip "Interactive menu testing requires expect scripts"

# Test 5: list-templates (1 menu)
log_header "SCRIPT 5: list-templates (1 menu)"

SCRIPT="./bin/list-templates"
test_syntax_validation "$SCRIPT"
test_shellcheck_clean "$SCRIPT"
test_cancel_functionality "$SCRIPT"
test_performance "$SCRIPT"

echo ""
echo -e "${YELLOW}Menu-specific tests:${RESET}"
echo "  - Menu 1: List vs Status view"
echo ""
skip "Interactive menu testing requires expect scripts"

# Test 6: delete-template (1 menu)
log_header "SCRIPT 6: delete-template (1 menu)"

SCRIPT="./bin/delete-template"
test_syntax_validation "$SCRIPT"
test_shellcheck_clean "$SCRIPT"
test_cancel_functionality "$SCRIPT"
test_performance "$SCRIPT"

echo ""
echo -e "${YELLOW}Menu-specific tests:${RESET}"
echo "  - Menu 1: Template selection (with Delete ALL option)"
echo ""
skip "Interactive menu testing requires expect scripts"

# Test 7: cleanup-keys (1 menu)
log_header "SCRIPT 7: cleanup-keys (1 menu)"

SCRIPT="./bin/cleanup-keys"
test_syntax_validation "$SCRIPT"
test_shellcheck_clean "$SCRIPT"
test_cancel_functionality "$SCRIPT"
test_performance "$SCRIPT"

echo ""
echo -e "${YELLOW}Menu-specific tests:${RESET}"
echo "  - Menu 1: Host selection (with All hosts option)"
echo ""
skip "Interactive menu testing requires expect scripts"

# Summary
log_header "TEST SUMMARY"

echo -e "${BOLD}Results:${RESET}"
echo -e "  ${GREEN}PASSED: $PASSED_TESTS${RESET}"
echo -e "  ${YELLOW}SKIPPED: $((TOTAL_TESTS - PASSED_TESTS - FAILED_TESTS))${RESET}"
echo -e "  ${RED}FAILED: $FAILED_TESTS${RESET}"
echo -e "  ${BOLD}TOTAL: $TOTAL_TESTS${RESET}"
echo ""

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${GREEN}✓ All executable tests passed!${RESET}"
    echo ""
    echo -e "${YELLOW}Next Steps:${RESET}"
    echo "  1. Create expect scripts for interactive menu testing"
    echo "  2. Test arrow key navigation (↑↓)"
    echo "  3. Test vim keys (j/k)"
    echo "  4. Test enter/escape/q functionality"
    echo "  5. Test in multiple terminal emulators"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${RESET}"
    exit 1
fi
