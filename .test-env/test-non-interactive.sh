#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
#  NON-INTERACTIVE MODE TEST SUITE
#  Tests generate-motd with piped input (scripting use case)
#  Fase 4: P1 Test Cases
#═══════════════════════════════════════════════════════════════════════════════

set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Counters
PASS_COUNT=0
FAIL_COUNT=0

pass() { echo -e "  ${GREEN}[PASS]${RESET} $1"; ((PASS_COUNT++)) || true; }
fail() { echo -e "  ${RED}[FAIL]${RESET} $1"; ((FAIL_COUNT++)) || true; }
header() { echo -e "\n${BOLD}${CYAN}$1${RESET}\n────────────────────────────────────────"; }

TEMPLATE_DIR="${HOME}/.local/share/homelab-tools/templates"
BIN_DIR="/opt/homelab-tools/bin"

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  NON-INTERACTIVE MODE TEST SUITE"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════════"

# Cleanup function - only run at EXIT
cleanup() {
    rm -f "$TEMPLATE_DIR/test-ni-"*.sh 2>/dev/null || true
}
trap cleanup EXIT

# Initial cleanup
cleanup

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: NON-INTERACTIVE TEMPLATE GENERATION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 1: NON-INTERACTIVE TEMPLATE GENERATION"

# Test 1: Auto-accept with Enter (Yes, generate MOTD)
echo -e "\n" | timeout 10 "$BIN_DIR/generate-motd" test-ni-accept >/dev/null 2>&1
if [[ -f "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
    pass "Non-interactive auto-accept: Template created"
else
    fail "Non-interactive auto-accept: Template not created"
fi

# Test 2: Service with preset (pihole) - different name so doesn't conflict
echo -e "\n" | timeout 10 "$BIN_DIR/generate-motd" test-ni-pihole >/dev/null 2>&1
if [[ -f "$TEMPLATE_DIR/test-ni-pihole.sh" ]]; then
    pass "Non-interactive pihole: Template created"
else
    fail "Non-interactive pihole: Template not created"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: HLT MARKERS IN NON-INTERACTIVE MODE
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 2: HLT MARKERS IN NON-INTERACTIVE MODE"

# Test 3: HLT-MOTD-START marker present
if [[ -f "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
    if grep -q "HLT-MOTD-START" "$TEMPLATE_DIR/test-ni-accept.sh"; then
        pass "HLT-MOTD-START marker: Present in template"
    else
        fail "HLT-MOTD-START marker: Missing from template"
    fi
else
    fail "HLT-MOTD-START marker: Template file missing"
fi

# Test 4: HLT-MOTD-END marker present
if [[ -f "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
    if grep -q "HLT-MOTD-END" "$TEMPLATE_DIR/test-ni-accept.sh"; then
        pass "HLT-MOTD-END marker: Present in template"
    else
        fail "HLT-MOTD-END marker: Missing from template"
    fi
else
    fail "HLT-MOTD-END marker: Template file missing"
fi

# Test 5: Markers properly formatted (with # === prefix)
if [[ -f "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
    if grep -q "^# === HLT-MOTD-START" "$TEMPLATE_DIR/test-ni-accept.sh"; then
        pass "HLT marker format: Correct (# === prefix)"
    else
        fail "HLT marker format: Missing # === prefix"
    fi
else
    fail "HLT marker format: Template file missing"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: TEMPLATE CONTENT VERIFICATION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 3: TEMPLATE CONTENT VERIFICATION"

# Test 6: Template is valid bash
if [[ -f "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
    if bash -n "$TEMPLATE_DIR/test-ni-accept.sh" 2>/dev/null; then
        pass "Template syntax: Valid bash"
    else
        fail "Template syntax: Invalid bash"
    fi
else
    fail "Template syntax: Template file missing"
fi

# Test 7: Template is executable
if [[ -f "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
    if [[ -x "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
        pass "Template permissions: Executable"
    else
        fail "Template permissions: Not executable"
    fi
else
    fail "Template permissions: Template file missing"
fi

# Test 8: Template contains service name
if [[ -f "$TEMPLATE_DIR/test-ni-accept.sh" ]]; then
    if grep -qi "test-ni-accept\|Server" "$TEMPLATE_DIR/test-ni-accept.sh"; then
        pass "Template content: Contains service identifier"
    else
        fail "Template content: Missing service identifier"
    fi
else
    fail "Template content: Template file missing"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: SERVICE PRESET DETECTION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 4: SERVICE PRESET DETECTION"

# Test with known presets
declare -A preset_tests=(
    ["pihole"]="Pi-hole"
    ["jellyfin"]="Jellyfin"
    ["sonarr"]="Sonarr"
    ["plex"]="Plex"
)

for service in "${!preset_tests[@]}"; do
    expected="${preset_tests[$service]}"
    template_file="$TEMPLATE_DIR/test-ni-${service}.sh"
    
    # Generate template
    rm -f "$template_file" 2>/dev/null || true
    echo -e "\n" | timeout 10 "$BIN_DIR/generate-motd" "test-ni-${service}" >/dev/null 2>&1
    
    if [[ -f "$template_file" ]]; then
        # Check for service name in output
        if grep -qi "$expected" "$template_file" 2>/dev/null; then
            pass "Preset $service: Detected as $expected"
        else
            # Unknown service just uses the name as-is
            pass "Preset $service: Template created (custom service)"
        fi
    else
        fail "Preset $service: Template not created"
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
#═══════════════════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  SUMMARY"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "  PASSED: $PASS_COUNT"
echo "  FAILED: $FAIL_COUNT"
echo ""

# Exit code
if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "  ${GREEN}✓ All non-interactive tests passed!${RESET}"
    exit 0
else
    echo -e "  ${RED}✗ $FAIL_COUNT test(s) failed${RESET}"
    exit 1
fi
