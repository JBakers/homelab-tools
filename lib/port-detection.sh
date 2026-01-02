#!/bin/bash
# lib/port-detection.sh - Smart port detection for homelab services
#
# This library provides automatic port detection via multiple methods:
# 1. User config file (~/.config/homelab-tools/custom-ports.conf)
# 2. Docker container inspection
# 3. Active listening ports (ss/netstat)
# 4. Fallback to service-presets.sh defaults
#
# Usage:
#   source "$LIB_DIR/port-detection.sh"
#   detect_port "pihole" "192.168.1.10"
#   echo "$HLT_DETECTED_PORT"     # e.g., "8080" or default from presets
#   echo "$HLT_PORT_SOURCE"       # "config", "docker", "listening", or "default"
#
# Author: J.Bakers
# Version: See VERSION file

# Configuration paths (only set if not already defined)
if [[ -z "${HLT_CONFIG_DIR:-}" ]]; then
    readonly HLT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/homelab-tools"
fi
if [[ -z "${HLT_CUSTOM_PORTS_FILE:-}" ]]; then
    readonly HLT_CUSTOM_PORTS_FILE="$HLT_CONFIG_DIR/custom-ports.conf"
fi

#──────────────────────────────────────────────────────────────────────────────
# Function: init_port_detection
# Description: Initialize port detection, create config directory if needed
# Arguments: None
# Returns: 0 on success
# Globals Modified: Creates HLT_CONFIG_DIR if not exists
#──────────────────────────────────────────────────────────────────────────────
init_port_detection() {
    if [[ ! -d "$HLT_CONFIG_DIR" ]]; then
        mkdir -p "$HLT_CONFIG_DIR"
    fi
    
    # Create example config if not exists
    if [[ ! -f "$HLT_CUSTOM_PORTS_FILE" ]]; then
        create_example_ports_config
    fi
}

#──────────────────────────────────────────────────────────────────────────────
# Function: create_example_ports_config
# Description: Create example custom-ports.conf with documentation
# Arguments: None
# Returns: 0 on success
# Globals: HLT_CUSTOM_PORTS_FILE
#──────────────────────────────────────────────────────────────────────────────
create_example_ports_config() {
    cat > "$HLT_CUSTOM_PORTS_FILE" << 'EOF'
# Homelab Tools - Custom Ports Configuration
# ==========================================
#
# Override default ports for your services.
# Format: service_name=port
#
# Examples:
# pihole=8080          # Pi-hole on non-standard port
# jellyfin=8097        # Jellyfin on custom port
# traefik=8888         # Traefik dashboard
#
# You can also specify full paths for web UI:
# plex=32401/web       # Plex with custom port and path
# pihole=8080/admin    # Pi-hole admin interface
#
# Lines starting with # are comments.
# Empty lines are ignored.

# === Your custom ports below ===

EOF
}

#──────────────────────────────────────────────────────────────────────────────
# Function: get_port_from_config
# Description: Check custom-ports.conf for user-defined port override
# Arguments:
#   $1 - Service name (e.g., "pihole", "jellyfin")
# Returns: 0 if found, 1 if not found
# Globals Modified:
#   HLT_DETECTED_PORT - The detected port
#   HLT_PORT_SOURCE - Set to "config"
#──────────────────────────────────────────────────────────────────────────────
get_port_from_config() {
    local service="$1"
    local port
    
    if [[ ! -f "$HLT_CUSTOM_PORTS_FILE" ]]; then
        return 1
    fi
    
    # Read config, skip comments and empty lines
    port=$(grep -E "^${service}=" "$HLT_CUSTOM_PORTS_FILE" 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d '[:space:]')
    
    if [[ -n "$port" ]]; then
        HLT_DETECTED_PORT="$port"
        HLT_PORT_SOURCE="config"
        return 0
    fi
    
    return 1
}

#──────────────────────────────────────────────────────────────────────────────
# Function: get_port_from_docker
# Description: Detect port from Docker container port mappings
# Arguments:
#   $1 - Service name (container name or partial match)
#   $2 - Host (SSH target, optional - uses localhost if not provided)
# Returns: 0 if found, 1 if not found
# Globals Modified:
#   HLT_DETECTED_PORT - The detected port
#   HLT_PORT_SOURCE - Set to "docker"
# Notes: Requires Docker access on target host
#──────────────────────────────────────────────────────────────────────────────
get_port_from_docker() {
    local service="$1"
    local host="${2:-localhost}"
    local port
    local docker_cmd
    
    # Build docker command - local or remote
    if [[ "$host" == "localhost" || "$host" == "127.0.0.1" ]]; then
        docker_cmd="docker"
    else
        docker_cmd="ssh -o ConnectTimeout=3 -o BatchMode=yes $host docker"
    fi
    
    # Try to get port from container with matching name
    # Format: 0.0.0.0:8096->8096/tcp -> extract 8096
    port=$($docker_cmd ps --filter "name=$service" --format '{{.Ports}}' 2>/dev/null | \
           grep -oE '0\.0\.0\.0:[0-9]+' | head -1 | cut -d':' -f2)
    
    if [[ -n "$port" ]]; then
        HLT_DETECTED_PORT="$port"
        HLT_PORT_SOURCE="docker"
        return 0
    fi
    
    return 1
}

