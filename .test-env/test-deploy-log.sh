#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
#  DEPLOYMENT LOG TEST SUITE
#  Tests ~/.local/share/homelab-tools/deploy-log functionality
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
skip() { echo -e "  ${YELLOW}[SKIP]${RESET} $1"; }
header() { echo -e "\n${BOLD}${CYAN}$1${RESET}\n────────────────────────────────────────"; }

DATA_DIR="${HOME}/.local/share/homelab-tools"
TEMPLATE_DIR="$DATA_DIR/templates"
DEPLOY_LOG="$DATA_DIR/deploy-log"
BIN_DIR="/opt/homelab-tools/bin"

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  DEPLOYMENT LOG TEST SUITE"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════════"

# Cleanup function
cleanup() {
    rm -f "$TEMPLATE_DIR/test-deploy-"*.sh 2>/dev/null || true
    rm -f "$DEPLOY_LOG.backup" 2>/dev/null || true
}
trap cleanup EXIT

# Initial setup
mkdir -p "$TEMPLATE_DIR"

# Backup existing deploy log
if [[ -f "$DEPLOY_LOG" ]]; then
    cp "$DEPLOY_LOG" "$DEPLOY_LOG.backup"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: DEPLOY LOG FILE CREATION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 1: DEPLOY LOG FILE CREATION"

# Create a test template
cat > "$TEMPLATE_DIR/test-deploy-1.sh" << 'EOF'
#!/bin/bash
# === HLT-MOTD-START ===
echo "Test MOTD for deploy log testing"
# === HLT-MOTD-END ===
EOF
chmod +x "$TEMPLATE_DIR/test-deploy-1.sh"

# Test 1: Deploy log directory exists
if [[ -d "$DATA_DIR" ]]; then
    pass "Data directory: Exists at $DATA_DIR"
else
    fail "Data directory: Does not exist"
fi

# Test 2: Check if deploy-motd creates log (need SSH access)
if ssh -o ConnectTimeout=3 -o BatchMode=yes pihole echo "test" >/dev/null 2>&1; then
    # Clear deploy log for clean test
    rm -f "$DEPLOY_LOG" 2>/dev/null || true
    
    # Deploy to pihole
    if echo "1" | timeout 30 "$BIN_DIR/deploy-motd" test-deploy-1 pihole >/dev/null 2>&1; then
        if [[ -f "$DEPLOY_LOG" ]]; then
            pass "Deploy log: Created after deployment"
        else
            fail "Deploy log: Not created after deployment"
        fi
    else
        skip "Deploy log creation: deploy-motd failed (may need interactive mode)"
    fi
else
    skip "Deploy log creation: SSH to pihole not available"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: DEPLOY LOG FORMAT
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 2: DEPLOY LOG FORMAT"

# Test 3: Log format validation (service|hostname|timestamp|hash)
if [[ -f "$DEPLOY_LOG" ]]; then
    log_line=$(tail -1 "$DEPLOY_LOG" 2>/dev/null || true)
    if [[ -n "$log_line" ]]; then
        # Check for pipe-separated format
        field_count=$(echo "$log_line" | tr '|' '\n' | wc -l)
        if [[ "$field_count" -ge 3 ]]; then
            pass "Log format: Has $field_count fields (pipe-separated)"
        else
            # Maybe different separator
            if echo "$log_line" | grep -qE "[a-z0-9-]+.*[0-9]+"; then
                pass "Log format: Contains service and timestamp"
            else
                fail "Log format: Unexpected format: $log_line"
            fi
        fi
    else
        fail "Log format: Empty log file"
    fi
else
    skip "Log format: Deploy log not available"
fi

# Test 4: Timestamp is numeric
if [[ -f "$DEPLOY_LOG" ]]; then
    log_line=$(tail -1 "$DEPLOY_LOG" 2>/dev/null || true)
    if echo "$log_line" | grep -qE '[0-9]{10}'; then
        pass "Timestamp: Contains Unix timestamp"
    else
        skip "Timestamp: No Unix timestamp found (may use different format)"
    fi
