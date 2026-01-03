#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
#  VERSION CONSISTENCY TEST SUITE
#  Verifies all scripts reference VERSION file correctly
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

WORKSPACE_DIR="/workspace"
BIN_DIR="$WORKSPACE_DIR/bin"
LIB_DIR="$WORKSPACE_DIR/lib"
VERSION_FILE="$WORKSPACE_DIR/VERSION"

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  VERSION CONSISTENCY TEST SUITE"
echo "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════════════════════════"

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 1: VERSION FILE FORMAT
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 1: VERSION FILE FORMAT"

# Test 1: VERSION file exists
if [[ -f "$VERSION_FILE" ]]; then
    pass "VERSION file: Exists"
else
    fail "VERSION file: Missing"
    exit 1
fi

# Test 2: VERSION format valid (MAJOR.MINOR.PATCH or MAJOR.MINOR.PATCH-dev.NN)
version=$(cat "$VERSION_FILE")
if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-dev\.[0-9]+)?$ ]]; then
    pass "VERSION format: Valid ($version)"
else
    fail "VERSION format: Invalid ($version)"
fi

# Test 3: VERSION is not empty
if [[ -n "$version" ]]; then
    pass "VERSION content: Not empty"
else
    fail "VERSION content: Empty"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 2: LIB/VERSION.SH INTEGRITY
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 2: LIB/VERSION.SH INTEGRITY"

# Test 4: version.sh exists
if [[ -f "$LIB_DIR/version.sh" ]]; then
    pass "lib/version.sh: Exists"
else
    fail "lib/version.sh: Missing"
fi

# Test 5: version.sh has get_version function
if grep -q "get_version()" "$LIB_DIR/version.sh" 2>/dev/null; then
    pass "get_version function: Defined"
else
    fail "get_version function: Missing"
fi

# Test 6: version.sh reads from VERSION file
if grep -q "VERSION" "$LIB_DIR/version.sh" 2>/dev/null; then
    pass "version.sh: References VERSION file"
else
    fail "version.sh: Does not reference VERSION file"
fi

# Test 7: version.sh syntax valid
if bash -n "$LIB_DIR/version.sh" 2>/dev/null; then
    pass "version.sh syntax: Valid"
else
    fail "version.sh syntax: Invalid"
fi

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 3: SCRIPT VERSION REFERENCES
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 3: SCRIPT VERSION REFERENCES"

# All main scripts
declare -a main_scripts=(
    "homelab"
    "generate-motd"
    "deploy-motd"
    "undeploy-motd"
    "list-templates"
    "delete-template"
    "edit-hosts"
    "edit-config"
    "copykey"
    "cleanup-keys"
    "cleanup-homelab"
    "bulk-generate-motd"
)

# Check each script references VERSION file (comment or source)
for script in "${main_scripts[@]}"; do
    script_path="$BIN_DIR/$script"
    if [[ -f "$script_path" ]]; then
        # Check for "VERSION file" comment OR sources version.sh
        if grep -q "VERSION file\|version\.sh" "$script_path" 2>/dev/null; then
            pass "$script: References VERSION correctly"
        else
            # Also check if it sources lib/version.sh indirectly
            if grep -q 'source.*lib' "$script_path" 2>/dev/null; then
                pass "$script: Sources lib (indirect VERSION access)"
            else
                fail "$script: No VERSION reference found"
            fi
        fi
    else
        fail "$script: Script not found"
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 4: NO HARDCODED VERSIONS
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 4: NO HARDCODED VERSIONS"

# Pattern for hardcoded versions (e.g., VERSION="3.6.0")
hardcode_pattern='VERSION\s*=\s*["'"'"'][0-9]+\.[0-9]+\.[0-9]+'

for script in "${main_scripts[@]}"; do
    script_path="$BIN_DIR/$script"
    if [[ -f "$script_path" ]]; then
        if grep -qE "$hardcode_pattern" "$script_path" 2>/dev/null; then
            fail "$script: Contains hardcoded version"
        else
            pass "$script: No hardcoded version"
        fi
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# SECTION 5: VERSION DISPLAYED CORRECTLY
#═══════════════════════════════════════════════════════════════════════════════

header "SECTION 5: VERSION DISPLAYED CORRECTLY"

# Test homelab --version or --help shows correct version
expected_version=$(cat "$VERSION_FILE")

# Test homelab help output
help_output=$("$BIN_DIR/homelab" --help 2>&1 || true)
if echo "$help_output" | grep -q "$expected_version"; then
    pass "homelab --help: Shows correct version ($expected_version)"
else
    # Check if version is shown at all
    if echo "$help_output" | grep -qE "[0-9]+\.[0-9]+\.[0-9]+"; then
        shown_version=$(echo "$help_output" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+(-dev\.[0-9]+)?" | head -1)
        if [[ "$shown_version" == "$expected_version" ]]; then
            pass "homelab --help: Shows correct version ($shown_version)"
        else
            fail "homelab --help: Version mismatch (expected $expected_version, got $shown_version)"
        fi
    else
        fail "homelab --help: No version found in output"
    fi
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
    echo -e "  ${GREEN}✓ All version consistency tests passed!${RESET}"
    exit 0
else
    echo -e "  ${RED}✗ $FAIL_COUNT test(s) failed${RESET}"
    exit 1
fi
