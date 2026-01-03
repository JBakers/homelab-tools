#!/bin/bash
# UX Test Suite - Master Runner
# Tests all User Experience aspects of Homelab Tools
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load test helpers
if [[ -f "$SCRIPT_DIR/lib/test-helpers.sh" ]]; then
    # shellcheck source=lib/test-helpers.sh
    source "$SCRIPT_DIR/lib/test-helpers.sh"
fi

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Counters
TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_SKIP=0

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║         🎨 UX TEST SUITE - Complete User Experience      ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Run individual test suites with timeout
run_test_suite() {
    local name="$1"
    local script="$2"
    local timeout="${3:-30}"  # Default 30s timeout for UX tests
    
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${BOLD}  Running: $name (max ${timeout}s)${RESET}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    
    if [[ -f "$SCRIPT_DIR/$script" ]]; then
        # Use test_with_timeout if available, otherwise regular timeout
        if type test_with_timeout &>/dev/null; then
            if test_with_timeout "$timeout" "$SCRIPT_DIR/$script"; then
                echo -e "${GREEN}✓ $name: PASSED${RESET}"
                ((TOTAL_PASS++)) || true
            else
                echo -e "${RED}✗ $name: FAILED${RESET}"
                ((TOTAL_FAIL++)) || true
            fi
        else
            # Fallback: basic timeout
            if timeout "$timeout" bash "$SCRIPT_DIR/$script"; then
                echo -e "${GREEN}✓ $name: PASSED${RESET}"
                ((TOTAL_PASS++)) || true
            else
                exit_code=$?
                if [[ $exit_code -eq 124 ]]; then
                    echo -e "${RED}⚠ $name: TIMEOUT (${timeout}s)${RESET}"
                else
                    echo -e "${RED}✗ $name: FAILED (exit $exit_code)${RESET}"
                fi
                ((TOTAL_FAIL++)) || true
            fi
        fi
    else
        echo -e "${YELLOW}⚠ $name: SKIPPED (script not found)${RESET}"
        ((TOTAL_SKIP++)) || true
    fi
    echo ""
}

# Test Suites
echo -e "${BOLD}Phase 1: Menu Consistency${RESET}"
run_test_suite "Arrow Navigation" "ux/test-arrow-navigation.sh"
run_test_suite "Navigation Help Text" "ux/test-navigation-help.sh"
run_test_suite "Quit Functionality" "ux/test-quit-keys.sh"

echo -e "${BOLD}Phase 2: Command Help${RESET}"
run_test_suite "Help Flags" "ux/test-help-flags.sh"
run_test_suite "Usage Examples" "ux/test-usage-examples.sh"

echo -e "${BOLD}Phase 3: Feature Completeness${RESET}"
run_test_suite "ALL Options" "ux/test-all-options.sh"
run_test_suite "Back/Cancel Options" "ux/test-back-cancel.sh"
run_test_suite "MOTD Protection" "ux/test-motd-protection.sh"
run_test_suite "Generate MOTD Menu" "ux/test-generate-motd-menu.sh"
run_test_suite "Backup Listing" "ux/test-backup-listing.sh"

echo -e "${BOLD}Phase 4: Visual Consistency${RESET}"
run_test_suite "Color Formatting" "ux/test-color-formatting.sh"
run_test_suite "Box Borders" "ux/test-box-borders.sh"
run_test_suite "Emoji Usage" "ux/test-emoji-usage.sh"

echo -e "${BOLD}Phase 5: Input Handling${RESET}"
run_test_suite "Invalid Input" "ux/test-invalid-input.sh"
run_test_suite "Edge Cases" "ux/test-edge-cases.sh"

# Summary
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║                    UX TEST SUMMARY                       ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Count results from log files
if [[ -f "$SCRIPT_DIR/ux/.ux-test-results" ]]; then
    source "$SCRIPT_DIR/ux/.ux-test-results"
    echo -e "  ${GREEN}PASSED:${RESET}  $TOTAL_PASS"
    echo -e "  ${RED}FAILED:${RESET}  $TOTAL_FAIL"
    echo -e "  ${YELLOW}SKIPPED:${RESET} $TOTAL_SKIP"
    echo ""
    
    if [[ $TOTAL_FAIL -eq 0 ]]; then
        echo -e "${GREEN}✓✓✓ ALL UX TESTS PASSED! 🎉${RESET}"
    else
        echo -e "${RED}✗ $TOTAL_FAIL UX tests need attention${RESET}"
    fi
else
    echo -e "${YELLOW}Run individual test suites for detailed results${RESET}"
fi

echo ""