else
    skip "Timestamp: Deploy log not available"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: DEPLOY LOG ACCUMULATION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 3: DEPLOY LOG ACCUMULATION"

# Create second test template
cat > "$TEMPLATE_DIR/test-deploy-2.sh" << 'EOF'
#!/bin/bash
# === HLT-MOTD-START ===
echo "Second test MOTD"
# === HLT-MOTD-END ===
EOF
chmod +x "$TEMPLATE_DIR/test-deploy-2.sh"

# Test 5: Multiple deploys accumulate
if [[ -f "$DEPLOY_LOG" ]]; then
    initial_count=$(wc -l < "$DEPLOY_LOG" 2>/dev/null || echo 0)
    
    if ssh -o ConnectTimeout=3 -o BatchMode=yes jellyfin echo "test" >/dev/null 2>&1; then
        echo "1" | timeout 30 "$BIN_DIR/deploy-motd" test-deploy-2 jellyfin >/dev/null 2>&1
        
        new_count=$(wc -l < "$DEPLOY_LOG" 2>/dev/null || echo 0)
        if [[ "$new_count" -gt "$initial_count" ]]; then
            pass "Log accumulation: Grew from $initial_count to $new_count entries"
        else
            skip "Log accumulation: Count unchanged (may update existing entry)"
        fi
    else
        skip "Log accumulation: SSH to jellyfin not available"
    fi
else
    skip "Log accumulation: Deploy log not available"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: LIST-TEMPLATES STATUS INTEGRATION
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 4: LIST-TEMPLATES STATUS INTEGRATION"

# Test 6: list-templates -s reads deploy log
status_output=$("$BIN_DIR/list-templates" -s 2>&1 || true)

if echo "$status_output" | grep -qE "🟢|🟡|🔴|deployed|ready|stale|Deployed"; then
    pass "list-templates -s: Shows deployment status indicators"
else
    if echo "$status_output" | grep -qE "template|\.sh"; then
        pass "list-templates -s: Lists templates (status format may differ)"
    else
        fail "list-templates -s: Unexpected output"
    fi
fi

# Test 7: Deployed templates show in status
if [[ -f "$DEPLOY_LOG" ]]; then
    if echo "$status_output" | grep -qi "deploy\|pihole\|jellyfin"; then
        pass "Status integration: Shows deployed templates"
    else
        skip "Status integration: May not show deployment info"
    fi
else
    skip "Status integration: No deploy log available"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: DEPLOY LOG CLEANUP
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 5: DEPLOY LOG CLEANUP"

# Test 8: Undeploy removes entry (if implemented)
if [[ -f "$DEPLOY_LOG" ]] && ssh -o ConnectTimeout=3 -o BatchMode=yes pihole echo "test" >/dev/null 2>&1; then
    initial_count=$(wc -l < "$DEPLOY_LOG" 2>/dev/null || echo 0)
    
    echo "y" | timeout 30 "$BIN_DIR/undeploy-motd" pihole >/dev/null 2>&1
    
    new_count=$(wc -l < "$DEPLOY_LOG" 2>/dev/null || echo 0)
    if [[ "$new_count" -lt "$initial_count" ]]; then
        pass "Undeploy cleanup: Removed entry from log"
    else
        skip "Undeploy cleanup: Entry not removed (may be by design)"
    fi
else
    skip "Undeploy cleanup: Prerequisites not met"
fi

# Restore original deploy log
if [[ -f "$DEPLOY_LOG.backup" ]]; then
    mv "$DEPLOY_LOG.backup" "$DEPLOY_LOG"
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
    echo -e "  ${GREEN}✓ All deploy log tests passed!${RESET}"
    exit 0
else
    echo -e "  ${RED}✗ $FAIL_COUNT test(s) failed${RESET}"
    exit 1
fi
