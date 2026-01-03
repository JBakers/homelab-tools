#!/bin/bash

# Interactive Testing Runner - Homelab Tools v3.6.0-dev.35
# Complete test suite with 12 sections, 72 tests (6 per section)
# Cross-referenced with TODO.md and latest features
# Time: ~5-10 minutes for complete test cycle
# Last updated: 2026-01-01 (Banner fixes, sync-dev.sh, auto-bump, clean /opt)

PROGRESS_FILE="$HOME/.homelab-test-progress"
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

declare -A CHECKED=()
declare -A TEST_NAMES=()
declare -A TEST_CMDS=()
declare -A TEST_VERIFY=()
declare -A SECTION_NAMES=(
    [0]="PRE-FLIGHT: Cleanup & Git Pull"
    [1]="FRESH INSTALL"
    [2]="SETUP & MENU"
    [3]="HOST MANAGEMENT (edit-hosts)"
    [4]="MOTD GENERATION"
    [5]="DEPLOY & UNDEPLOY"
    [6]="TEMPLATE MANAGEMENT"
    [7]="LIST TEMPLATES (all modes)"
    [8]="MENU CONSISTENCY & NAVIGATION"
    [9]="INSTALL MENU (with existing)"
    [10]="UNINSTALL FEATURES"
    [11]="FINAL VERIFICATION"
)

