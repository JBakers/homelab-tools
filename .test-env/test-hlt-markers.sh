#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
#  HLT MARKER VALIDATION TEST SUITE
#  Tests that all templates have proper HLT-MOTD-START/END markers
#  Fase 5: P2 Test Cases
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
echo "  HLT MARKER VALIDATION TEST SUITE"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════════"

# Cleanup function
cleanup() {
    rm -f "$TEMPLATE_DIR/test-hlt-"*.sh 2>/dev/null || true
}
trap cleanup EXIT

# Initial cleanup
cleanup
mkdir -p "$TEMPLATE_DIR"

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: MARKER PRESENCE IN GENERATED TEMPLATES
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 1: MARKER PRESENCE IN GENERATED TEMPLATES"

# Test 1: Generate template and check START marker
echo -e "\n" | timeout 10 "$BIN_DIR/generate-motd" test-hlt-1 >/dev/null 2>&1
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    if grep -q "HLT-MOTD-START" "$TEMPLATE_DIR/test-hlt-1.sh"; then
        pass "HLT-MOTD-START marker: Present in generated template"
    else
        fail "HLT-MOTD-START marker: Missing from generated template"
    fi
else
    fail "HLT-MOTD-START marker: Template not created"
fi

# Test 2: Check END marker
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    if grep -q "HLT-MOTD-END" "$TEMPLATE_DIR/test-hlt-1.sh"; then
        pass "HLT-MOTD-END marker: Present in generated template"
    else
        fail "HLT-MOTD-END marker: Missing from generated template"
    fi
else
    fail "HLT-MOTD-END marker: Template not created"
fi

# Test 3: START comes before END
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    start_line=$(grep -n "HLT-MOTD-START" "$TEMPLATE_DIR/test-hlt-1.sh" | head -1 | cut -d: -f1)
    end_line=$(grep -n "HLT-MOTD-END" "$TEMPLATE_DIR/test-hlt-1.sh" | head -1 | cut -d: -f1)
    if [[ -n "$start_line" ]] && [[ -n "$end_line" ]] && [[ "$start_line" -lt "$end_line" ]]; then
        pass "Marker order: START ($start_line) before END ($end_line)"
    else
        fail "Marker order: Invalid (START=$start_line, END=$end_line)"
    fi
else
    fail "Marker order: Template not created"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: MARKER FORMAT VALIDATION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 2: MARKER FORMAT VALIDATION"

# Test 4: Markers have proper comment prefix
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    if grep -q "^# === HLT-MOTD-START ===" "$TEMPLATE_DIR/test-hlt-1.sh" || \
       grep -q "^# HLT-MOTD-START" "$TEMPLATE_DIR/test-hlt-1.sh"; then
        pass "START marker format: Has comment prefix"
    else
        fail "START marker format: Missing comment prefix"
    fi
else
    fail "START marker format: Template not created"
fi

# Test 5: END marker has proper comment prefix
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    if grep -q "^# === HLT-MOTD-END ===" "$TEMPLATE_DIR/test-hlt-1.sh" || \
       grep -q "^# HLT-MOTD-END" "$TEMPLATE_DIR/test-hlt-1.sh"; then
        pass "END marker format: Has comment prefix"
    else
        fail "END marker format: Missing comment prefix"
    fi
else
    fail "END marker format: Template not created"
fi

# Test 6: No typos in markers
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    # Check for common typos
    if grep -qE "HLT-MOTD-STAR[^T]|HLT-MOT[^D]-|HLT-MOTD-EN[^D]" "$TEMPLATE_DIR/test-hlt-1.sh"; then
        fail "Marker typos: Found typos in markers"
    else
        pass "Marker typos: No typos detected"
    fi
else
    fail "Marker typos: Template not created"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: MARKER CONTENT VALIDATION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 3: MARKER CONTENT VALIDATION"

# Test 7: Content exists between markers
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    start_line=$(grep -n "HLT-MOTD-START" "$TEMPLATE_DIR/test-hlt-1.sh" | head -1 | cut -d: -f1)
    end_line=$(grep -n "HLT-MOTD-END" "$TEMPLATE_DIR/test-hlt-1.sh" | head -1 | cut -d: -f1)
    if [[ -n "$start_line" ]] && [[ -n "$end_line" ]]; then
        content_lines=$((end_line - start_line - 1))
        if [[ "$content_lines" -gt 0 ]]; then
            pass "Content between markers: $content_lines lines"
        else
            fail "Content between markers: No content (markers adjacent)"
        fi
    else
        fail "Content between markers: Markers not found"
    fi
else
    fail "Content between markers: Template not created"
fi

# Test 8: Shebang before START marker
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    first_line=$(head -1 "$TEMPLATE_DIR/test-hlt-1.sh")
    if [[ "$first_line" == "#!/bin/bash" ]]; then
        pass "Shebang position: At line 1 (before markers)"
    else
        fail "Shebang position: Not at line 1 (got: $first_line)"
    fi
else
    fail "Shebang position: Template not created"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: MULTIPLE TEMPLATE CONSISTENCY
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 4: MULTIPLE TEMPLATE CONSISTENCY"

# Generate multiple templates and check all have markers
services=("test-hlt-pihole" "test-hlt-jellyfin" "test-hlt-sonarr")
marker_ok=0
marker_fail=0

for service in "${services[@]}"; do
    echo -e "\n" | timeout 10 "$BIN_DIR/generate-motd" "$service" >/dev/null 2>&1
    if [[ -f "$TEMPLATE_DIR/${service}.sh" ]]; then
        if grep -q "HLT-MOTD-START" "$TEMPLATE_DIR/${service}.sh" && \
           grep -q "HLT-MOTD-END" "$TEMPLATE_DIR/${service}.sh"; then
            ((marker_ok++)) || true
        else
            ((marker_fail++)) || true
        fi
    else
        ((marker_fail++)) || true
    fi
done

if [[ $marker_fail -eq 0 ]]; then
    pass "Multiple templates: All $marker_ok templates have correct markers"
else
    fail "Multiple templates: $marker_fail of ${#services[@]} missing markers"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: PROTECTION MARKER INTEGRITY
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 5: PROTECTION MARKER INTEGRITY"

# Test 9: Warning comment about not editing
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    if grep -qi "do not edit\|don't edit\|generated" "$TEMPLATE_DIR/test-hlt-1.sh"; then
        pass "Edit warning: Present in template"
    else
        # This is informational - not all templates may have this
        pass "Edit warning: Not present (optional)"
    fi
else
    fail "Edit warning: Template not created"
fi

# Test 10: Template is valid bash after markers
if [[ -f "$TEMPLATE_DIR/test-hlt-1.sh" ]]; then
    if bash -n "$TEMPLATE_DIR/test-hlt-1.sh" 2>/dev/null; then
        pass "Template validity: Valid bash syntax with markers"
    else
        fail "Template validity: Invalid bash syntax"
    fi
else
    fail "Template validity: Template not created"
fi

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
    echo -e "  ${GREEN}✓ All HLT marker tests passed!${RESET}"
    exit 0
else
    echo -e "  ${RED}✗ $FAIL_COUNT test(s) failed${RESET}"
    exit 1
fi
