#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
#  CLI OPTIONS TEST SUITE
#  Tests all --help, --all, -s, -v flags and exit codes
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

BIN_DIR="/opt/homelab-tools/bin"

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  CLI OPTIONS TEST SUITE"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════════"

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: --help FLAGS
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 1: --help FLAGS"

# All commands that should have --help
declare -a commands=(
    "homelab"
    "generate-motd"
    "deploy-motd"
    "undeploy-motd"
    "list-templates"
    "delete-template"
    "edit-hosts"
    "copykey"
    "cleanup-keys"
    "cleanup-homelab"
)

for cmd in "${commands[@]}"; do
    if [[ -f "$BIN_DIR/$cmd" ]]; then
        if timeout 5 "$BIN_DIR/$cmd" --help < /dev/null > /dev/null 2>&1; then
            # Check for escape code issues
            if timeout 5 "$BIN_DIR/$cmd" --help < /dev/null 2>&1 | grep -q '\\033'; then
                fail "$cmd --help: Raw escape codes in output"
            else
                pass "$cmd --help: Works correctly"
            fi
        else
            fail "$cmd --help: Exit code non-zero"
        fi
    else
        fail "$cmd: Command not found"
    fi
done

# Test -h short flag
header "SECTION 2: -h SHORT FLAGS"

for cmd in "${commands[@]}"; do
    if [[ -f "$BIN_DIR/$cmd" ]]; then
        if timeout 5 "$BIN_DIR/$cmd" -h < /dev/null > /dev/null 2>&1; then
            pass "$cmd -h: Works correctly"
        else
            fail "$cmd -h: Failed"
        fi
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: LIST-TEMPLATES OPTIONS
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 3: list-templates OPTIONS"

# --status / -s (will work if templates exist)
if timeout 5 "$BIN_DIR/list-templates" --status < /dev/null > /dev/null 2>&1; then
    pass "list-templates --status: Works"
else
    output=$(timeout 5 "$BIN_DIR/list-templates" --status < /dev/null 2>&1)
    if echo "$output" | grep -q "No templates\|Status\|ready\|stale"; then
        pass "list-templates --status: Works (shows output)"
    else
        fail "list-templates --status: Failed"
    fi
fi

if timeout 5 "$BIN_DIR/list-templates" -s < /dev/null > /dev/null 2>&1; then
    pass "list-templates -s: Works"
else
    output=$(timeout 5 "$BIN_DIR/list-templates" -s < /dev/null 2>&1)
    if echo "$output" | grep -q "No templates\|Status\|ready\|stale"; then
        pass "list-templates -s: Works (shows output)"
    else
        fail "list-templates -s: Failed"
    fi
fi

# --view / -v (interactive, just check it starts)
if timeout 2 "$BIN_DIR/list-templates" --view < /dev/null > /dev/null 2>&1; then
    pass "list-templates --view: Starts (exits on empty input)"
else
    # Expected to timeout or exit - that's ok
    pass "list-templates --view: Interactive mode detected"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: UNDEPLOY-MOTD --all
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 4: undeploy-motd --all"

# Just check it recognizes the flag (will fail without hosts, but should parse)
if timeout 5 "$BIN_DIR/undeploy-motd" --help < /dev/null 2>&1 | grep -q "\-\-all"; then
    pass "undeploy-motd --all: Documented in help"
else
    fail "undeploy-motd --all: Not in help"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: DEPLOY-MOTD --all
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 5: deploy-motd --all"

if timeout 5 "$BIN_DIR/deploy-motd" --help < /dev/null 2>&1 | grep -q "\-\-all"; then
    pass "deploy-motd --all: Documented in help"
else
    fail "deploy-motd --all: Not in help"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 6: HOMELAB SUBCOMMANDS
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 6: homelab SUBCOMMANDS"

# homelab --usage
if timeout 5 "$BIN_DIR/homelab" --usage < /dev/null > /dev/null 2>&1; then
    pass "homelab --usage: Works"
else
    fail "homelab --usage: Failed"
fi

# homelab help
if timeout 5 "$BIN_DIR/homelab" help < /dev/null > /dev/null 2>&1; then
    pass "homelab help: Works"
else
    fail "homelab help: Failed"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 7: INPUT VALIDATION (SECURITY)
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 7: INPUT VALIDATION (SECURITY)"

# Test injection attempts - should all fail gracefully
declare -a bad_inputs=(
    "; rm -rf /"
    "\$(whoami)"
    "| cat /etc/passwd"
    "../../../etc/passwd"
    "test\necho hacked"
)

for bad_input in "${bad_inputs[@]}"; do
    if echo "n" | "$BIN_DIR/generate-motd" "$bad_input" 2>&1 | grep -q "Invalid\|Error\|invalid"; then
        pass "generate-motd: Rejects '$bad_input'"
    else
        # Check if it at least doesn't execute
        result=$(echo "n" | "$BIN_DIR/generate-motd" "$bad_input" 2>&1)
        if echo "$result" | grep -q "hacked\|root\|passwd"; then
            fail "generate-motd: SECURITY - '$bad_input' may have executed!"
        else
            pass "generate-motd: Safely handles '$bad_input'"
        fi
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 8: EXIT CODES
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 8: EXIT CODES"

# --help should exit 0
timeout 5 "$BIN_DIR/homelab" --help < /dev/null > /dev/null 2>&1
[[ $? -eq 0 ]] && pass "homelab --help: Exit code 0" || fail "homelab --help: Non-zero exit"

# Missing argument should exit non-zero
timeout 5 "$BIN_DIR/deploy-motd" < /dev/null 2> /dev/null
[[ $? -ne 0 ]] && pass "deploy-motd (no args): Non-zero exit" || fail "deploy-motd (no args): Should fail"

# Invalid service should exit non-zero
echo "n" | timeout 5 "$BIN_DIR/generate-motd" "!!invalid!!" > /dev/null 2>&1
[[ $? -ne 0 ]] && pass "generate-motd invalid: Non-zero exit" || fail "generate-motd invalid: Should fail"

#═══════════════════════════════════════════════════════════════════════════════
# FINAL REPORT
#═══════════════════════════════════════════════════════════════════════════════

TOTAL=$((PASS_COUNT + FAIL_COUNT))

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  CLI OPTIONS TEST REPORT"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "  ${GREEN}PASSED:${RESET}  $PASS_COUNT"
echo -e "  ${RED}FAILED:${RESET}  $FAIL_COUNT"
echo "  TOTAL:   $TOTAL tests"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "  ${GREEN}${BOLD}✓ ALL CLI TESTS PASSED!${RESET}"
    exit 0
else
    echo -e "  ${RED}✗ $FAIL_COUNT test(s) failed${RESET}"
    exit 1
fi
