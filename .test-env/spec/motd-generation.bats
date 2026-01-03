#!/usr/bin/env bats
# BATS Tests - MOTD Generation
# Tests for generate-motd functionality

# Load helpers from fixed path
load '/workspace/.test-env/spec/support/helpers.sh'

setup() {
    setup_test_env
    cleanup_templates
    cleanup_deploy_log
}

teardown() {
    cleanup_templates
}

# ============================================================
# BASIC GENERATION TESTS
# ============================================================

@test "generate-motd creates template file" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd testservice >/dev/null 2>&1
    assert_template_exists testservice
}

@test "generated template has correct shebang" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd pihole >/dev/null 2>&1
    assert_template_has_shebang pihole
}

@test "generated template is executable" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd jellyfin >/dev/null 2>&1
    assert_template_is_executable jellyfin
}

@test "generated template has valid bash syntax" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd sonarr >/dev/null 2>&1
    assert_template_valid_bash sonarr
}

# ============================================================
# HLT MARKER TESTS
# ============================================================

@test "template has HLT-MOTD-START marker" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd testmarkers >/dev/null 2>&1
    assert_template_has_markers testmarkers
}

@test "template has HLT-MOTD-END marker" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd endmarker >/dev/null 2>&1
    assert_template_has_markers endmarker
}

# ============================================================
# CONTENT TESTS
# ============================================================

@test "template contains system information" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd sysinfo >/dev/null 2>&1
    assert_template_contains sysinfo "Hostname\|Uptime"
}

@test "service name is in template" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd radarr >/dev/null 2>&1
    assert_template_has_service_name radarr "Radarr"
}

@test "service name with number detected correctly" {
    printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd pihole2 >/dev/null 2>&1
    assert_template_has_service_name pihole2 "Pi-hole 2"
}

# ============================================================
# WEB UI TESTS
# ============================================================

@test "Web UI link added when specified" {
    printf "y\n8080\n" | /opt/homelab-tools/bin/generate-motd webtest >/dev/null 2>&1
    assert_template_contains webtest ":8080"
}

@test "port is in Web UI URL" {
    printf "y\n5000\n" | /opt/homelab-tools/bin/generate-motd porttest >/dev/null 2>&1
    assert_template_contains porttest ":5000"
}

# ============================================================
# ERROR HANDLING
# ============================================================

@test "rejects invalid service name" {
    run bash -c 'printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd "; echo hacked" 2>&1'
    [ "$status" -ne 0 ]
}

@test "shows error for invalid characters" {
    run bash -c '/opt/homelab-tools/bin/generate-motd "; rm -rf /" 2>&1'
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Invalid" ]]
}
