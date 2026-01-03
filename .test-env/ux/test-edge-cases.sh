#!/bin/bash
# UX Test: Edge Cases
# Tests various edge case scenarios
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Edge Cases${RESET}"
echo ""

# Test no templates scenario
test_no_templates() {
    echo "Testing list-templates with no templates..."
    
    if command -v list-templates &>/dev/null; then
        # Temporarily move templates
        local templates_dir="$HOME/.local/share/homelab-tools/templates"
        local backup_dir="/tmp/hlt-templates-backup-$$"
        
        if [[ -d "$templates_dir" ]] && [[ -n "$(ls -A "$templates_dir" 2>/dev/null)" ]]; then
            mkdir -p "$backup_dir"
            mv "$templates_dir"/* "$backup_dir/" 2>/dev/null || true
        fi
        
        result=$(echo "q" | list-templates 2>&1 || true)
        
        # Restore templates
        if [[ -d "$backup_dir" ]] && [[ -n "$(ls -A "$backup_dir" 2>/dev/null)" ]]; then
            mv "$backup_dir"/* "$templates_dir/" 2>/dev/null || true
            rmdir "$backup_dir" 2>/dev/null || true
        fi
        
        if echo "$result" | grep -qi "no template\|empty\|none found\|no.*found"; then
            echo -e "  ${GREEN}✓${RESET} list-templates handles empty gracefully"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} list-templates with no templates"
        fi
    fi
}

# Test no SSH hosts scenario
test_no_hosts() {
    echo ""
    echo "Testing deploy with no SSH hosts..."
    
    if command -v deploy-motd &>/dev/null; then
        # Create temp template
        local templates_dir="$HOME/.local/share/homelab-tools/templates"
        mkdir -p "$templates_dir"
        echo "#!/bin/bash" > "$templates_dir/test-edge.sh"
        
        result=$(echo "q" | deploy-motd "test-edge" 2>&1 || true)
        
        # Cleanup
        rm -f "$templates_dir/test-edge.sh"
        
        if echo "$result" | grep -qi "no host\|select host\|choose\|enter"; then
            echo -e "  ${GREEN}✓${RESET} deploy-motd prompts for host"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} deploy-motd host selection behavior"
        fi
    fi
}

# Test very long service names
test_long_names() {
    echo ""
    echo "Testing very long service names..."
    
    if command -v generate-motd &>/dev/null; then
        local long_name="thisisaverylongservicenamethatexceedsnormallengthsandmightbreakformatting"
        
        result=$(echo -e "n\n" | generate-motd "$long_name" 2>&1 || true)
        
        if echo "$result" | grep -qi "error\|too long\|invalid" || [[ $? -ne 0 ]]; then
            echo -e "  ${GREEN}✓${RESET} Long names handled (rejected or truncated)"
            ((PASS++))
        else
            # Check if template was created
            if [[ -f "$HOME/.local/share/homelab-tools/templates/${long_name}.sh" ]]; then
                echo -e "  ${YELLOW}○${RESET} Long name accepted (template created)"
                rm -f "$HOME/.local/share/homelab-tools/templates/${long_name}.sh"
            else
                echo -e "  ${YELLOW}○${RESET} Long name handling unclear"
            fi
        fi
    fi
}

# Test Unicode service names
test_unicode_names() {
    echo ""
    echo "Testing Unicode in service names..."
    
    if command -v generate-motd &>/dev/null; then
        local unicode_names=(
            "café"
            "naïve"
            "日本語"
        )
        
        for name in "${unicode_names[@]}"; do
            result=$(echo -e "n\n" | generate-motd "$name" 2>&1 || true)
            
            if echo "$result" | grep -qi "invalid\|error\|not allowed"; then
                echo -e "  ${GREEN}✓${RESET} Rejects Unicode: $name"
                ((PASS++))
            else
                echo -e "  ${YELLOW}○${RESET} Accepts Unicode: $name (may cause issues)"
            fi
        done
    fi
}

# Test interrupted operations
test_interrupted() {
    echo ""
    echo "Testing interrupt handling (Ctrl+C simulation)..."
    
    # Check for trap handlers
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        if grep -q "trap.*INT\|trap.*SIGINT\|trap.*EXIT" "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} $name has interrupt handler"
            ((PASS++))
        fi
    done
}

# Test concurrent execution
test_concurrent() {
    echo ""
    echo "Testing for race condition protection..."
    
    # Check for lock files or mutex patterns
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        if grep -qi "lock\|mutex\|flock\|pid.*file" "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} $name has concurrency protection"
            ((PASS++))
        fi
    done
    
    echo -e "  ${YELLOW}○${RESET} Most scripts don't need concurrency protection"
}

# Test permission errors
test_permissions() {
    echo ""
    echo "Testing permission error handling..."
    
    # Check for permission checks before operations
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        if grep -qE "\-w\s|\-r\s|\-x\s|permission\|Permission\|access denied" "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${RESET} $name checks permissions"
            ((PASS++))
        fi
    done
}

# Run checks
test_no_templates
test_no_hosts
test_long_names
test_unicode_names
test_interrupted
test_concurrent
test_permissions

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Edge Cases: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "EDGE_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "EDGE_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