#──────────────────────────────────────────────────────────────────────────────
# Function: get_port_from_listening
# Description: Detect port from active listening services (ss/netstat)
# Arguments:
#   $1 - Service name (process name or partial match)
#   $2 - Host (SSH target, optional - uses localhost if not provided)
# Returns: 0 if found, 1 if not found
# Globals Modified:
#   HLT_DETECTED_PORT - The detected port
#   HLT_PORT_SOURCE - Set to "listening"
# Notes: Requires ss or netstat on target host
#──────────────────────────────────────────────────────────────────────────────
get_port_from_listening() {
    local service="$1"
    local host="${2:-localhost}"
    local port
    local cmd_prefix=""
    
    # Build command prefix for remote execution
    if [[ "$host" != "localhost" && "$host" != "127.0.0.1" ]]; then
        cmd_prefix="ssh -o ConnectTimeout=3 -o BatchMode=yes $host"
    fi
    
    # Try ss first (modern), then netstat (legacy)
    # Look for process name matching service
    port=$($cmd_prefix ss -tlnp 2>/dev/null | grep -i "$service" | \
           grep -oE ':[0-9]+' | head -1 | tr -d ':')
    
    if [[ -z "$port" ]]; then
        # Fallback to netstat
        port=$($cmd_prefix netstat -tlnp 2>/dev/null | grep -i "$service" | \
               grep -oE ':[0-9]+' | head -1 | tr -d ':')
    fi
    
    if [[ -n "$port" ]]; then
        HLT_DETECTED_PORT="$port"
        HLT_PORT_SOURCE="listening"
        return 0
    fi
    
    return 1
}

#──────────────────────────────────────────────────────────────────────────────
# Function: detect_port
# Description: Smart port detection using multiple methods in priority order
# Arguments:
#   $1 - Service name (e.g., "pihole", "jellyfin")
#   $2 - Host (SSH target, optional - for remote detection)
# Returns: 0 on success (always succeeds with at least default)
# Globals Modified:
#   HLT_DETECTED_PORT - The detected port (or default from presets)
#   HLT_PORT_SOURCE - Source of detection: "config", "docker", "listening", "default"
# Notes: 
#   Detection order: config > docker > listening > presets default
#   Requires service-presets.sh to be sourced for fallback defaults
#──────────────────────────────────────────────────────────────────────────────
detect_port() {
    local service="$1"
    local host="${2:-localhost}"
    
    # Reset globals
    HLT_DETECTED_PORT=""
    HLT_PORT_SOURCE=""
    
    # 1. Check user config first (highest priority)
    if get_port_from_config "$service"; then
        return 0
    fi
    
    # 2. Try Docker container detection
    if get_port_from_docker "$service" "$host"; then
        return 0
    fi
    
    # 3. Try listening port detection
    if get_port_from_listening "$service" "$host"; then
        return 0
    fi
    
    # 4. Fallback to presets default
    # Requires service-presets.sh to be sourced
    if type detect_service_preset &>/dev/null; then
        detect_service_preset "$service"
        if [[ -n "$HLT_WEBUI_PORT" ]]; then
            HLT_DETECTED_PORT="$HLT_WEBUI_PORT"
            HLT_PORT_SOURCE="default"
            return 0
        fi
    fi
    
    # No port found
    HLT_PORT_SOURCE="unknown"
    return 1
}

#──────────────────────────────────────────────────────────────────────────────
# Function: get_all_custom_ports
# Description: Get all custom port configurations from config file
# Arguments: None
# Returns: Outputs service=port pairs, one per line
# Globals: HLT_CUSTOM_PORTS_FILE
#──────────────────────────────────────────────────────────────────────────────
get_all_custom_ports() {
    if [[ -f "$HLT_CUSTOM_PORTS_FILE" ]]; then
        grep -E '^[a-zA-Z0-9_-]+=' "$HLT_CUSTOM_PORTS_FILE" 2>/dev/null | grep -v '^#'
    fi
}

#──────────────────────────────────────────────────────────────────────────────
# Function: set_custom_port
# Description: Set or update a custom port in config file
# Arguments:
#   $1 - Service name
#   $2 - Port value
# Returns: 0 on success, 1 on error
# Globals: HLT_CUSTOM_PORTS_FILE
#──────────────────────────────────────────────────────────────────────────────
set_custom_port() {
    local service="$1"
    local port="$2"
    
    # Validate inputs
    if [[ -z "$service" || -z "$port" ]]; then
        return 1
    fi
    
    # Initialize if needed
    init_port_detection
    
    # Remove existing entry if present
    if grep -q "^${service}=" "$HLT_CUSTOM_PORTS_FILE" 2>/dev/null; then
        sed -i "/^${service}=/d" "$HLT_CUSTOM_PORTS_FILE"
    fi
    
    # Add new entry
    echo "${service}=${port}" >> "$HLT_CUSTOM_PORTS_FILE"
    return 0
}

#──────────────────────────────────────────────────────────────────────────────
# Function: remove_custom_port
# Description: Remove a custom port entry from config file
# Arguments:
#   $1 - Service name
# Returns: 0 on success, 1 if not found
# Globals: HLT_CUSTOM_PORTS_FILE
#──────────────────────────────────────────────────────────────────────────────
remove_custom_port() {
    local service="$1"
    
    if [[ -z "$service" ]]; then
        return 1
    fi
    
    if grep -q "^${service}=" "$HLT_CUSTOM_PORTS_FILE" 2>/dev/null; then
        sed -i "/^${service}=/d" "$HLT_CUSTOM_PORTS_FILE"
        return 0
    fi
    
    return 1
}
