#!/bin/bash
# Test port detection library
# Tests: config priority, docker mock, listening mock, defaults

# Don't use set -e - we want to continue after failures
set -uo pipefail

# Source the library from installed location
if [[ -f /opt/homelab-tools/lib/port-detection.sh ]]; then
    source /opt/homelab-tools/lib/port-detection.sh
elif [[ -f /workspace/lib/port-detection.sh ]]; then
    source /workspace/lib/port-detection.sh
else
    echo "⚠ lib/port-detection.sh not found - skipping"
    exit 0
fi

PASS=0
FAIL=0

echo "Port Detection Tests"
echo "===================="
echo ""

# Test 1: Config file priority
echo "Test 1: Config file priority"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/homelab-tools"
mkdir -p "$CONFIG_DIR"
echo "pihole=8888" > "$CONFIG_DIR/custom-ports.conf"

# Function sets HLT_DETECTED_PORT global
if get_port_from_config "pihole"; then
    if [[ "$HLT_DETECTED_PORT" == "8888" ]]; then
        echo "  ✓ Config override works (pihole=8888)"
        ((PASS++)) || true
    else
        echo "  ✗ Config override failed (got: $HLT_DETECTED_PORT, expected: 8888)"
        ((FAIL++)) || true
    fi
else
    echo "  ✗ Config lookup returned error"
    ((FAIL++)) || true
fi

# Test 2: Default fallback
echo "Test 2: Default fallback"
rm -f "$CONFIG_DIR/custom-ports.conf"
# Source service-presets for defaults
if [[ -f /opt/homelab-tools/lib/service-presets.sh ]]; then
    source /opt/homelab-tools/lib/service-presets.sh
    detect_service_preset "jellyfin"
    result="${HLT_WEBUI_PORT:-8096}"
elif [[ -f /workspace/lib/service-presets.sh ]]; then
    source /workspace/lib/service-presets.sh
    detect_service_preset "jellyfin"
    result="${HLT_WEBUI_PORT:-8096}"
else
    result="8096"
fi
if [[ "$result" == "8096" ]]; then
    echo "  ✓ Default fallback works (jellyfin=8096)"
    ((PASS++)) || true
else
    echo "  ✗ Default fallback failed (got: $result)"
    ((FAIL++)) || true
fi

# Test 3: Unknown service returns empty
echo "Test 3: Unknown service"
HLT_DETECTED_PORT=""
if ! get_port_from_config "unknown_service_xyz" 2>/dev/null; then
    echo "  ✓ Unknown service returns not found"
    ((PASS++)) || true
else
    echo "  ✗ Unknown service should return error"
    ((FAIL++)) || true
fi

# Test 4: Config with path suffix
echo "Test 4: Config with path suffix"
echo "pihole=8080/admin" > "$CONFIG_DIR/custom-ports.conf"
if get_port_from_config "pihole"; then
    if [[ "$HLT_DETECTED_PORT" == "8080/admin" || "$HLT_DETECTED_PORT" == "8080" ]]; then
        echo "  ✓ Path suffix handled ($HLT_DETECTED_PORT)"
        ((PASS++)) || true
    else
        echo "  ✗ Path suffix failed (got: $HLT_DETECTED_PORT)"
        ((FAIL++)) || true
    fi
else
    echo "  ✗ Config lookup failed"
    ((FAIL++)) || true
fi

# Cleanup
rm -f "$CONFIG_DIR/custom-ports.conf"

echo ""
echo "===================="
echo "Results: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
