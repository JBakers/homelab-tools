#!/bin/bash
# lib/validators.sh - Centralized input validation functions
# Usage: source "$LIB_DIR/validators.sh"

# Validate service name (alphanumeric, dots, underscores, hyphens)
validate_service() {
    local service="$1"
    if [[ ! "$service" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        return 1
    fi
    return 0
}

# Validate hostname (RFC-compliant + IP addresses)
validate_hostname() {
    local hostname="$1"
    
    # Check for IP address (simple check, requires dots and digits)
    if [[ "$hostname" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # Verify octets are 0-255
        local IFS='.'
        for octet in $hostname; do
            if (( octet > 255 )); then
                return 1
            fi
        done
        return 0
    fi
    
    # Hostname validation (RFC 952/1123):
    # - Start with letter or digit
    # - Contains only letters, digits, hyphens, dots
    # - End with letter or digit
    # - No consecutive dots or hyphens
    if [[ $hostname =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]]; then
        # Additional check: no consecutive dots or hyphens
        if [[ ! "$hostname" =~ \.\.|\-\-|^\-|^\.|\.$ ]]; then
            return 0
        fi
    fi
    return 1
}

# Validate file path (no traversal attacks)
validate_path() {
    local path="$1"
    
    # Block absolute paths outside home
    if [[ "$path" =~ ^/ ]]; then
        return 1
    fi
    
    # Block path traversal
    if [[ "$path" =~ \.\. ]]; then
        return 1
    fi
    
    return 0
}

# Validate port number (1-65535)
validate_port() {
    local port="$1"
    
    if [[ ! "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
        return 1
    fi
    return 0
}

# Export all validators
export -f validate_service validate_hostname validate_path validate_port
