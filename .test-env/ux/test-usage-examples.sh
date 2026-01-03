#!/bin/bash
# UX Test: Usage Examples
# Verifies commands have clear usage examples in help
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Usage Examples in Help${RESET}"
echo ""

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
)

echo "Checking for usage examples in --help..."
echo ""

for cmd in "${COMMANDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "  ${YELLOW}○${RESET} $cmd not installed"
        continue
    fi
    
    output=$($cmd --help 2>&1 || true)
    
    # Check for EXAMPLE section
    if echo "$output" | grep -qi "example"; then
        # Check for actual command example
        if echo "$output" | grep -qE "^\s+$cmd |  $cmd "; then
            echo -e "  ${GREEN}✓${RESET} $cmd has usage examples"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} $cmd has EXAMPLE section but no command examples"
        fi
    else
        echo -e "  ${RED}✗${RESET} $cmd missing EXAMPLE section"
        ((FAIL++))
    fi
done

echo ""
echo "Checking example quality..."
echo ""

for cmd in "${COMMANDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        continue
    fi
    
    output=$($cmd --help 2>&1 || true)
    
    # Count examples
    example_count=$(echo "$output" | grep -cE "^\s+$cmd|^  $cmd|Example:" 2>/dev/null || echo 0)
    
    if [[ $example_count -ge 2 ]]; then
        echo -e "  ${GREEN}✓${RESET} $cmd has multiple examples ($example_count)"
        ((PASS++))
    elif [[ $example_count -eq 1 ]]; then
        echo -e "  ${YELLOW}○${RESET} $cmd has 1 example (could use more)"
    else
        echo -e "  ${RED}✗${RESET} $cmd has no command examples"
        ((FAIL++))
    fi
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Usage Examples: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "USAGE_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "USAGE_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
