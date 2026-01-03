#!/bin/bash
# Test all 10 ASCII styles in generate-motd
# Tests: clean, rainbow_future, rainbow_standard, mono_future, big_mono, small, emboss, pagga, trek, term

# Don't use set -e - we want to continue after failures
set -uo pipefail

export PATH="/opt/homelab-tools/bin:$PATH"
TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
PASS=0
FAIL=0

cleanup() {
    rm -f "$TEMPLATES_DIR"/ascii-test-*.sh 2>/dev/null || true
}
trap cleanup EXIT

# Style index to name mapping (1-based for menu)
declare -A STYLE_NAMES=(
    [1]="clean"
    [2]="rainbow_future"
    [3]="rainbow_standard"
    [4]="mono_future"
    [5]="big_mono"
    [6]="small"
    [7]="emboss"
    [8]="pagga"
    [9]="trek"
    [10]="term"
)

echo "ASCII Styles Test - All 10 Styles"
echo "=================================="
echo ""

# Check if toilet is available
if ! command -v toilet &>/dev/null; then
    echo "⚠ Toilet not installed - skipping ASCII rendering tests"
    echo "  Only testing style 1 (clean)"
    
    # Test clean style only
    printf "\n\n" | generate-motd ascii-test-clean >/dev/null 2>&1
    if [[ -f "$TEMPLATES_DIR/ascii-test-clean.sh" ]]; then
        echo "✓ Style 1 (clean): Template created"
        ((PASS++))
    else
        echo "✗ Style 1 (clean): Template NOT created"
        ((FAIL++))
    fi
else
    # Test each style
    for idx in {1..10}; do
        style="${STYLE_NAMES[$idx]}"
        service="ascii-test-$style"
        
        # Generate with style selection
        # Menu: Continue (0), then style selection (idx-1 for 0-based)
        # Style menu starts at index 0
        style_select=$((idx - 1))
        
        # Use expect to handle interactive menu
        expect -c "
            set timeout 10
            spawn generate-motd $service
            expect -re \"Continue|settings\"
            send \"\r\"
            expect -re \"style|Style\"
            # Navigate to correct style
            for {set i 0} {\$i < $style_select} {incr i} {
                send \"\033\[B\"
            }
            send \"\r\"
            expect eof
        " >/dev/null 2>&1 || true
        
        if [[ -f "$TEMPLATES_DIR/$service.sh" ]]; then
            # Verify template is valid bash
            if bash -n "$TEMPLATES_DIR/$service.sh" 2>/dev/null; then
                echo "✓ Style $idx ($style): Valid template"
                ((PASS++))
            else
                echo "✗ Style $idx ($style): Invalid bash syntax"
                ((FAIL++))
            fi
        else
            echo "✗ Style $idx ($style): Template NOT created"
            ((FAIL++))
        fi
    done
fi

echo ""
echo "=================================="
echo "Results: $PASS passed, $FAIL failed"

# Allow up to 2 failures (some fonts may not be installed)
if [[ $FAIL -gt 2 ]]; then
    exit 1
fi
exit 0
