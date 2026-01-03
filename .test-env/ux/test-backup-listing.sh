#!/bin/bash
# UX Test: Backup Listing Feature
# Tests if backup listing is available and works
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Backup Listing Feature${RESET}"
echo ""

# Check homelab menu for backup option
check_backup_menu() {
    echo "Checking for backup menu in homelab..."
    
    local file="/opt/homelab-tools/bin/homelab"
    
    if [[ ! -f "$file" ]]; then
        echo -e "  ${RED}✗${RESET} homelab not found"
        ((FAIL++))
        return
    fi
    
    # Check for backup-related menu entries
    if grep -qi "backup" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} 'Backup' option in homelab menu"
        ((PASS++))
        
        # Check for backup listing specifically
        if grep -qi "list.*backup\|view.*backup\|show.*backup" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Backup listing option found"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} Backup menu exists but 'list' option unclear"
        fi
    else
        echo -e "  ${RED}✗${RESET} No 'Backup' option in homelab menu"
        ((FAIL++))
    fi
}

# Check cleanup-homelab for backup features
check_cleanup_homelab() {
    echo ""
    echo "Checking cleanup-homelab for backup features..."
    
    local file="/opt/homelab-tools/bin/cleanup-homelab"
    
    if [[ ! -f "$file" ]]; then
        echo -e "  ${YELLOW}○${RESET} cleanup-homelab not found"
        return
    fi
    
    # Check for backup-related functionality
    if grep -qi "backup" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} cleanup-homelab handles backups"
        ((PASS++))
        
        # Check what backup operations are available
        if grep -qi "list.*backup\|show.*backup" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Has backup listing"
            ((PASS++))
        fi
        
        if grep -qi "delete.*backup\|remove.*backup" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Has backup deletion"
            ((PASS++))
        fi
        
        if grep -qi "archive.*backup\|tar.*backup" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Has backup archiving"
            ((PASS++))
        fi
    else
        echo -e "  ${YELLOW}○${RESET} cleanup-homelab may not handle backups"
    fi
}

# Check for backup locations
check_backup_locations() {
    echo ""
    echo "Checking backup location detection..."
    
    # Check if any script references backup locations
    if grep -rq "\.bak\|\.backup\|-backup-\|backup.*dir" /opt/homelab-tools/bin/ 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Backup file patterns found in scripts"
        ((PASS++))
    else
        echo -e "  ${YELLOW}○${RESET} No explicit backup patterns found"
    fi
}

# Test backup listing functionality (if available)
test_backup_listing() {
    echo ""
    echo "Testing backup listing functionality..."
    
    if command -v cleanup-homelab &>/dev/null; then
        # Try to access backup listing
        result=$(echo "q" | cleanup-homelab 2>&1 || true)
        
        if echo "$result" | grep -qi "backup"; then
            echo -e "  ${GREEN}✓${RESET} cleanup-homelab shows backup options"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} cleanup-homelab output unclear"
        fi
    fi
}

# Run checks
check_backup_menu
check_cleanup_homelab
check_backup_locations
test_backup_listing

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Backup Listing: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

if [[ $FAIL -gt 0 ]] || [[ $PASS -lt 3 ]]; then
    echo -e "${YELLOW}⚠ FEATURE REQUEST: Add comprehensive backup listing${RESET}"
    echo "  - List all backups with dates/sizes"
    echo "  - Show backup locations"
    echo "  - Option to restore from backup"
    echo ""
fi

# Save results
echo "BACKUP_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "BACKUP_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
