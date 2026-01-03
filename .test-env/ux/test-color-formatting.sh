#!/bin/bash
# UX Test: Color Formatting Consistency
# Verifies consistent color usage across all scripts
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Color Formatting Consistency${RESET}"
echo ""

# Expected color variables
EXPECTED_COLORS=(
    "GREEN"
    "RED"
    "YELLOW"
    "CYAN"
    "RESET"
)

OPTIONAL_COLORS=(
    "BLUE"
    "MAGENTA"
    "BOLD"
    "DIM"
)

check_color_definitions() {
    echo "Checking color variable definitions..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        missing=""
        
        for color in "${EXPECTED_COLORS[@]}"; do
            if ! grep -q "^$color=\|^local $color=" "$script" 2>/dev/null; then
                missing+="$color "
            fi
        done
        
        if [[ -z "$missing" ]]; then
            echo -e "  ${GREEN}✓${RESET} $name has all required colors"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} $name missing: $missing"
        fi
    done
}

check_color_usage() {
    echo ""
    echo "Checking color usage patterns..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Check for raw ANSI codes (should use variables instead)
        if grep -qE "\\\\033\[0;3[0-9]m|\\\\e\[0;3[0-9]m" "$script" 2>/dev/null; then
            # Check if also has color variables
            if grep -q "GREEN=\|RED=\|CYAN=" "$script" 2>/dev/null; then
                echo -e "  ${YELLOW}○${RESET} $name: mixes raw ANSI codes with variables"
            else
                echo -e "  ${RED}✗${RESET} $name: uses raw ANSI codes (should use variables)"
                ((FAIL++))
            fi
        else
            echo -e "  ${GREEN}✓${RESET} $name: uses color variables"
            ((PASS++))
        fi
    done
}

check_reset_usage() {
    echo ""
    echo "Checking RESET usage (prevent color bleed)..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Count echo -e with colors vs with RESET
        local color_count
        color_count=$(grep -cE "echo.*\\\$\{(GREEN|RED|YELLOW|CYAN|BOLD)" "$script" 2>/dev/null || echo 0)
        local reset_count
        reset_count=$(grep -cE "echo.*\\\$\{RESET\}|\\\$RESET" "$script" 2>/dev/null || echo 0)
        
        if [[ $color_count -eq 0 ]]; then
            # No colors used
            continue
        fi
        
        if [[ $reset_count -ge $color_count ]]; then
            echo -e "  ${GREEN}✓${RESET} $name: RESET used appropriately"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} $name: $color_count colors, $reset_count resets (may have color bleed)"
        fi
    done
}

check_semantic_colors() {
    echo ""
    echo "Checking semantic color usage..."
    echo "(Green=success, Red=error, Yellow=warning, Cyan=info)"
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        issues=0
        
        # Check for correct semantic usage
        # Error messages should use RED
        if grep -qi "error\|failed\|✗" "$script" 2>/dev/null; then
            if ! grep -qE "RED.*error|RED.*failed|RED.*✗" "$script" 2>/dev/null; then
                # Check if error messages use RED
                error_lines=$(grep -n "echo.*error\|echo.*failed\|echo.*✗" "$script" 2>/dev/null | head -3)
                if echo "$error_lines" | grep -q "RED\|red"; then
                    : # OK
                else
                    ((issues++))
                fi
            fi
        fi
        
        # Success messages should use GREEN
        if grep -qi "success\|complete\|✓" "$script" 2>/dev/null; then
            if ! grep -qE "GREEN.*success|GREEN.*complete|GREEN.*✓" "$script" 2>/dev/null; then
                success_lines=$(grep -n "echo.*success\|echo.*complete\|echo.*✓" "$script" 2>/dev/null | head -3)
                if echo "$success_lines" | grep -q "GREEN\|green"; then
                    : # OK
                else
                    ((issues++))
                fi
            fi
        fi
        
        if [[ $issues -eq 0 ]]; then
            echo -e "  ${GREEN}✓${RESET} $name: semantic colors correct"
            ((PASS++))
        else
            echo -e "  ${YELLOW}⚠${RESET} $name: $issues semantic color issues"
        fi
    done
}

# Run checks
check_color_definitions
check_color_usage
check_reset_usage
check_semantic_colors

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Color Formatting: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "COLOR_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "COLOR_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
