#!/bin/bash
# lib/ssh-helpers.sh - Centralized SSH utilities
# Usage: source "$LIB_DIR/ssh-helpers.sh"

# SSH options for security and robustness
readonly SSH_CONFIG="$HOME/.ssh/config"
readonly SSH_TIMEOUT=5
readonly SSH_OPTIONS=(-o ConnectTimeout=$SSH_TIMEOUT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null)

# Test SSH connectivity to a host
# Usage: test_ssh_connection "hostname" [config_file]
# Returns: 0 if connected, 1 if not
test_ssh_connection() {
    local hostname="$1"
    local config_file="${2:-$SSH_CONFIG}"
    
    ssh -F "$config_file" "${SSH_OPTIONS[@]}" -o BatchMode=yes "$hostname" -- echo "connected" &>/dev/null
    return $?
}

# Execute SSH command with automatic sudo fallback
# Usage: ssh_exec "hostname" "command"
# Tries direct execution first, falls back to sudo if needed
ssh_exec() {
    local hostname="$1"
    local command="$2"
    
    if ssh -F "$SSH_CONFIG" "${SSH_OPTIONS[@]}" -- "$hostname" "$command" 2>/dev/null; then
        return 0
    fi
    
    # Fallback: try with sudo
    if ssh -F "$SSH_CONFIG" "${SSH_OPTIONS[@]}" -- "$hostname" "sudo $command" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

# Copy file to remote host via SCP
# Usage: scp_to_host "local_path" "hostname" "remote_path"
scp_to_host() {
    local local_path="$1"
    local hostname="$2"
    local remote_path="$3"
    
    scp -F "$SSH_CONFIG" "${SSH_OPTIONS[@]}" "$local_path" "${hostname}:${remote_path}" 2>/dev/null
    return $?
}

# Export all SSH helpers
export -f test_ssh_connection ssh_exec scp_to_host