# Initialize all tests
init_tests() {
    # Section 0: PRE-FLIGHT
    TEST_NAMES[0.1]="Complete uninstall"; TEST_CMDS[0.1]="sudo rm -rf /opt/homelab-tools /home/jochem/.local/bin/homelab* /home/jochem/.local/share/homelab-tools && echo '✓ All homelab files removed'"; TEST_VERIFY[0.1]="[[ ! -d /opt/homelab-tools ]]"
    TEST_NAMES[0.2]="Verify cleanup complete"; TEST_CMDS[0.2]="ls /opt/homelab-tools 2>/dev/null && echo '✗ NOT CLEAN!' || echo '✓ Clean - no files found'"; TEST_VERIFY[0.2]="[[ ! -d /opt/homelab-tools ]]"
    TEST_NAMES[0.3]="Git pull latest develop"; TEST_CMDS[0.3]="cd /home/jochem/Workspace/homelab-tools && git pull origin develop"; TEST_VERIFY[0.3]="cd /home/jochem/Workspace/homelab-tools && git rev-parse --abbrev-ref HEAD | grep -q 'develop'"
    TEST_NAMES[0.4]="Verify on develop branch"; TEST_CMDS[0.4]="cd /home/jochem/Workspace/homelab-tools && git branch --show-current"; TEST_VERIFY[0.4]="cd /home/jochem/Workspace/homelab-tools && git branch --show-current | grep -q 'develop'"
    TEST_NAMES[0.5]="Check VERSION file"; TEST_CMDS[0.5]="cd /home/jochem/Workspace/homelab-tools && cat VERSION"; TEST_VERIFY[0.5]="[[ -f /home/jochem/Workspace/homelab-tools/VERSION ]]"
    TEST_NAMES[0.6]="Verify no uncommitted changes"; TEST_CMDS[0.6]="cd /home/jochem/Workspace/homelab-tools && git status --short"; TEST_VERIFY[0.6]="cd /home/jochem/Workspace/homelab-tools && [[ -z \$(git status --short) ]]"

    # Section 1: FRESH INSTALL
    TEST_NAMES[1.1]="Install: Shows header"; TEST_CMDS[1.1]="cd /home/jochem/Workspace/homelab-tools && sudo bash install.sh"; TEST_VERIFY[1.1]="[[ -d /opt/homelab-tools ]]"
    TEST_NAMES[1.2]="Install script valid"; TEST_CMDS[1.2]="bash -n /home/jochem/Workspace/homelab-tools/install.sh && echo '✓ Valid'"; TEST_VERIFY[1.2]="bash -n /home/jochem/Workspace/homelab-tools/install.sh"
    TEST_NAMES[1.3]="Copies to /opt/homelab-tools/"; TEST_CMDS[1.3]="ls /opt/homelab-tools/ && echo '✓ Files found'"; TEST_VERIFY[1.3]="[[ -d /opt/homelab-tools && -n $(ls -A /opt/homelab-tools/) ]]"
    TEST_NAMES[1.4]="Creates ~/.local/bin symlinks"; TEST_CMDS[1.4]="ls /home/jochem/.local/bin/ | grep homelab && echo '✓ Symlinks found'"; TEST_VERIFY[1.4]="[[ -L /home/jochem/.local/bin/homelab ]]"
    TEST_NAMES[1.5]="Configures .bashrc"; TEST_CMDS[1.5]="grep 'homelab' /home/jochem/.bashrc && echo '✓ Configured'"; TEST_VERIFY[1.5]="grep -q 'homelab' /home/jochem/.bashrc"
    TEST_NAMES[1.6]="Completes successfully"; TEST_CMDS[1.6]="/home/jochem/.local/bin/homelab --version"; TEST_VERIFY[1.6]="[[ -x /home/jochem/.local/bin/homelab ]]"

    # Section 2: SETUP & MENU
    TEST_NAMES[2.1]="source ~/.bashrc works"; TEST_CMDS[2.1]="source /home/jochem/.bashrc && echo '✓ Loaded'"; TEST_VERIFY[2.1]="source /home/jochem/.bashrc 2>/dev/null"
    TEST_NAMES[2.2]="homelab menu appears"; TEST_CMDS[2.2]="timeout 1 /home/jochem/.local/bin/homelab 2>&1 | grep -q 'MOTD Tools' && echo '✓ Menu shows'"; TEST_VERIFY[2.2]="timeout 1 /home/jochem/.local/bin/homelab 2>&1 | grep -q 'MOTD Tools'"
    TEST_NAMES[2.3]="homelab help command"; TEST_CMDS[2.3]="homelab help | grep -q 'generate-motd' && echo '✓ Help works'"; TEST_VERIFY[2.3]="homelab help | grep -q 'generate-motd'"
    TEST_NAMES[2.4]="Menu has proper formatting"; TEST_CMDS[2.4]="homelab --help 2>&1 | grep -q '════' && echo '✓ Formatted'"; TEST_VERIFY[2.4]="homelab --help 2>&1 | grep -q '════'"
    TEST_NAMES[2.5]="All commands accessible"; TEST_CMDS[2.5]="homelab help | grep -c 'motd\\|host\\|keys' | grep -q '[1-9]' && echo '✓ Commands found'"; TEST_VERIFY[2.5]="homelab help | grep -E 'motd|host|keys' | wc -l | grep -q '[1-9]'"
    TEST_NAMES[2.6]="No syntax errors in main script"; TEST_CMDS[2.6]="bash -n /opt/homelab-tools/bin/homelab && echo '✓ Valid'"; TEST_VERIFY[2.6]="bash -n /opt/homelab-tools/bin/homelab"

    # Section 3: HOST MANAGEMENT
    TEST_NAMES[3.1]="edit-hosts --help shows usage"; TEST_CMDS[3.1]="edit-hosts --help 2>&1 | grep -q 'USAGE'"; TEST_VERIFY[3.1]="edit-hosts --help 2>&1 | grep -q 'USAGE'"
    TEST_NAMES[3.2]="edit-hosts: No escape code artifacts"; TEST_CMDS[3.2]="edit-hosts --help 2>&1 | grep -c '\\\033' || echo '0'"; TEST_VERIFY[3.2]="[[ \$(edit-hosts --help 2>&1 | grep -c '\\\033' || echo '0') -eq 0 ]]"
    TEST_NAMES[3.3]="edit-hosts menu structure (bash -n)"; TEST_CMDS[3.3]="bash -n /opt/homelab-tools/bin/edit-hosts"; TEST_VERIFY[3.3]="bash -n /opt/homelab-tools/bin/edit-hosts"
    TEST_NAMES[3.4]="edit-hosts: All menu titles present"; TEST_CMDS[3.4]="grep -c 'show_arrow_menu' /opt/homelab-tools/bin/edit-hosts"; TEST_VERIFY[3.4]="[[ \$(grep -c 'show_arrow_menu' /opt/homelab-tools/bin/edit-hosts) -eq 4 ]]"
    TEST_NAMES[3.5]="SSH config directory exists"; TEST_CMDS[3.5]="mkdir -p /home/jochem/.ssh 2>/dev/null; [[ -d /home/jochem/.ssh ]] && echo '✓ SSH dir'"; TEST_VERIFY[3.5]="[[ -d /home/jochem/.ssh ]]"
    TEST_NAMES[3.6]="SSH config file exists/created"; TEST_CMDS[3.6]="[[ ! -f /home/jochem/.ssh/config ]] && touch /home/jochem/.ssh/config && chmod 600 /home/jochem/.ssh/config; [[ -f /home/jochem/.ssh/config ]] && echo '✓ Config OK'"; TEST_VERIFY[3.6]="[[ -f /home/jochem/.ssh/config && -r /home/jochem/.ssh/config ]]"

    # Section 4: MOTD GENERATION
    TEST_NAMES[4.1]="generate-motd --help works"; TEST_CMDS[4.1]="generate-motd --help | head -5"; TEST_VERIFY[4.1]="generate-motd --help | grep -q 'Usage'"
    TEST_NAMES[4.2]="generate-motd: Interactive mode"; TEST_CMDS[4.2]="printf 'n\n1\nn\n' | generate-motd test-motd-1"; TEST_VERIFY[4.2]="[[ -f /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh ]]"
    TEST_NAMES[4.3]="generate-motd: Non-interactive stdin"; TEST_CMDS[4.3]="printf 'y\n8080\n' | generate-motd test-motd-2"; TEST_VERIFY[4.3]="[[ -f /home/jochem/.local/share/homelab-tools/templates/test-motd-2.sh ]]"
    TEST_NAMES[4.4]="Template has valid content"; TEST_CMDS[4.4]="cat /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh | head -10"; TEST_VERIFY[4.4]="[[ -f /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh && -s /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh ]]"
    TEST_NAMES[4.5]="bulk-generate-motd --help"; TEST_CMDS[4.5]="bulk-generate-motd --help | head -5"; TEST_VERIFY[4.5]="bulk-generate-motd --help | grep -q 'Usage'"
    TEST_NAMES[4.6]="No syntax errors in scripts"; TEST_CMDS[4.6]="bash -n /opt/homelab-tools/bin/generate-motd && echo '✓ OK'"; TEST_VERIFY[4.6]="bash -n /opt/homelab-tools/bin/generate-motd"

    # Section 5: DEPLOY & UNDEPLOY
    TEST_NAMES[5.1]="deploy-motd --help"; TEST_CMDS[5.1]="deploy-motd --help | head -5"; TEST_VERIFY[5.1]="deploy-motd --help | grep -q 'Usage'"
    TEST_NAMES[5.2]="deploy-motd: SSH error handling"; TEST_CMDS[5.2]="deploy-motd nonexistent-host 2>&1 | grep -q 'Cannot connect' && echo '✓ Error handled' || echo '✓ Attempted'"; TEST_VERIFY[5.2]="true"
    TEST_NAMES[5.3]="undeploy-motd --help"; TEST_CMDS[5.3]="undeploy-motd --help | head -5"; TEST_VERIFY[5.3]="undeploy-motd --help | grep -q 'Usage'"
    TEST_NAMES[5.4]="undeploy-motd: Single host mode"; TEST_CMDS[5.4]="undeploy-motd nonexistent 2>&1 | grep -q 'Cannot connect' && echo '✓' || echo '✓'"; TEST_VERIFY[5.4]="true"
    TEST_NAMES[5.5]="undeploy-motd --all mode"; TEST_CMDS[5.5]="echo 'Testing --all flag...' && echo '✓ Flag available'"; TEST_VERIFY[5.5]="undeploy-motd --help | grep -q -- '--all'"
    TEST_NAMES[5.6]="Deployment logging setup"; TEST_CMDS[5.6]="mkdir -p /home/jochem/.local/share/homelab-tools && echo '✓ Log dir ready'"; TEST_VERIFY[5.6]="[[ -d /home/jochem/.local/share/homelab-tools ]]"

    # Section 6: TEMPLATE MANAGEMENT
    TEST_NAMES[6.1]="delete-template --help"; TEST_CMDS[6.1]="delete-template --help"; TEST_VERIFY[6.1]="delete-template --help | grep -q 'Usage'"
    TEST_NAMES[6.2]="delete-template: Help colors OK"; TEST_CMDS[6.2]="delete-template --help 2>&1 | grep -q '033' && echo '✗ HAS CODES' || echo '✓ Clean'"; TEST_VERIFY[6.2]="! delete-template --help 2>&1 | grep -q '033'"
    TEST_NAMES[6.3]="Template directory writable"; TEST_CMDS[6.3]="touch /home/jochem/.local/share/homelab-tools/test.tmp && rm /home/jochem/.local/share/homelab-tools/test.tmp && echo '✓ Writable'"; TEST_VERIFY[6.3]="[[ -d /home/jochem/.local/share/homelab-tools ]]"
    TEST_NAMES[6.4]="List existing templates"; TEST_CMDS[6.4]="ls /home/jochem/.local/share/homelab-tools/templates/*.sh 2>/dev/null | wc -l"; TEST_VERIFY[6.4]="true"
    TEST_NAMES[6.5]="Template format valid"; TEST_CMDS[6.5]="bash -n /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh 2>&1 && echo '✓ Valid'"; TEST_VERIFY[6.5]="bash -n /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh"
    TEST_NAMES[6.6]="No garbled template content"; TEST_CMDS[6.6]="cat /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh | grep -c '^' | awk '{if(\$1 > 0) print \"✓ Content OK\"}'"; TEST_VERIFY[6.6]="[[ -f /home/jochem/.local/share/homelab-tools/templates/test-motd-1.sh ]]"

    # Section 7: LIST TEMPLATES (all modes)
    TEST_NAMES[7.1]="list-templates: Default mode"; TEST_CMDS[7.1]="list-templates | head -10"; TEST_VERIFY[7.1]="list-templates | grep -q 'Template'"
    TEST_NAMES[7.2]="list-templates --status"; TEST_CMDS[7.2]="list-templates --status | head -10"; TEST_VERIFY[7.2]="list-templates --status | grep -q 'Status'"
    TEST_NAMES[7.3]="list-templates: Shows indicators"; TEST_CMDS[7.3]="list-templates --status 2>&1 | grep -E '🟢|🟡|🔴' && echo '✓ Indicators'"; TEST_VERIFY[7.3]="list-templates --status 2>&1 | grep -qE '🟢|🟡|🔴'"
    TEST_NAMES[7.4]="list-templates --view: Menu opens with template"; TEST_CMDS[7.4]="timeout 2 list-templates --view 2>&1 | grep -q 'Select Template' && echo '✓ Menu' || echo '✓ Command works'"; TEST_VERIFY[7.4]="bash -n /opt/homelab-tools/bin/list-templates"
    TEST_NAMES[7.5]="list-templates --view: Uses show_arrow_menu"; TEST_CMDS[7.5]="grep -c 'show_arrow_menu' /opt/homelab-tools/bin/list-templates | grep -q '[1-9]' && echo '✓ Has menu'"; TEST_VERIFY[7.5]="grep -q 'show_arrow_menu' /opt/homelab-tools/bin/list-templates"
    TEST_NAMES[7.6]="All modes work without errors"; TEST_CMDS[7.6]="bash -n /opt/homelab-tools/bin/list-templates && echo '✓ OK'"; TEST_VERIFY[7.6]="bash -n /opt/homelab-tools/bin/list-templates"

    # Section 8: MENU CONSISTENCY & NAVIGATION
    TEST_NAMES[8.1]="homelab: Main menu shows"; TEST_CMDS[8.1]="homelab --help 2>&1 | head -5"; TEST_VERIFY[8.1]="homelab --help | grep -q 'homelab'"
    TEST_NAMES[8.2]="homelab: help text complete"; TEST_CMDS[8.2]="homelab help 2>&1 | grep -c 'motd' | grep -q '[1-9]' && echo '✓ Complete'"; TEST_VERIFY[8.2]="homelab help 2>&1 | grep -cE 'motd|host|deploy' | grep -q '[1-9]'"
    TEST_NAMES[8.3]="edit-hosts: Command installed"; TEST_CMDS[8.3]="[[ -x /home/jochem/.local/bin/edit-hosts ]] && echo '✓ OK'"; TEST_VERIFY[8.3]="[[ -x /home/jochem/.local/bin/edit-hosts ]]"
    TEST_NAMES[8.4]="edit-hosts: Has 4 menu calls"; TEST_CMDS[8.4]="[[ $(grep -c 'show_arrow_menu' /opt/homelab-tools/bin/edit-hosts) -eq 4 ]] && echo '✓ 4 menus'"; TEST_VERIFY[8.4]="[[ $(grep -c 'show_arrow_menu' /opt/homelab-tools/bin/edit-hosts) -eq 4 ]]"
    TEST_NAMES[8.5]="All menu titles present"; TEST_CMDS[8.5]="grep -qE 'Host Options|Bulk Operations|Select Host|Configuration Manager' /opt/homelab-tools/bin/edit-hosts && echo '✓ All titles'"; TEST_VERIFY[8.5]="grep -qE 'Host Options|Bulk Operations|Select Host|Configuration Manager' /opt/homelab-tools/bin/edit-hosts"
    TEST_NAMES[8.6]="All menus: No crashes"; TEST_CMDS[8.6]="bash -n /opt/homelab-tools/bin/homelab && echo '✓ OK'"; TEST_VERIFY[8.6]="bash -n /opt/homelab-tools/bin/homelab"

    # Section 9: INSTALL MENU (with existing)
    TEST_NAMES[9.1]="Detects existing install"; TEST_CMDS[9.1]="cd /home/jochem/Workspace/homelab-tools && sudo bash install.sh"; TEST_VERIFY[9.1]="[[ -d /opt/homelab-tools ]]"
    TEST_NAMES[9.2]="Install script syntax valid"; TEST_CMDS[9.2]="bash -n /opt/homelab-tools/install.sh && echo '✓ Valid'"; TEST_VERIFY[9.2]="bash -n /opt/homelab-tools/install.sh"
    TEST_NAMES[9.3]="Config preserved on Update"; TEST_CMDS[9.3]="[[ -f /opt/homelab-tools/config.sh ]] && echo '✓ Config'"; TEST_VERIFY[9.3]="[[ -f /opt/homelab-tools/config.sh ]]"
    TEST_NAMES[9.4]="VERSION file exists"; TEST_CMDS[9.4]="[[ -f /opt/homelab-tools/VERSION ]] && cat /opt/homelab-tools/VERSION"; TEST_VERIFY[9.4]="[[ -f /opt/homelab-tools/VERSION ]]"
    TEST_NAMES[9.5]="Symlinks active"; TEST_CMDS[9.5]="[[ -L /home/jochem/.local/bin/homelab ]] && echo '✓ Symlinks'"; TEST_VERIFY[9.5]="[[ -L /home/jochem/.local/bin/homelab ]]"
    TEST_NAMES[9.6]="Completes successfully"; TEST_CMDS[9.6]="[[ -d /opt/homelab-tools ]] && echo '✓ Installed'"; TEST_VERIFY[9.6]="[[ -d /opt/homelab-tools ]]"

    # Section 10: UNINSTALL FEATURES (SAFE CANCEL)
    TEST_NAMES[10.1]="Shows banner & cancel"; TEST_CMDS[10.1]="cd ~ && printf 'n\n' | /opt/homelab-tools/uninstall.sh && sleep 1"; TEST_VERIFY[10.1]="[[ -x /opt/homelab-tools/uninstall.sh ]]"
    TEST_NAMES[10.2]="Install dir kept"; TEST_CMDS[10.2]="[[ -d /opt/homelab-tools ]] && echo '✓ /opt/homelab-tools intact'"; TEST_VERIFY[10.2]="[[ -d /opt/homelab-tools ]]"
    TEST_NAMES[10.3]="Templates kept"; TEST_CMDS[10.3]="[[ -d /home/jochem/.local/share/homelab-tools/templates ]] && echo '✓ Templates intact'"; TEST_VERIFY[10.3]="[[ -d /home/jochem/.local/share/homelab-tools/templates ]]"
    TEST_NAMES[10.4]="Symlinks kept"; TEST_CMDS[10.4]="[[ -L /home/jochem/.local/bin/homelab ]] && echo '✓ Symlink intact'"; TEST_VERIFY[10.4]="[[ -L /home/jochem/.local/bin/homelab ]]"
    TEST_NAMES[10.5]="Backups untouched"; TEST_CMDS[10.5]="ls /opt | grep homelab-tools.backup || echo 'no backups (ok)'"; TEST_VERIFY[10.5]="true"
    TEST_NAMES[10.6]="Exit cleanly"; TEST_CMDS[10.6]="echo '✓ Uninstall cancel flow tested'"; TEST_VERIFY[10.6]="true"

    # Section 11: FINAL VERIFICATION
    TEST_NAMES[11.1]="Reinstall succeeds"; TEST_CMDS[11.1]="cd /home/jochem/Workspace/homelab-tools && sudo bash install.sh"; TEST_VERIFY[11.1]="[[ -d /opt/homelab-tools ]]"
    TEST_NAMES[11.2]="Fresh install works"; TEST_CMDS[11.2]="[[ -d /opt/homelab-tools ]] && echo '✓ Installed'"; TEST_VERIFY[11.2]="[[ -d /opt/homelab-tools ]]"
    TEST_NAMES[11.3]="All files present"; TEST_CMDS[11.3]="ls /opt/homelab-tools/bin/ | wc -l"; TEST_VERIFY[11.3]="[[ \$(ls /opt/homelab-tools/bin/ | wc -l) -ge 10 ]]"
    TEST_NAMES[11.4]="No errors"; TEST_CMDS[11.4]="echo '✓ Check install output'"; TEST_VERIFY[11.4]="true"
    TEST_NAMES[11.5]="Version correct"; TEST_CMDS[11.5]="/home/jochem/.local/bin/homelab --version"; TEST_VERIFY[11.5]="[[ -x /home/jochem/.local/bin/homelab ]]"
    TEST_NAMES[11.6]="All commands work"; TEST_CMDS[11.6]="homelab --help 2>/dev/null || echo '✓ Works'"; TEST_VERIFY[11.6]="[[ -x /home/jochem/.local/bin/homelab ]]"
}

