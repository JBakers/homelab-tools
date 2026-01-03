#!/bin/bash
# UX Test: Box Border Consistency
# Verifies consistent box drawing across all scripts
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Box Border Consistency${RESET}"
echo ""

# Check for consistent box characters
check_box_characters() {
    echo "Checking box drawing characters..."
    echo ""
    
    # Standard box characters
    local box_chars="╔╗╚╝═║━"
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Check if script uses box drawing
        if grep -q "╔\|═\|╗" "$script" 2>/dev/null; then
            # Check for consistent usage
            local has_top_left has_top_right has_bottom_left has_bottom_right
            has_top_left=$(grep -c "╔" "$script" 2>/dev/null || echo 0)
            has_top_right=$(grep -c "╗" "$script" 2>/dev/null || echo 0)
            has_bottom_left=$(grep -c "╚" "$script" 2>/dev/null || echo 0)
            has_bottom_right=$(grep -c "╝" "$script" 2>/dev/null || echo 0)
            
            if [[ $has_top_left -eq $has_top_right ]] && [[ $has_bottom_left -eq $has_bottom_right ]]; then
                echo -e "  ${GREEN}✓${RESET} $name: box corners balanced"
                ((PASS++))
            else
                echo -e "  ${YELLOW}⚠${RESET} $name: box corners unbalanced (╔:$has_top_left ╗:$has_top_right ╚:$has_bottom_left ╝:$has_bottom_right)"
            fi
        fi
    done
}

# Check box width consistency
check_box_widths() {
    echo ""
    echo "Checking box width consistency..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Extract box top lines and check width
        local widths
        widths=$(grep -oE "╔═+╗" "$script" 2>/dev/null | while read -r line; do echo ${#line}; done | sort -u)
        
        if [[ -z "$widths" ]]; then
            continue
        fi
        
        local width_count
        width_count=$(echo "$widths" | wc -l)
        
        if [[ $width_count -eq 1 ]]; then
            echo -e "  ${GREEN}✓${RESET} $name: consistent box width ($(echo $widths | head -1) chars)"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} $name: multiple box widths ($widths)"
        fi
    done
}

# Check emoji alignment in boxes
check_emoji_alignment() {
    echo ""
    echo "Checking emoji alignment in boxes..."
    echo ""
    
    # Emojis are typically 2 characters wide but display as 1
    # This can cause alignment issues
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Check for emoji + box combination
        if grep -qE "║.*[🎨📝🔧💾🌐🖥️📊⚙️🔑]" "$script" 2>/dev/null; then
            # Check if there's compensating spacing
            if grep -qE "║.*  .*[🎨📝🔧💾🌐🖥️📊⚙️🔑]" "$script" 2>/dev/null; then
                echo -e "  ${GREEN}✓${RESET} $name: emoji spacing appears correct"
                ((PASS++))
            else
                echo -e "  ${YELLOW}○${RESET} $name: has emojis in boxes (check alignment manually)"
            fi
        fi
    done
}

# Check for ASCII fallback
check_ascii_fallback() {
    echo ""
    echo "Checking for ASCII fallback support..."
    echo ""
    
    local menu_helpers="/opt/homelab-tools/lib/menu-helpers.sh"
    
    if [[ -f "$menu_helpers" ]]; then
        # Check for TERM or locale checks
        if grep -qE "TERM\|LC_ALL\|LANG\|ascii" "$menu_helpers" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} menu-helpers may have ASCII fallback"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} No ASCII fallback detected (OK for UTF-8 terminals)"
        fi
    fi
}

# Run checks
check_box_characters
check_box_widths
check_emoji_alignment
check_ascii_fallback

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Box Borders: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "BOX_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "BOX_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
