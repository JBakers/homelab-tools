#!/bin/bash
# UX Test: Navigation Help Text
# Verifies all menus show navigation instructions
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Navigation Help Text Presence${RESET}"
echo ""

# Check menu-helpers.sh for navigation help
check_menu_helpers() {
    local file="/opt/homelab-tools/lib/menu-helpers.sh"
    
    echo "Checking menu-helpers.sh for navigation instructions..."
    
    # Check for navigation hint patterns
    local patterns=(
        "↑.*↓\|up.*down"
        "Enter.*select"
        "q.*quit\|ESC.*quit"
        "Navigate.*arrows\|Use.*↑"
    )
    
    for pattern in "${patterns[@]}"; do
        if grep -qi "$pattern" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Found: $pattern"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} Missing: $pattern"
            ((FAIL++))
        fi
    done
}

# Check if show_arrow_menu displays help
check_menu_footer() {
    local file="/opt/homelab-tools/lib/menu-helpers.sh"
    
    echo ""
    echo "Checking for consistent menu footer..."
    
    # Expected footer format
    local expected="Navigate:.*↑/↓.*Enter.*select.*q.*quit"
    
    if grep -qE "$expected" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Menu footer contains navigation instructions"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${RESET} Menu footer may be incomplete"
        echo "    Expected pattern: Navigate: ↑/↓ | Enter to select | q to quit"
        
        # Check what IS there
        if grep -q "echo.*Navigate\|printf.*Navigate" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Some navigation text found"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} No navigation footer found"
            ((FAIL++))
        fi
    fi
}

# Check individual scripts for help in their custom menus
check_script_help() {
    local script="$1"
    local name="$2"
    
    # Scripts should not have custom help if they use menu-helpers
    if grep -q "source.*menu-helpers.sh" "$script" 2>/dev/null; then
        # OK - uses centralized menu system
        return 0
    fi
    
    # If custom menu, should have help
    if grep -q "read -p\|while.*read" "$script" 2>/dev/null; then
        if grep -qi "arrow\|↑\|↓\|navigate" "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} $name has navigation help"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} $name may need navigation help"
        fi
    fi
}

# Run checks
check_menu_helpers
check_menu_footer

echo ""
echo "Checking individual scripts..."

for script in /opt/homelab-tools/bin/*; do
    name=$(basename "$script")
    check_script_help "$script" "$name"
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Navigation Help: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "NAVHELP_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "NAVHELP_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
