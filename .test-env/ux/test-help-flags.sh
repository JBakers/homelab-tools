#!/bin/bash
# UX Test: Help Flags
# Verifies all commands have --help and -h flags
# Note: Uses set +e because help commands may return non-zero

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Help Flags (--help and -h)${RESET}"
echo ""

# All commands that should have help
COMMANDS=(
    "homelab"
    "generate-motd"
    "deploy-motd"
    "undeploy-motd"
    "bulk-generate-motd"
    "list-templates"
    "delete-template"
    "edit-hosts"
    "edit-config"
    "cleanup-keys"
    "copykey"
    "cleanup-homelab"
)

echo "Testing --help flag..."
for cmd in "${COMMANDS[@]}"; do
    # Try command in PATH first, then /opt path
    if command -v "$cmd" &>/dev/null; then
        cmd_path="$cmd"
    elif [[ -x "/opt/homelab-tools/bin/$cmd" ]]; then
        cmd_path="/opt/homelab-tools/bin/$cmd"
    else
        echo -e "  ${YELLOW}○${RESET} $cmd not installed"
        continue
    fi
    
    output=$($cmd_path --help 2>&1 || true)
        
        if [[ -n "$output" ]] && [[ "$output" != *"error"* ]] && [[ "$output" != *"Error"* ]]; then
            # Check for expected help content
            if echo "$output" | grep -qi "usage\|description\|example\|options"; then
                echo -e "  ${GREEN}✓${RESET} $cmd --help works"
                ((PASS++))
            else
                echo -e "  ${YELLOW}⚠${RESET} $cmd --help output may be incomplete"
                ((PASS++))
            fi
        else
            echo -e "  ${RED}✗${RESET} $cmd --help failed or empty"
            ((FAIL++))
        fi
done

echo ""
echo "Testing -h flag..."
for cmd in "${COMMANDS[@]}"; do
    # Try command in PATH first, then /opt path
    if command -v "$cmd" &>/dev/null; then
        cmd_path="$cmd"
    elif [[ -x "/opt/homelab-tools/bin/$cmd" ]]; then
        cmd_path="/opt/homelab-tools/bin/$cmd"
    else
        continue
    fi
    
    output=$($cmd_path -h 2>&1 || true)
    
    if [[ -n "$output" ]] && [[ "$output" != *"error"* ]]; then
        echo -e "  ${GREEN}✓${RESET} $cmd -h works"
        ((PASS++))
    else
        echo -e "  ${RED}✗${RESET} $cmd -h failed"
        ((FAIL++))
    fi
done

echo ""
echo "Checking help content quality..."
for cmd in "${COMMANDS[@]}"; do
    # Try command in PATH first, then /opt path
    if command -v "$cmd" &>/dev/null; then
        cmd_path="$cmd"
    elif [[ -x "/opt/homelab-tools/bin/$cmd" ]]; then
        cmd_path="/opt/homelab-tools/bin/$cmd"
    else
        continue
    fi
    
    output=$($cmd_path --help 2>&1 || true)
    
    # Check for required sections
    sections=0
    
    if echo "$output" | grep -qi "usage"; then
        ((sections++))
    fi
    if echo "$output" | grep -qi "description\|what it does"; then
        ((sections++))
    fi
    if echo "$output" | grep -qi "example"; then
        ((sections++))
    fi
    if echo "$output" | grep -qi "options\|flags"; then
        ((sections++))
    fi
    
    if [[ $sections -ge 3 ]]; then
        echo -e "  ${GREEN}✓${RESET} $cmd has comprehensive help ($sections/4 sections)"
        ((PASS++))
    elif [[ $sections -ge 2 ]]; then
        echo -e "  ${YELLOW}○${RESET} $cmd has basic help ($sections/4 sections)"
    else
        echo -e "  ${RED}✗${RESET} $cmd help is incomplete ($sections/4 sections)"
        ((FAIL++))
    fi
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Help Flags: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "HELP_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "HELP_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
