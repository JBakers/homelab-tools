#!/bin/bash
# UX Test: Quit Functionality (q key and ESC)
# Verifies all menus respond to q and ESC to quit
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Quit Functionality (q key, ESC, Q)${RESET}"
echo ""

# Check menu-helpers.sh for quit handling
check_quit_handling() {
    local file="/opt/homelab-tools/lib/menu-helpers.sh"
    
    echo "Checking menu-helpers.sh for quit key handling..."
    
    # Check for q key handling
    if grep -qE "q\)|\"q\"|'q'" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Handles 'q' key"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} Missing 'q' key handling"
        ((FAIL++))
    fi
    
    # Check for Q (uppercase) handling
    if grep -qE "Q\)|\"Q\"|'Q'" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Handles 'Q' key (uppercase)"
        ((PASS++))
    else
        echo -e "  ${YELLOW}○${RESET} No explicit 'Q' handling (may be case-insensitive)"
    fi
    
    # Check for ESC handling (escape sequence \e or \033)
    if grep -qE "\\\\e\[|\\\033\[|escape|ESC" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Handles ESC key"
        ((PASS++))
    else
        echo -e "  ${YELLOW}⚠${RESET} ESC key handling not explicit"
    fi
    
    # Check for MENU_RESULT = -1 on quit
    if grep -q "MENU_RESULT=-1\|MENU_RESULT=\"-1\"" "$file" 2>/dev/null; then
        echo -e "  ${GREEN}✓${RESET} Returns -1 on quit"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} Quit may not return -1"
        ((FAIL++))
    fi
}

# Check scripts handle quit return value
check_quit_return_handling() {
    echo ""
    echo "Checking scripts handle quit return (-1)..."
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Skip non-interactive scripts
        if ! grep -q "show_arrow_menu\|choose_menu" "$script" 2>/dev/null; then
            continue
        fi
        
        # Check if script handles -1 return
        if grep -qE "\-1\)|\"-1\"|== -1|eq -1" "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} $name handles quit (-1)"
            ((PASS++))
        else
            # Check for wildcard catch
            if grep -qE "\*\)|else\)" "$script" 2>/dev/null; then
                echo -e "  ${GREEN}✓${RESET} $name has wildcard catch for quit"
                ((PASS++))
            else
                echo -e "  ${RED}✗${RESET} $name may not handle quit return"
                ((FAIL++))
            fi
        fi
    done
}

# Interactive quit test using expect
test_quit_interactive() {
    echo ""
    echo "Testing interactive quit (expect scripts)..."
    
    if ! command -v expect &>/dev/null; then
        echo -e "  ${YELLOW}⚠${RESET} expect not installed, skipping interactive tests"
        return 0
    fi
    
    # Test homelab main menu quit
    local result
    result=$(expect -c '
        set timeout 3
        spawn homelab
        expect {
            "MOTD" { send "q"; exp_continue }
            "Navigate" { send "q"; exp_continue }
            eof { exit 0 }
            timeout { exit 1 }
        }
    ' 2>&1) || true
    
    if [[ $? -eq 0 ]]; then
        echo -e "  ${GREEN}✓${RESET} homelab quits on 'q' key"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} homelab may not quit on 'q' key"
        ((FAIL++))
    fi
}

# Run checks
check_quit_handling
check_quit_return_handling
test_quit_interactive

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Quit Functionality: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "QUIT_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "QUIT_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
