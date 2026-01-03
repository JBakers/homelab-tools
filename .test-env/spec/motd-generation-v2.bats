#!/usr/bin/env bats
# BATS Tests - MOTD Generation v2
# Simplified approach - inline helpers

# ============================================================
# HELPER FUNCTIONS (inlined for BATS compatibility)
# ============================================================

setup_test_env() {
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    mkdir -p "$TEMPLATES_DIR" "$HOME/.local/share/homelab-tools"
}

cleanup_templates() {
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    rm -f "$TEMPLATES_DIR"/*.sh
}

assert_template_exists() {
    local service="$1"
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    [ -f "$TEMPLATES_DIR/$service.sh" ]
}

assert_template_has_markers() {
    local service="$1"
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    local template="$TEMPLATES_DIR/$service.sh"
    grep -q "# === HLT-MOTD-START ===" "$template" && \
    grep -q "# === HLT-MOTD-END ===" "$template"
}

assert_template_valid_bash() {
    local service="$1"
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    local template="$TEMPLATES_DIR/$service.sh"
    bash -n "$template" 2>/dev/null
}

# ============================================================
# SETUP & TEARDOWN
# ============================================================

setup() {
    setup_test_env
    cleanup_templates
    # Make sure scripts are executable and in PATH
    export PATH="/opt/homelab-tools/bin:$PATH"
}

teardown() {
    cleanup_templates
}

# ============================================================
# BASIC GENERATION TESTS
# ============================================================

@test "generate-motd creates template file" {
    printf "\n\n\n" | generate-motd testservice >/dev/null 2>&1
    assert_template_exists testservice
}

@test "generated template has correct shebang" {
    printf "\n\n\n" | generate-motd pihole >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    head -1 "$TEMPLATES_DIR/pihole.sh" | grep -q "^#!/bin/bash"
}

@test "generated template is executable" {
    printf "\n\n\n" | generate-motd jellyfin >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    [ -x "$TEMPLATES_DIR/jellyfin.sh" ]
}

@test "generated template has valid bash syntax" {
    printf "\n\n\n" | generate-motd sonarr >/dev/null 2>&1
    assert_template_valid_bash sonarr
}

# ============================================================
# HLT MARKER TESTS
# ============================================================

@test "template has HLT-MOTD-START marker" {
    printf "\n\n\n" | generate-motd testmarkers >/dev/null 2>&1
    assert_template_has_markers testmarkers
}

@test "template has HLT-MOTD-END marker" {
    printf "\n\n\n" | generate-motd endmarker >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    grep -q "# === HLT-MOTD-END ===" "$TEMPLATES_DIR/endmarker.sh"
}

# ============================================================
# CONTENT TESTS
# ============================================================

@test "template contains system information" {
    printf "\n\n\n" | generate-motd sysinfo >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    grep -q "Hostname\|Uptime" "$TEMPLATES_DIR/sysinfo.sh"
}

@test "service name is in template" {
    printf "\n\n\n" | generate-motd radarr >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    grep -q "Radarr" "$TEMPLATES_DIR/radarr.sh"
}

@test "service name with number detected correctly" {
    printf "\n\n\n" | generate-motd pihole2 >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    grep -q "Pi-hole 2" "$TEMPLATES_DIR/pihole2.sh"
}

# ============================================================
# WEB UI TESTS
# ============================================================

@test "Web UI link added when specified" {
    printf "y\n8080\n" | generate-motd webtest >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    grep -q ":8080" "$TEMPLATES_DIR/webtest.sh"
}

@test "port is in Web UI URL" {
    printf "y\n5000\n" | generate-motd porttest >/dev/null 2>&1
    TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
    grep -q ":5000" "$TEMPLATES_DIR/porttest.sh"
}

# ============================================================
# ERROR HANDLING
# ============================================================

@test "rejects invalid service name" {
    run bash -c 'printf "\n\n\n" | generate-motd "; echo hacked" 2>&1'
    [ "$status" -ne 0 ]
}

@test "shows error for invalid characters" {
    run bash -c 'generate-motd "; rm -rf /" 2>&1'
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Invalid" ]]
}
