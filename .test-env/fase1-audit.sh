#!/bin/bash
# FASE 1: Testing Audit - Systematic Gap Analysis
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}FASE 1: Testing Audit - Gap Analysis${RESET}"
echo "==========================================="
echo ""

# Function to test gap
test_gap() {
    local gap_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    echo -n "Testing: $gap_name ... "
    
    if eval "$test_command" 2>/dev/null | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✓${RESET}"
        return 0
    else
        echo -e "${RED}✗${RESET}"
        return 1
    fi
}

echo "GAP 1: MOTD Lifecycle Tests"
echo "---"
test_gap "HLT markers in generated template" \
    "printf '\n\n\n' | /opt/homelab-tools/bin/generate-motd pihole 2>/dev/null && grep -q 'HLT-MOTD-START' ~/.local/share/homelab-tools/templates/pihole.sh" \
    "HLT-MOTD-START" || echo "  ❌ HLT markers missing in non-interactive mode"

test_gap "ASCII art rendered in template" \
    "printf '\n\n1\n' | /opt/homelab-tools/bin/generate-motd test 2>/dev/null && grep -q 'toilet\|figlet' ~/.local/share/homelab-tools/templates/test.sh" \
    "toilet\|figlet" || echo "  ❌ ASCII art code not in template"

echo ""
echo "GAP 2: ASCII Art Validation"
echo "---"
for style in 1 2 3 4 5 6; do
    echo -n "  Style $style: "
    if printf "y\n8080\n$style\n" | /opt/homelab-tools/bin/generate-motd style$style >/dev/null 2>&1; then
        if grep -q "toilet" ~/.local/share/homelab-tools/templates/style$style.sh 2>/dev/null; then
            echo -e "${GREEN}✓${RESET}"
        else
            echo -e "${RED}✗${RESET} (no rendering code)"
        fi
    else
        echo -e "${RED}✗${RESET} (generation failed)"
    fi
done

echo ""
echo "GAP 3: HLT Markers in All Modes"
echo "---"
test_gap "Interactive mode has markers" \
    "echo '2' | /opt/homelab-tools/bin/generate-motd jellyfin >/dev/null 2>&1 && grep -c 'HLT-MOTD' ~/.local/share/homelab-tools/templates/jellyfin.sh" \
    "^2$" || echo "  ❌ Markers missing in interactive mode"

echo ""
echo "GAP 4: Service Name Substitution"
echo "---"
for service in pihole jellyfin sonarr; do
    echo -n "  Service '$service': "
    if printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd $service >/dev/null 2>&1; then
        template_name=$(grep "Service:" ~/.local/share/homelab-tools/templates/$service.sh 2>/dev/null | head -1 | cut -d'$' -f1 | tail -c 20)
        if [[ -n "$template_name" ]]; then
            echo -e "${GREEN}✓${RESET} (name substituted)"
        else
            echo -e "${RED}✗${RESET} (generic name)"
        fi
    fi
done

echo ""
echo "GAP 5: Port in Web UI URL"
echo "---"
if printf "y\n8080\n" | /opt/homelab-tools/bin/generate-motd porttest >/dev/null 2>&1; then
    if grep -q ":8080" ~/.local/share/homelab-tools/templates/porttest.sh; then
        echo -e "${GREEN}✓${RESET} Port in URL"
    else
        echo -e "${RED}✗${RESET} Port NOT in URL"
    fi
fi

echo ""
echo "GAP 6: Deployment State Tracking"
echo "---"
test_gap "Deploy creates log entry" \
    "[[ -f ~/.local/share/homelab-tools/deploy-log ]]" \
    "" && echo "  ✓ Log exists" || echo "  ❌ Deploy log not created"

echo ""
echo "GAP 7: Menu Edge Cases"
echo "---"
echo -n "  Empty templates menu: "
rm -f ~/.local/share/homelab-tools/templates/*.sh
if timeout 2 bash -c "echo 'q' | /opt/homelab-tools/bin/list-templates" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${RESET}"
else
    echo -e "${RED}✗${RESET} (hangs or crashes)"
fi

echo ""
echo "==========================================="
echo -e "${CYAN}Audit Complete${RESET}"
echo ""
echo "Summary:"
echo "- Check each gap above for ✓ (working) or ✗ (missing)"
echo "- Document findings in TESTING-TODO.md"
echo "- Ready for Phase 2: Framework Setup"

