#!/bin/bash
# UX Test: Generate MOTD Menu System
# Specifically tests if generate-motd uses arrow menus
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing generate-motd Menu System${RESET}"
echo ""

# Check if generate-motd uses arrow menus for customization
check_arrow_menu_usage() {
    echo "Checking generate-motd for arrow menu usage..."
    
    local file="/opt/homelab-tools/bin/generate-motd"
    
    if [[ ! -f "$file" ]]; then
        echo -e "  ${RED}✗${RESET} generate-motd not found"
        ((FAIL++))
        return
    fi
    
    # Check for menu-helpers source
    if grep -q "source.*menu-helpers.sh" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Sources menu-helpers.sh"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} Does NOT source menu-helpers.sh"
        ((FAIL++))
    fi
    
    # Check for choose_menu or show_arrow_menu calls
    local menu_calls
    menu_calls=$(grep -c "choose_menu\|show_arrow_menu" "$file" 2>/dev/null || echo 0)
    
    if [[ $menu_calls -gt 0 ]]; then
        echo -e "  ${GREEN}✓${RESET} Has $menu_calls arrow menu call(s)"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} No arrow menu calls found"
        ((FAIL++))
    fi
    
    # Check for legacy read -p prompts that should be menus
    echo ""
    echo "Checking for prompts that should be menus..."
    
    # Customize prompt
    if grep -q 'read.*Customize' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${RESET} 'Customize?' uses read -p (should be menu)"
    else
        echo -e "  ${GREEN}✓${RESET} No legacy 'Customize?' prompt"
        ((PASS++))
    fi
    
    # Web UI prompt
    if grep -q 'read.*Web.*UI' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${RESET} 'Web UI?' uses read -p (could be menu)"
    else
        echo -e "  ${GREEN}✓${RESET} No legacy 'Web UI?' prompt"
        ((PASS++))
    fi
    
    # Deploy prompt
    if grep -q 'read.*[Dd]eploy' "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}○${RESET} 'Deploy now?' uses read -p (acceptable)"
    fi
    
    # ASCII style selection should use menu
    if grep -q "choose_menu.*[Ss]tyle\|show_arrow_menu.*[Ss]tyle" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} ASCII style uses arrow menu"
        ((PASS++))
    elif grep -q "Style\|style" "$file" 2>/dev/null; then
        if grep -q "read.*[Ss]tyle\|read.*choose" "$file" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠${RESET} ASCII style may not use arrow menu"
        else
            echo -e "  ${GREEN}✓${RESET} Style selection handled"
            ((PASS++))
        fi
    fi
}

# Check menu flow logic
check_menu_flow() {
    echo ""
    echo "Checking menu flow and return handling..."
    
    local file="/opt/homelab-tools/bin/generate-motd"
    
    # Check for MENU_RESULT handling
    if grep -q "MENU_RESULT" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Uses MENU_RESULT"
        ((PASS++))
    else
        echo -e "  ${YELLOW}○${RESET} MENU_RESULT not found (may use different pattern)"
    fi
    
    # Check for -1 (quit) handling
    if grep -qE "\-1\)|\"-1\"|== -1" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Handles quit (-1)"
        ((PASS++))
    else
        if grep -q 'q).*exit\|"q").*exit' "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} Handles 'q' quit"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} Quit handling unclear"
        fi
    fi
}

# Interactive test with expect
test_interactive() {
    echo ""
    echo "Testing interactive behavior..."
    
    if ! command -v expect &>/dev/null; then
        echo -e "  ${YELLOW}⚠${RESET} expect not installed, skipping"
        return
    fi
    
    # Check if menu appears during generation
    local result
    result=$(timeout 5 expect -c '
        spawn generate-motd testux
        expect {
            -re "Navigate|↑|↓|arrows" {
                puts "MENU_FOUND"
                send "q"
            }
            -re "Customize.*y/N" {
                puts "PROMPT_FOUND"
                send "n\n"
            }
            timeout {
                puts "TIMEOUT"
            }
            eof {
                puts "EOF"
            }
        }
        expect eof
    ' 2>&1) || true
    
    if echo "$result" | grep -q "MENU_FOUND"; then
        echo -e "  ${GREEN}✓${RESET} generate-motd shows arrow menu"
        ((PASS++))
    elif echo "$result" | grep -q "PROMPT_FOUND"; then
        echo -e "  ${YELLOW}⚠${RESET} generate-motd uses y/N prompts (not arrow menu)"
    else
        echo -e "  ${YELLOW}○${RESET} Interactive test inconclusive"
    fi
    
    # Cleanup test template
    rm -f "$HOME/.local/share/homelab-tools/templates/testux.sh"
}

# Run checks
check_arrow_menu_usage
check_menu_flow
test_interactive

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "generate-motd Menu: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# This is a critical test - generate-motd SHOULD use arrow menus
if [[ $FAIL -gt 0 ]]; then
    echo -e "${YELLOW}⚠ RECOMMENDATION: Convert generate-motd prompts to arrow menus${RESET}"
    echo ""
fi

# Save results
echo "GENMOTD_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "GENMOTD_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
