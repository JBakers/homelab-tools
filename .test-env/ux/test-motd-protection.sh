#!/bin/bash
# UX Test: MOTD Protection Messages
# Verifies MOTD protection shows Replace/Append/Cancel options
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing MOTD Protection System${RESET}"
echo ""

# Check deploy-motd has protection logic
check_protection_code() {
    echo "Checking deploy-motd for MOTD protection..."
    
    local file="/opt/homelab-tools/bin/deploy-motd"
    if [[ ! -f "$file" ]]; then
        echo -e "  ${RED}✗${RESET} deploy-motd not found"
        ((FAIL++))
        return
    fi
    
    # Check for HLT marker detection
    if grep -q "HLT-MOTD-START\|HLT.*MOTD" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Checks for HLT markers"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} Missing HLT marker detection"
        ((FAIL++))
    fi
    
    # Check for existing MOTD detection
    if grep -qi "existing\|already\|motd.*exist\|found.*motd" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Detects existing MOTDs"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${RESET} May not detect existing MOTDs"
    fi
    
    # Check for Replace option
    if grep -qi "replace" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Has Replace option"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} Missing Replace option"
        ((FAIL++))
    fi
    
    # Check for Append option
    if grep -qi "append" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Has Append option"
        ((PASS++))
    else
        echo -e "  ${YELLOW}○${RESET} No Append option (may be OK)"
    fi
    
    # Check for Cancel option
    if grep -qi "cancel\|skip\|abort" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Has Cancel option"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} Missing Cancel option"
        ((FAIL++))
    fi
    
    # Check for backup before replace
    if grep -qi "backup" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Creates backup before replace"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${RESET} May not create backup"
    fi
}

# Check bulk-generate-motd shows protection
check_bulk_protection() {
    echo ""
    echo "Checking bulk-generate-motd for protection visibility..."
    
    local file="/opt/homelab-tools/bin/bulk-generate-motd"
    if [[ ! -f "$file" ]]; then
        echo -e "  ${YELLOW}○${RESET} bulk-generate-motd not found"
        return
    fi
    
    # Check if bulk uses deploy-motd or has own protection
    if grep -q "deploy-motd" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Uses deploy-motd for deployment"
        ((PASS++))
        
        # Check if output is visible (not hidden)
        if grep -q ">/dev/null\|2>/dev/null\|&>/dev/null" "$file" 2>/dev/null; then
            # Check if it's suppressing deploy output
            if grep -qE "deploy-motd.*>/dev/null" "$file" 2>/dev/null; then
                echo -e "  ${RED}✗${RESET} deploy-motd output may be hidden"
                ((FAIL++))
            else
                echo -e "  ${GREEN}✓${RESET} deploy-motd output should be visible"
                ((PASS++))
            fi
        else
            echo -e "  ${GREEN}✓${RESET} No output suppression detected"
            ((PASS++))
        fi
    else
        echo -e "  ${YELLOW}⚠${RESET} bulk-generate has own deployment logic"
        
        # Check for protection in bulk
        if grep -qi "replace\|append\|cancel\|existing" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Has protection options"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} Missing protection in bulk mode"
            ((FAIL++))
        fi
    fi
}

# Check undeploy-motd protects non-HLT
check_undeploy_protection() {
    echo ""
    echo "Checking undeploy-motd protection..."
    
    local file="/opt/homelab-tools/bin/undeploy-motd"
    if [[ ! -f "$file" ]]; then
        echo -e "  ${YELLOW}○${RESET} undeploy-motd not found"
        return
    fi
    
    # Check for HLT marker check before delete
    if grep -q "HLT-MOTD-START\|HLT.*MOTD" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Checks for HLT markers before removal"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} May remove non-HLT MOTDs (dangerous)"
        ((FAIL++))
    fi
    
    # Check for warning on non-HLT
    if grep -qi "not.*hlt\|third.*party\|external\|preserve" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Warns about non-HLT MOTDs"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${RESET} May not warn about non-HLT MOTDs"
    fi
}

# Run checks
check_protection_code
check_bulk_protection
check_undeploy_protection

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "MOTD Protection: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "MOTD_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "MOTD_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
