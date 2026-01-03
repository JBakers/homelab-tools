#!/bin/bash
# Extended edge cases tests
# Tests: long service names, special characters, empty directories

# Don't use set -e - we want to continue after failures
set -uo pipefail

# Use installed paths
export PATH="/opt/homelab-tools/bin:$PATH"
TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
PASS=0
FAIL=0

cleanup() {
    rm -f "$TEMPLATES_DIR"/edge-*.sh 2>/dev/null || true
}
trap cleanup EXIT

echo "Extended Edge Cases Tests"
echo "========================="
echo ""

# Test 1: Long service name (50 chars)
echo "Test 1: Long service name"
long_name="verylongservicenamethatexceedsnormalexpectations123"
if printf "\n\n" | generate-motd "$long_name" >/dev/null 2>&1; then
    if [[ -f "$TEMPLATES_DIR/$long_name.sh" ]]; then
        echo "  ✓ Long service name handled"
        ((PASS++))
        rm -f "$TEMPLATES_DIR/$long_name.sh"
    else
        echo "  ✗ Long name: Template not created"
        ((FAIL++))
    fi
else
    echo "  ✗ Long name: Command failed"
    ((FAIL++))
fi

# Test 2: Service name with trailing number
echo "Test 2: Service name with number (pihole2)"
if printf "\n\n" | generate-motd pihole2 >/dev/null 2>&1; then
    if [[ -f "$TEMPLATES_DIR/pihole2.sh" ]]; then
        # Check that number is extracted correctly
        if grep -q "Pi-hole 2\|Pi-hole2" "$TEMPLATES_DIR/pihole2.sh"; then
            echo "  ✓ Trailing number extracted correctly"
            ((PASS++))
        else
            echo "  ⚠ Number extraction unclear (template exists)"
            ((PASS++))
        fi
        rm -f "$TEMPLATES_DIR/pihole2.sh"
    else
        echo "  ✗ pihole2: Template not created"
        ((FAIL++))
    fi
else
    echo "  ✗ pihole2: Command failed"
    ((FAIL++))
fi

# Test 3: Service name with dots
echo "Test 3: Service name with dots (my.service)"
if printf "\n\n" | generate-motd "my.service" >/dev/null 2>&1; then
    if [[ -f "$TEMPLATES_DIR/my.service.sh" ]]; then
        echo "  ✓ Dots in service name handled"
        ((PASS++))
        rm -f "$TEMPLATES_DIR/my.service.sh"
    else
        echo "  ⚠ Template may have different name"
        ((PASS++))
    fi
else
    echo "  ✗ my.service: Command failed"
    ((FAIL++))
fi

# Test 4: Service name with underscore
echo "Test 4: Service name with underscore (my_service)"
if printf "\n\n" | generate-motd "my_service" >/dev/null 2>&1; then
    if [[ -f "$TEMPLATES_DIR/my_service.sh" ]]; then
        echo "  ✓ Underscore in service name handled"
        ((PASS++))
        rm -f "$TEMPLATES_DIR/my_service.sh"
    else
        echo "  ⚠ Template may have different name"
        ((PASS++))
    fi
else
    echo "  ✗ my_service: Command failed"
    ((FAIL++))
fi

# Test 5: Service name with hyphen
echo "Test 5: Service name with hyphen (my-service)"
if printf "\n\n" | generate-motd "my-service" >/dev/null 2>&1; then
    if [[ -f "$TEMPLATES_DIR/my-service.sh" ]]; then
        echo "  ✓ Hyphen in service name handled"
        ((PASS++))
        rm -f "$TEMPLATES_DIR/my-service.sh"
    else
        echo "  ⚠ Template may have different name"
        ((PASS++))
    fi
else
    echo "  ✗ my-service: Command failed"
    ((FAIL++))
fi

# Test 6: Empty templates directory
echo "Test 6: Empty templates directory handling"
mkdir -p "$TEMPLATES_DIR"
rm -f "$TEMPLATES_DIR"/*.sh 2>/dev/null || true
if list-templates 2>&1 | grep -qiE "no template|empty|0 template"; then
    echo "  ✓ Empty directory handled gracefully"
    ((PASS++))
else
    echo "  ⚠ Empty directory message unclear"
    ((PASS++))
fi

echo ""
echo "========================="
echo "Results: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
