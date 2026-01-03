#!/bin/bash
# UX Test: Invalid Input Handling
# Verifies scripts handle invalid/malicious input gracefully
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Invalid Input Handling${RESET}"
echo ""

# Test command injection prevention
test_injection_prevention() {
    echo "Testing command injection prevention..."
    echo ""
    
    # Test generate-motd with malicious input
    if command -v generate-motd &>/dev/null; then
        # Try command injection patterns
        local patterns=(
            "; echo hacked"
            "| cat /etc/passwd"
            "\$(whoami)"
            "\`id\`"
            "../../../etc/passwd"
        )
        
        for pattern in "${patterns[@]}"; do
            result=$(echo "n" | generate-motd "$pattern" 2>&1 || true)
            
            if echo "$result" | grep -qi "invalid\|error\|not allowed\|rejected"; then
                echo -e "  ${GREEN}✓${RESET} generate-motd rejects: $pattern"
                ((PASS++))
            elif echo "$result" | grep -qi "hacked\|passwd\|uid="; then
                echo -e "  ${RED}✗${RESET} generate-motd VULNERABLE to: $pattern"
                ((FAIL++))
            else
                echo -e "  ${YELLOW}○${RESET} generate-motd handles: $pattern (check manually)"
            fi
        done
    fi
}

# Test empty input handling
test_empty_input() {
    echo ""
    echo "Testing empty input handling..."
    echo ""
    
    local commands=(
        "generate-motd"
        "deploy-motd"
        "cleanup-keys"
        "delete-template"
    )
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            result=$($cmd "" 2>&1 || true)
            
            if echo "$result" | grep -qi "error\|usage\|required\|missing\|provide"; then
                echo -e "  ${GREEN}✓${RESET} $cmd handles empty input gracefully"
                ((PASS++))
            else
                echo -e "  ${YELLOW}○${RESET} $cmd with empty input - check behavior"
            fi
        fi
    done
}

# Test special characters in service names
test_special_chars() {
    echo ""
    echo "Testing special character handling..."
    echo ""
    
    if command -v generate-motd &>/dev/null; then
        local special_chars=(
            "test service"     # space
            "test\ttab"        # tab
            "test\nnewline"    # newline
            "test'quote"       # single quote
            'test"double'      # double quote
            "test&amp"         # ampersand
        )
        
        for name in "${special_chars[@]}"; do
            result=$(echo "n" | generate-motd "$name" 2>&1 || true)
            
            if echo "$result" | grep -qi "invalid\|error\|only.*allowed"; then
                echo -e "  ${GREEN}✓${RESET} Rejects special chars: ${name:0:15}..."
                ((PASS++))
            else
                echo -e "  ${YELLOW}○${RESET} Accepts/handles: ${name:0:15}..."
            fi
        done
    fi
}

# Test input validation in scripts
check_input_validation() {
    echo ""
    echo "Checking input validation patterns in code..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Check for input validation regex
        if grep -qE '\[\[.*=~.*\^\[a-zA-Z\]|\[\[.*!.*=~' "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} $name has regex input validation"
            ((PASS++))
        else
            # Check for other validation
            if grep -qi "validate\|sanitize\|check.*input" "$script" 2>/dev/null; then
                echo -e "  ${GREEN}✓${RESET} $name has input validation"
                ((PASS++))
            else
                # Scripts that accept user input should validate
                if grep -q "read -p\|\$1\|\${1" "$script" 2>/dev/null; then
                    echo -e "  ${YELLOW}⚠${RESET} $name accepts input but no clear validation"
                fi
            fi
        fi
    done
}

# Test non-existent file handling
test_nonexistent_files() {
    echo ""
    echo "Testing non-existent file handling..."
    echo ""
    
    if command -v deploy-motd &>/dev/null; then
        result=$(deploy-motd "nonexistent_service_12345" 2>&1 || true)
        
        if echo "$result" | grep -qi "not found\|does not exist\|no template"; then
            echo -e "  ${GREEN}✓${RESET} deploy-motd handles non-existent template"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} deploy-motd with non-existent service"
        fi
    fi
    
    if command -v delete-template &>/dev/null; then
        result=$(echo "n" | delete-template "nonexistent_service_12345" 2>&1 || true)
        
        if echo "$result" | grep -qi "not found\|does not exist\|no template"; then
            echo -e "  ${GREEN}✓${RESET} delete-template handles non-existent template"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} delete-template with non-existent service"
        fi
    fi
}

# Run checks
test_injection_prevention
test_empty_input
test_special_chars
check_input_validation
test_nonexistent_files

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Invalid Input: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "INPUT_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "INPUT_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
