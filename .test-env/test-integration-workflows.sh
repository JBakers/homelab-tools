#!/bin/bash
# Integration Workflow Tests
# Tests complete end-to-end workflows
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

PASS=0
FAIL=0

pass() {
    echo -e "  ${GREEN}[PASS]${RESET} $1"
    ((PASS++)) || true
}

fail() {
    echo -e "  ${RED}[FAIL]${RESET} $1"
    ((FAIL++)) || true
}

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}  Integration Workflow Tests${RESET}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo ""

# Setup
TEMPLATE_DIR="$HOME/.local/share/homelab-tools/templates"
mkdir -p "$TEMPLATE_DIR"

# Cleanup old test templates
rm -f "$TEMPLATE_DIR"/workflow-test*.sh 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 1: Full Generate → List → Delete cycle
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}Workflow 1: Generate → List → Delete${RESET}"

# Step 1: Generate
echo "  Step 1: Generating template..."
if echo -e "\n\n\n" | timeout 30 /opt/homelab-tools/bin/generate-motd workflow-test1 > /tmp/wf1-gen.log 2>&1; then
    if [[ -f "$TEMPLATE_DIR/workflow-test1.sh" ]]; then
        pass "Template generated"
    else
        fail "Template file not created"
    fi
else
    fail "Generate command failed"
fi

# Step 2: List  
echo "  Step 2: Listing templates..."
sleep 1  # Give filesystem time to sync
list_out=$(/opt/homelab-tools/bin/list-templates 2>&1 < /dev/null || true)
if echo "$list_out" | grep -q "workflow-test1"; then
    pass "Template appears in list"
else
    echo "  DEBUG: list output: $(echo "$list_out" | grep -c template) templates"
    fail "Template not in list"
fi

# Step 3: Delete
echo "  Step 3: Deleting template..."
if echo "y" | timeout 10 /opt/homelab-tools/bin/delete-template workflow-test1 > /tmp/wf1-del.log 2>&1; then
    if [[ ! -f "$TEMPLATE_DIR/workflow-test1.sh" ]]; then
        pass "Template deleted"
    else
        fail "Template still exists after delete"
    fi
else
    fail "Delete command failed"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 2: Multiple templates at once
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}Workflow 2: Multiple Templates${RESET}"

# Generate 3 templates
templates=("wf-multi1" "wf-multi2" "wf-multi3")
generated=0

echo "  Generating ${#templates[@]} templates..."
for tmpl in "${templates[@]}"; do
    if echo -e "\n\n\n" | timeout 30 /opt/homelab-tools/bin/generate-motd "$tmpl" > /tmp/wf2-$tmpl.log 2>&1; then
        if [[ -f "$TEMPLATE_DIR/$tmpl.sh" ]]; then
            ((generated++)) || true
        fi
    fi
done

if [[ $generated -eq ${#templates[@]} ]]; then
    pass "All $generated templates generated"
else
    fail "Only $generated/${#templates[@]} templates generated"
fi

# Verify all in list
echo "  Verifying all in list..."
sleep 1  # Give filesystem time to sync
list_output=$(/opt/homelab-tools/bin/list-templates 2>&1 < /dev/null || true)
all_found=true
for tmpl in "${templates[@]}"; do
    if ! echo "$list_output" | grep -q "$tmpl"; then
        all_found=false
        break
    fi
done

if [[ "$all_found" == "true" ]]; then
    pass "All templates in list"
else
    fail "Some templates missing from list"
fi

# Cleanup
for tmpl in "${templates[@]}"; do
    rm -f "$TEMPLATE_DIR/$tmpl.sh" 2>/dev/null || true
done
pass "Cleanup completed"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 3: Template regeneration (overwrite)
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}Workflow 3: Template Regeneration${RESET}"

# Generate initial template
echo "  Step 1: Initial generation..."
echo -e "\n\n\n" | timeout 30 /opt/homelab-tools/bin/generate-motd wf-regen > /tmp/wf3-1.log 2>&1

if [[ -f "$TEMPLATE_DIR/wf-regen.sh" ]]; then
    initial_size=$(wc -c < "$TEMPLATE_DIR/wf-regen.sh")
    pass "Initial template created ($initial_size bytes)"
    
    # Regenerate (should overwrite)
    echo "  Step 2: Regenerating..."
    echo -e "\n\n\n" | timeout 30 /opt/homelab-tools/bin/generate-motd wf-regen > /tmp/wf3-2.log 2>&1
    
    if [[ -f "$TEMPLATE_DIR/wf-regen.sh" ]]; then
        new_size=$(wc -c < "$TEMPLATE_DIR/wf-regen.sh")
        pass "Template regenerated ($new_size bytes)"
        
        # Should still have HLT markers
        if grep -q "HLT-MOTD-START" "$TEMPLATE_DIR/wf-regen.sh"; then
            pass "HLT markers preserved after regeneration"
        else
            fail "HLT markers missing after regeneration"
        fi
    else
        fail "Template missing after regeneration"
    fi
else
    fail "Initial template not created"
fi

# Cleanup
rm -f "$TEMPLATE_DIR/wf-regen.sh" 2>/dev/null || true
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# WORKFLOW 4: Deploy to mock server (if available)
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}Workflow 4: Deploy to Mock Server${RESET}"

# Check if pihole is reachable
if ssh -o ConnectTimeout=2 -o BatchMode=yes pihole echo "connected" > /dev/null 2>&1; then
    echo "  Mock server available, testing deploy..."
    
    # Generate template for pihole
    echo -e "\n\n\n" | timeout 30 /opt/homelab-tools/bin/generate-motd pihole > /tmp/wf4-gen.log 2>&1
    
    if [[ -f "$TEMPLATE_DIR/pihole.sh" ]]; then
        pass "Template for pihole generated"
        
        # Deploy
        if echo "1" | timeout 60 /opt/homelab-tools/bin/deploy-motd pihole > /tmp/wf4-deploy.log 2>&1; then
            pass "Deploy command completed"
            
            # Verify on remote
            if ssh pihole "[[ -f /etc/profile.d/00-motd.sh ]]" 2>/dev/null; then
                pass "MOTD file exists on remote"
                
                # Check for HLT markers on remote
                if ssh pihole "grep -q 'HLT-MOTD-START' /etc/profile.d/00-motd.sh" 2>/dev/null; then
                    pass "HLT markers present on remote"
                else
                    fail "HLT markers missing on remote"
                fi
            else
                fail "MOTD file not found on remote"
            fi
        else
            fail "Deploy command failed"
        fi
    else
        fail "Template generation failed"
    fi
else
    echo -e "  ${YELLOW}○${RESET} Mock server not available - skipping"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}  Test Summary${RESET}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${GREEN}PASSED:${RESET} $PASS"
echo -e "  ${RED}FAILED:${RESET} $FAIL"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓✓✓ ALL INTEGRATION WORKFLOW TESTS PASSED! 🎉${RESET}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${RESET}"
    exit 1
fi
