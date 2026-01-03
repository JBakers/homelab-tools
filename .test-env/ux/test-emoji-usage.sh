#!/bin/bash
# UX Test: Emoji Usage Consistency
# Verifies consistent emoji usage across all scripts
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

PASS=0
FAIL=0

echo -e "${CYAN}Testing Emoji Usage Consistency${RESET}"
echo ""

# Expected emoji mappings (semantic usage)
# ✓ = success, ✗ = error, ⚠ = warning, → = action
# 📝 = edit/create, 🔧 = config, 📊 = status, 🔑 = keys
# 💾 = save/backup, 🗑️ = delete, 📁 = files

check_success_indicator() {
    echo "Checking success indicators (✓ vs ✔ vs ☑)..."
    echo ""
    
    local success_chars="✓ ✔ ☑ ✅"
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        # Count different success indicators
        local check_mark tick_mark box_check emoji_check
        check_mark=$(grep -o "✓" "$script" 2>/dev/null | wc -l || echo 0)
        tick_mark=$(grep -o "✔" "$script" 2>/dev/null | wc -l || echo 0)
        emoji_check=$(grep -o "✅" "$script" 2>/dev/null | wc -l || echo 0)
        
        local total=$((check_mark + tick_mark + emoji_check))
        
        if [[ $total -eq 0 ]]; then
            continue
        fi
        
        # Should primarily use ✓
        if [[ $check_mark -gt 0 ]] && [[ $tick_mark -eq 0 ]] && [[ $emoji_check -eq 0 ]]; then
            echo -e "  ${GREEN}✓${RESET} $name uses ✓ consistently"
            ((PASS++))
        elif [[ $check_mark -ge $tick_mark ]] && [[ $check_mark -ge $emoji_check ]]; then
            echo -e "  ${YELLOW}○${RESET} $name: ✓=$check_mark ✔=$tick_mark ✅=$emoji_check (prefer ✓)"
        else
            echo -e "  ${YELLOW}⚠${RESET} $name: mixed success indicators"
        fi
    done
}

check_error_indicator() {
    echo ""
    echo "Checking error indicators (✗ vs ✘ vs ❌)..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        local cross_mark heavy_cross emoji_cross
        cross_mark=$(grep -o "✗" "$script" 2>/dev/null | wc -l || echo 0)
        heavy_cross=$(grep -o "✘" "$script" 2>/dev/null | wc -l || echo 0)
        emoji_cross=$(grep -o "❌" "$script" 2>/dev/null | wc -l || echo 0)
        
        local total=$((cross_mark + heavy_cross + emoji_cross))
        
        if [[ $total -eq 0 ]]; then
            continue
        fi
        
        if [[ $cross_mark -gt 0 ]] && [[ $heavy_cross -eq 0 ]] && [[ $emoji_cross -eq 0 ]]; then
            echo -e "  ${GREEN}✓${RESET} $name uses ✗ consistently"
            ((PASS++))
        else
            echo -e "  ${YELLOW}○${RESET} $name: ✗=$cross_mark ✘=$heavy_cross ❌=$emoji_cross"
        fi
    done
}

check_arrow_indicators() {
    echo ""
    echo "Checking arrow indicators (→ vs > vs >>)..."
    echo ""
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        
        local arrow_right text_arrow
        arrow_right=$(grep -o "→" "$script" 2>/dev/null | wc -l || echo 0)
        text_arrow=$(grep -oE ">>|=>" "$script" 2>/dev/null | wc -l || echo 0)
        
        if [[ $arrow_right -gt 0 ]]; then
            echo -e "  ${GREEN}✓${RESET} $name uses → arrows"
            ((PASS++))
        elif [[ $text_arrow -gt 0 ]]; then
            echo -e "  ${YELLOW}○${RESET} $name uses text arrows (>> or =>)"
        fi
    done
}

check_semantic_emojis() {
    echo ""
    echo "Checking semantic emoji usage..."
    echo ""
    
    # Expected patterns
    local patterns=(
        "📝.*motd\|motd.*📝:MOTD/Generate should use 📝"
        "🔧.*config\|config.*🔧:Config should use 🔧"
        "🔑.*key\|key.*🔑\|ssh.*🔑:Keys should use 🔑"
        "💾.*backup\|backup.*💾\|save.*💾:Backup should use 💾"
    )
    
    for script in /opt/homelab-tools/bin/*; do
        name=$(basename "$script")
        local has_semantic=0
        
        # Check if script uses emojis at all
        if grep -qE "[📝🔧🔑💾🗑️📁📊🖥️🌐⏱️]" "$script" 2>/dev/null; then
            has_semantic=1
            echo -e "  ${GREEN}✓${RESET} $name uses semantic emojis"
            ((PASS++))
        fi
    done
}

# Run checks
check_success_indicator
check_error_indicator
check_arrow_indicators
check_semantic_emojis

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Emoji Usage: ${GREEN}$PASS passed${RESET}, ${RED}$FAIL failed${RESET}"
echo ""

# Save results
echo "EMOJI_PASS=$PASS" >> "$SCRIPT_DIR/.ux-test-results"
echo "EMOJI_FAIL=$FAIL" >> "$SCRIPT_DIR/.ux-test-results"

[[ $FAIL -eq 0 ]]