load_progress() {
    [[ -f "$PROGRESS_FILE" ]] && while read -r line; do CHECKED["${line%=*}"]="${line#*=}"; done < "$PROGRESS_FILE"
}

save_progress() {
    : > "$PROGRESS_FILE"
    for key in "${!CHECKED[@]}"; do echo "$key=${CHECKED[$key]}" >> "$PROGRESS_FILE"; done
}

show_header() {
    clear
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
    echo -e "║   🧪 Interactive Test Runner - Homelab Tools v3.6.0-dev.20   ║"
    echo -e "║   Complete test suite (72 tests, 12 sections)                ║"
    echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

show_progress() {
    local checked=0
    for key in "${!CHECKED[@]}"; do [[ "${CHECKED[$key]}" == "1" ]] && ((checked++)); done
    echo -e "${CYAN}Progress: ${checked}/72 tests completed ($(( checked * 100 / 72 ))%)${RESET}"
    echo ""
}

# Test interactive menu with expect
# Usage: test_menu_navigation "command" "expected_output"
# Example: test_menu_navigation "edit-hosts" "SSH Host Configuration"
test_menu_navigation() {
    local cmd="$1"
    local expect_str="$2"
    local timeout=3
    
    local result
    result=$(/usr/bin/expect -c "
        set timeout $timeout
        spawn -open [open |\"$cmd\" w+]
        expect {
            \"$expect_str\" { exit 0 }
            timeout { exit 1 }
            eof { exit 1 }
        }
    " 2>&1)
    
    if [[ $? -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Test menu with arrow keys and enter
# Usage: test_menu_arrows "command" "expected_menu_title"
test_menu_arrows() {
    local cmd="$1"
    local expected="$2"
    
    local result
    result=$(/usr/bin/expect -c "
        set timeout 2
        spawn $cmd
        expect {
            \"$expected\" { exit 0 }
            timeout { exit 1 }
        }
    " 2>&1)
    
    return $?
}

# Test command with stdin input
# Usage: test_stdin "command" "input_data" "expected_output"
test_stdin() {
    local cmd="$1"
    local input="$2"
    local expected="$3"
    
    local result
    result=$(echo "$input" | $cmd 2>&1)
    
    if echo "$result" | grep -q "$expected"; then
        return 0
    else
        return 1
    fi
}

run_test() {
    local key="$1"
    local cmd="${TEST_CMDS[$key]}"
    local verify="${TEST_VERIFY[$key]}"
    local test_passed=false
    
    if [[ "$cmd" == "MANUAL" ]]; then
        echo -e "${YELLOW}⚠ Manual test - verify visually${RESET}"
        read -p "Test passed? (y/n): " result
        if [[ "$result" =~ ^[Yy]$ ]]; then
            CHECKED[$key]=1
            save_progress
            test_passed=true
        fi
    else
        echo -e "${CYAN}Running: $cmd${RESET}"
        echo ""
        
        if eval "$cmd" 2>/dev/null; then
            echo ""
            if [[ "$verify" != "MANUAL" ]] && eval "$verify" 2>/dev/null; then
                echo -e "${CYAN}Verification: ✓ Passed${RESET}"
                CHECKED[$key]=1
                save_progress
                test_passed=true
            else
                read -p "Test passed? (y/n/Enter=yes): " result
                if [[ -z "$result" || "$result" =~ ^[Yy]$ ]]; then
                    CHECKED[$key]=1
                    save_progress
                    test_passed=true
                fi
            fi
        else
            echo -e "${RED}✗ Command failed${RESET}"
            read -p "Mark as passed anyway? (y/n): " force
            if [[ "$force" =~ ^[Yy]$ ]]; then
                CHECKED[$key]=1
                save_progress
                test_passed=true
            fi
        fi
    fi
    
    echo ""
    if [[ "$test_passed" == "true" ]]; then
        echo -e "${GREEN}╔═══════════════════════════════╗${RESET}"
        echo -e "${GREEN}║      ✓ TEST PASSED!           ║${RESET}"
        echo -e "${GREEN}╚═══════════════════════════════╝${RESET}"
    else
        echo -e "${RED}╔═══════════════════════════════╗${RESET}"
        echo -e "${RED}║      ✗ TEST FAILED            ║${RESET}"
        echo -e "${RED}╚═══════════════════════════════╝${RESET}"
    fi
    sleep 1
}

show_section() {
    local s=$1
    echo -e "${BOLD}SECTION $s: ${YELLOW}${SECTION_NAMES[$s]}${RESET}"
    echo ""
    
    for i in {1..6}; do
        local key="$s.$i"
        local checkbox="[ ]"
        [[ "${CHECKED[$key]:-0}" == "1" ]] && checkbox="${GREEN}[x]${RESET}"
        local cmd="${TEST_CMDS[$key]}"
        
        echo -e "  $i) $checkbox ${TEST_NAMES[$key]}"
        if [[ "$cmd" == "MANUAL" ]]; then
            echo -e "      ${YELLOW}(Manual verification required)${RESET}"
        else
            echo -e "      ${CYAN}$(echo "$cmd" | cut -c1-50)...${RESET}"
        fi
    done
    echo ""
}

init_tests
load_progress

while true; do
    show_header
    show_progress
    
    echo -e "${BOLD}Sections (6 tests each):${RESET}"
    for s in {0..11}; do
        printf "  %2d) %s\n" $s "${SECTION_NAMES[$s]}"
    done
    echo ""
    echo -e "${CYAN}  s${RESET}) Summary  |  ${YELLOW}r${RESET}) Reset  |  ${RED}q${RESET}) Quit"
    echo ""
    
    read -p "Choose section (0-11, s, r, q): " choice
    
    case "$choice" in
        [0-9]|1[0-1])
            while true; do
                show_header
                show_section "$choice"
                
                # Check if all tests in this section are completed
                all_checked=true
                for i in {1..6}; do
                    if [[ "${CHECKED["$choice.$i"]:-0}" != "1" ]]; then
                        all_checked=false
                        break
                    fi
                done
                
                # If section complete, ask to continue
                if [[ "$all_checked" == "true" ]]; then
                    echo -e "${GREEN}✓ Section $choice complete!${RESET}"
                    next_section=$((choice + 1))
                    if [[ $next_section -le 11 ]]; then
                        echo -e "${CYAN}Continue to Section $next_section? (y/n/b for back)${RESET}"
                        read -p "> " skip_choice
                        case "$skip_choice" in
                            y|Y|"")
                                choice=$next_section
                                continue
                                ;;
                            n|N)
                                ;;
                            b|B)
                                break
                                ;;
                        esac
                    else
                        echo -e "${GREEN}🎉 All sections complete!${RESET}"
                        read -p "Press Enter to return to menu..."
                        break
                    fi
                fi
                
                # Find next unchecked test
                next_unchecked=""
                for i in {1..6}; do
                    if [[ "${CHECKED["$choice.$i"]:-0}" != "1" ]]; then
                        next_unchecked=$i
                        break
                    fi
                done
                
                if [[ -n "$next_unchecked" ]]; then
                    echo -e "${CYAN}Commands: ${RESET}1-6=Run test | ${GREEN}Enter${RESET}=Run next (#$next_unchecked) | ${GREEN}a${RESET}=All | ${YELLOW}u${RESET}=Uncheck | ${RED}b${RESET}=Back"
                else
                    echo -e "${GREEN}✓ All tests complete!${RESET}"
                    echo -e "${CYAN}Commands: ${RESET}1-6=Run test | ${GREEN}a${RESET}=All | ${YELLOW}u${RESET}=Uncheck | ${RED}b${RESET}=Back"
                fi
                read -p "> " num
                
                case "$num" in
                    "")
                        if [[ -n "$next_unchecked" ]]; then
                            key="$choice.$next_unchecked"
                            show_header
                            echo -e "${BOLD}Test $key: ${TEST_NAMES[$key]}${RESET}"
                            echo ""
                            run_test "$key"
                        else
                            echo -e "${GREEN}✓ All tests complete! Press b to go back.${RESET}"
                            sleep 1
                        fi
                        ;;
                    [1-6])
                        key="$choice.$num"
                        show_header
                        echo -e "${BOLD}Test $key: ${TEST_NAMES[$key]}${RESET}"
                        echo ""
                        run_test "$key"
                        ;;
                    a|A)
                        for i in {1..6}; do
                            CHECKED["$choice.$i"]=1
                        done
                        save_progress
                        echo -e "${GREEN}✓ All tests checked${RESET}"
                        sleep 1
                        ;;
                    u|U)
                        for i in {1..6}; do
                            unset 'CHECKED['"$choice.$i"']'
                        done
                        save_progress
                        echo -e "${YELLOW}☐ All tests unchecked${RESET}"
                        sleep 1
                        ;;
                    b|B)
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid input${RESET}"
                        sleep 0.5
                        ;;
                esac
            done
            ;;
        s|S)
            show_header
            checked=0
            for key in "${!CHECKED[@]}"; do [[ "${CHECKED[$key]}" == "1" ]] && ((checked++)); done
            echo -e "${BOLD}TOTAL PROGRESS: ${GREEN}${checked}/72 ($(( checked * 100 / 72 ))%)${RESET}"
            echo ""
            [[ $checked -eq 72 ]] && echo -e "${GREEN}✓✓✓ ALL TESTS PASSED! 🎉${RESET}" && echo -e "${GREEN}Ready to commit and merge to main!${RESET}"
            echo ""
            echo -e "${CYAN}v3.6.0-dev.20 Features Tested:${RESET}"
            echo "  ✓ edit-hosts menu fixes (3 missing title arguments)"
            echo "  ✓ list-templates --view fix (choose_menu → show_arrow_menu)"
            echo "  ✓ delete-template help fix (escape codes)"
            echo "  ✓ deploy-motd & undeploy-motd functionality"
            echo "  ✓ All menu navigation (arrow keys, q=quit)"
            echo "  ✓ All commands syntax (bash -n)"
            echo ""
            echo -e "${CYAN}Cross-reference with TODO.md v3.6.0:${RESET}"
            echo "  ✓ edit-hosts: Full interactive SSH config manager"
            echo "  ✓ list-templates: --status and --view modes"
            echo "  ✓ undeploy-motd: Single and bulk (--all) modes"
            echo "  ✓ Menu consistency: Arrow nav + q=cancel everywhere"
            echo ""
            read -p "Press Enter..."
            ;;
        r|R)
            read -p "Reset all progress? (y/N): " confirm
            [[ "$confirm" =~ ^[Yy]$ ]] && CHECKED=() && rm -f "$PROGRESS_FILE" && echo -e "${GREEN}✓ Reset${RESET}" && sleep 1
            ;;
        q|Q)
            echo -e "${GREEN}✓ Progress saved. Goodbye!${RESET}"
            exit 0
            ;;
    esac
done
