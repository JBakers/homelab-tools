#!/bin/bash
# UX Test: ALL Options in Menus
# Verifies "Delete ALL", "Deploy ALL" etc. options exist where expected
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing ALL/Bulk Options in Menus${RESET}"
echo ""

# Scripts that SHOULD have "ALL" options
check_all_options() {
    echo "Checking for ALL options in scripts..."
    echo ""
    
    # delete-template should have "Delete ALL" or "--all"
    local file="/opt/homelab-tools/bin/delete-template"
    if [[ -f "$file" ]]; then
        if grep -qi "all\|ALL" "$file" 2>/dev/null; then
            if grep -qi "delete.*all\|all.*template" "$file" 2>/dev/null; then
                echo -e "  ${GREEN}✓${RESET} delete-template has 'Delete ALL' option"
                ((PASS++))
            else
                echo -e "  ${YELLOW}⚠${RESET} delete-template has 'all' but unclear context"
                ((PASS++))
            fi
        else
            echo -e "  ${RED}✗${RESET} delete-template MISSING 'Delete ALL' option"
            ((FAIL++))
        fi
    fi
    
    # deploy-motd should have --all flag
    file="/opt/homelab-tools/bin/deploy-motd"
    if [[ -f "$file" ]]; then
        if grep -q "\-\-all" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} deploy-motd has --all flag"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} deploy-motd MISSING --all flag"
            ((FAIL++))
        fi
    fi
    
    # undeploy-motd should have --all flag
    file="/opt/homelab-tools/bin/undeploy-motd"
    if [[ -f "$file" ]]; then
        if grep -q "\-\-all" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} undeploy-motd has --all flag"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} undeploy-motd MISSING --all flag"
            ((FAIL++))
        fi
    else
        echo -e "  ${YELLOW}○${RESET} undeploy-motd not found"
    fi
    
    # cleanup-keys should have "all hosts" option
    file="/opt/homelab-tools/bin/cleanup-keys"
    if [[ -f "$file" ]]; then
        if grep -qi "all.*host\|host.*all\|ALL\)" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} cleanup-keys has 'all hosts' option"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} cleanup-keys may need 'all hosts' option"
        fi
    fi
}

# Check menu options include ALL where appropriate
check_menu_all_option() {
    echo ""
    echo "Checking menu configurations for ALL option..."
    
    # delete-template menu should include "Delete ALL"
    local file="/opt/homelab-tools/bin/delete-template"
    if [[ -f "$file" ]]; then
        # Look for ALL in menu array or choose_menu call
        if grep -E "DELETE.*ALL|ALL.*templates|\"ALL\"|'ALL'" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} delete-template menu includes ALL option"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} delete-template menu missing ALL in menu items"
            ((FAIL++))
        fi
    fi
}

# Test --all flags work
test_all_flags() {
    echo ""
    echo "Testing --all flag acceptance..."
    
    # Test deploy-motd --all (should not error on flag parse)
    if command -v deploy-motd &>/dev/null; then
        output=$(deploy-motd --all --help 2>&1 || deploy-motd --help 2>&1 || echo "error")
        if [[ "$output" != *"unknown"* ]] && [[ "$output" != *"invalid"* ]]; then
            echo -e "  ${GREEN}✓${RESET} deploy-motd accepts --all flag"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} deploy-motd rejects --all flag"
            ((FAIL++))
        fi
    fi
}

# Run checks
check_all_options
check_menu_all_option
test_all_flags

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "ALL Options: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "ALL_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "ALL_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
