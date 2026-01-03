#!/usr/bin/env bats
# BATS Tests - MOTD Designer

load '/workspace/.test-env/spec/support/helpers.sh'

setup() {
    setup_test_env
    cleanup_templates
}

teardown() {
    cleanup_templates
}

@test "motd-designer creates template non-interactive" {
    /opt/homelab-tools/bin/motd-designer --name designer-test --style clean --header "Designer Test" --blocks hostname,ip >/dev/null 2>&1
    assert_template_exists designer-test
    assert_template_has_markers designer-test
}

@test "motd-designer invalid style fails" {
    run /opt/homelab-tools/bin/motd-designer --name badstyle --style not_a_style --header "Test" --blocks hostname
    [ "$status" -ne 0 ]
}
