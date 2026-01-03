#!/bin/bash
# BATS Test Helpers - Common functions for all tests

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Test environment paths
TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
MOTD_PATH="/etc/update-motd.d/00-custom"
DEPLOY_LOG="$HOME/.local/share/homelab-tools/deploy-log"

# ============================================================
# SETUP FUNCTIONS
# ============================================================

setup_test_env() {
    # Create necessary directories
    mkdir -p "$TEMPLATES_DIR" "$HOME/.local/share/homelab-tools"
    mkdir -p "$HOME/.ssh" "$HOME/.config/homelab-tools"
}

cleanup_templates() {
    # Remove all test templates
    rm -f "$TEMPLATES_DIR"/*.sh
}

cleanup_deploy_log() {
    # Clear deployment log for fresh test
    rm -f "$DEPLOY_LOG"
}

# ============================================================
# TEMPLATE VALIDATION FUNCTIONS
# ============================================================

assert_template_exists() {
    local service="$1"
    [ -f "$TEMPLATES_DIR/$service.sh" ]
}

assert_template_has_markers() {
    local service="$1"
    local template="$TEMPLATES_DIR/$service.sh"
    
    grep -q "# === HLT-MOTD-START ===" "$template" || return 1
    grep -q "# === HLT-MOTD-END ===" "$template" || return 1
}

assert_template_has_service_name() {
    local service="$1"
    local expected_name="$2"
    local template="$TEMPLATES_DIR/$service.sh"
    
    grep -q "$expected_name" "$template"
}

assert_template_is_executable() {
    local service="$1"
    local template="$TEMPLATES_DIR/$service.sh"
    
    [ -x "$template" ]
}

assert_template_has_shebang() {
    local service="$1"
    local template="$TEMPLATES_DIR/$service.sh"
    
    head -1 "$template" | grep -q "^#!/bin/bash"
}

assert_template_valid_bash() {
    local service="$1"
    local template="$TEMPLATES_DIR/$service.sh"
    
    bash -n "$template" 2>/dev/null
}

assert_template_contains() {
    local service="$1"
    local pattern="$2"
    local template="$TEMPLATES_DIR/$service.sh"
    
    grep -q "$pattern" "$template"
}

# ============================================================
# DEPLOYMENT FUNCTIONS
# ============================================================

get_deploy_log_entry() {
    local service="$1"
    grep "^$service|" "$DEPLOY_LOG" 2>/dev/null | tail -1
}

assert_deploy_log_exists() {
    [ -f "$DEPLOY_LOG" ]
}

assert_service_in_deploy_log() {
    local service="$1"
    grep -q "^$service|" "$DEPLOY_LOG"
}

get_template_hash() {
    local service="$1"
    local template="$TEMPLATES_DIR/$service.sh"
    md5sum "$template" 2>/dev/null | awk '{print $1}'
}

# ============================================================
# MOCK FUNCTIONS
# ============================================================

create_mock_ssh() {
    # Create mock SSH that succeeds
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/ssh" << 'EOF'
#!/bin/bash
# Mock SSH - returns success
exit 0
EOF
    chmod +x "$HOME/.local/bin/ssh"
}

remove_mock_ssh() {
    rm -f "$HOME/.local/bin/ssh"
}

# ============================================================
# DEBUG FUNCTIONS
# ============================================================

debug_template() {
    local service="$1"
    local template="$TEMPLATES_DIR/$service.sh"
    
    if [ -f "$template" ]; then
        echo "=== Template: $service ===" >&2
        head -20 "$template" >&2
    else
        echo "Template not found: $template" >&2
    fi
}

debug_deploy_log() {
    echo "=== Deploy Log ===" >&2
    if [ -f "$DEPLOY_LOG" ]; then
        cat "$DEPLOY_LOG" >&2
    else
        echo "Deploy log not created" >&2
    fi
}
