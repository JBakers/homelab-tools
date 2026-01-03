#!/bin/bash
# UX Test: Arrow Navigation in All Menus
# Verifies all interactive menus support arrow key navigation
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test-helpers.sh" 2>/dev/null || true

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Arrow Navigation in All Menus${RESET}"
echo ""

# Test function: Check if script uses show_arrow_menu or choose_menu
check_arrow_menu() {
    local script="$1"
    local name="$2"
    
    if grep -q "show_arrow_menu\|choose_menu" "$script" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} $name uses arrow menu"
        ((PASS++))
        return 0
    else
        # Check if script has any interactive menus (read -p patterns)
        if grep -q "read -p" "$script" 2>/dev/null; then
            echo -e "  ${RED}✗${RESET} $name uses read -p instead of arrow menu"
            ((FAIL++))
            return 1
        else
            echo -e "  ${YELLOW}○${RESET} $name has no interactive menus (OK)"
            return 0
        fi
    fi
}

# Test function: Check menu source
check_menu_source() {
    local script="$1"
    local name="$2"
    
    if grep -q "source.*menu-helpers.sh" "$script" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} $name sources menu-helpers.sh"
        ((PASS++))
        return 0
    else
        if grep -q "show_arrow_menu\|choose_menu" "$script" 2>/dev/null; then
            echo -e "  ${RED}✗${RESET} $name uses menu but doesn't source menu-helpers.sh"
            ((FAIL++))
            return 1
        fi
        return 0
    fi
}

echo "Checking bin/* scripts for arrow menu usage..."
echo ""

# Scripts that SHOULD have arrow menus
MENU_SCRIPTS=(
    "/opt/homelab-tools/bin/homelab:homelab"
    "/opt/homelab-tools/bin/generate-motd:generate-motd"
    "/opt/homelab-tools/bin/deploy-motd:deploy-motd"
    "/opt/homelab-tools/bin/bulk-generate-motd:bulk-generate-motd"
    "/opt/homelab-tools/bin/delete-template:delete-template"
    "/opt/homelab-tools/bin/cleanup-keys:cleanup-keys"
    "/opt/homelab-tools/bin/edit-hosts:edit-hosts"
)

for item in "${MENU_SCRIPTS[@]}"; do
    script="${item%%:*}"
    name="${item##*:}"
    
    if [[ -f "$script" ]]; then
        check_arrow_menu "$script" "$name"
        check_menu_source "$script" "$name"
    else
        echo -e "  ${YELLOW}⚠${RESET} $name not found at $script"
    fi
done

echo ""
echo "Checking for legacy menu patterns (should be 0)..."
echo ""

# Check for old menu patterns that should NOT exist
LEGACY_PATTERNS=(
    "read -p.*\[1-9\]"
    "read -p.*Enter.*number"
    "read -p.*Choose.*option"
    "select.*in.*do"
)

for script in /opt/homelab-tools/bin/*; do
    name=$(basename "$script")
    for pattern in "${LEGACY_PATTERNS[@]}"; do
        if grep -qE "$pattern" "$script" 2>/dev/null; then
            echo -e "  ${RED}✗${RESET} $name contains legacy menu pattern: $pattern"
            ((FAIL++))
        fi
    done
done

if [[ $FAIL -eq 0 ]]; then
    echo -e "  ${GREEN}✓${RESET} No legacy menu patterns found"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Arrow Navigation: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "ARROW_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "ARROW_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
