#!/bin/bash
# UX Test: Back/Cancel Options
# Verifies all menus have consistent back/cancel functionality
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Back/Cancel Options in Menus${RESET}"
echo ""

# Check for BACK option in menus
check_back_option() {
    echo "Checking for BACK option in menu scripts..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Only check scripts with menus
        if ! grep -q "choose_menu\|show_arrow_menu" "$script" 2>/dev/null; then
            continue
        fi
        
        # Check for BACK in menu options
        if grep -qEi "BACK|Back|back|CANCEL|Cancel|QUIT|Return" "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} $name has back/cancel option"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} $name may need explicit BACK option"
        fi
    done
}

# Check submenus return to parent
check_submenu_return() {
    echo ""
    echo "Checking submenu return patterns..."
    
    # homelab should have BACK options in submenus
    local file="/opt/homelab-tools/bin/homelab"
    if [[ -f "$file" ]]; then
        # Count BACK occurrences vs menu functions
        local back_count
        back_count=$(grep -ci "BACK\|back" "$file" 2>/dev/null || echo 0)
        local menu_count
        menu_count=$(grep -c "choose_menu\|show_arrow_menu" "$file" 2>/dev/null || echo 0)
        
        if [[ $back_count -ge $menu_count ]]; then
            echo -e "  ${GREEN}✓${RESET} homelab has BACK for each submenu"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} homelab: $back_count BACK options for $menu_count menus"
        fi
    fi
}

# Check q key consistently means quit/back
check_q_consistency() {
    echo ""
    echo "Checking 'q' key consistency..."
    
    local file="/opt/homelab-tools/lib/menu-helpers.sh"
    if [[ -f "$file" ]]; then
        if grep -q 'q)' "$file" 2>/dev/null || grep -q '"q"' "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} menu-helpers handles 'q' for quit"
            ((PASS++))
        else
            echo -e "  ${RED}✗${RESET} menu-helpers missing 'q' handling"
            ((FAIL++))
        fi
    fi
}

# Check ESC handling
check_esc_handling() {
    echo ""
    echo "Checking ESC key handling..."
    
    local file="/opt/homelab-tools/lib/menu-helpers.sh"
    if [[ -f "$file" ]]; then
        # ESC is typically \e[ or \033[
        if grep -qE "\\\\e\[|\\\\033\[|\$'\\\\e'" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} ESC key sequence detected"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} ESC key handling unclear"
        fi
    fi
}

# Check left arrow = back (new feature)
check_left_arrow() {
    echo ""
    echo "Checking left arrow (←) = back feature..."
    
    local file="/opt/homelab-tools/lib/menu-helpers.sh"
    if [[ -f "$file" ]]; then
        # Left arrow is \e[D or \033[D
        if grep -qE "\\[D|left" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Left arrow handling found"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} Left arrow = back not implemented (feature request)"
        fi
    fi
}

# Check right arrow = enter (new feature)
check_right_arrow() {
    echo ""
    echo "Checking right arrow (→) = enter feature..."
    
    local file="/opt/homelab-tools/lib/menu-helpers.sh"
    if [[ -f "$file" ]]; then
        # Right arrow is \e[C or \033[C
        if grep -qE "\\[C|right" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Right arrow handling found"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} Right arrow = enter not implemented (feature request)"
        fi
    fi
}

# Run checks
check_back_option
check_submenu_return
check_q_consistency
check_esc_handling
check_left_arrow
check_right_arrow

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Back/Cancel Options: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "BACK_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "BACK_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
