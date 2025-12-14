#!/bin/bash
# Centralized version management for Homelab Tools
# All scripts should source this file to get the version
# Author: J.Bakers

# Find VERSION file location
_find_version_file() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd)"
    
    # Check relative to script location (development)
    if [[ -f "${script_dir}/../VERSION" ]]; then
        echo "${script_dir}/../VERSION"
    elif [[ -f "${script_dir}/VERSION" ]]; then
        echo "${script_dir}/VERSION"
    # Check installed location
    elif [[ -f "/opt/homelab-tools/VERSION" ]]; then
        echo "/opt/homelab-tools/VERSION"
    # Fallback to home directory
    elif [[ -f "$HOME/homelab-tools/VERSION" ]]; then
        echo "$HOME/homelab-tools/VERSION"
    else
        echo ""
    fi
}

# Get version from VERSION file
get_version() {
    local version_file
    version_file="$(_find_version_file)"
    
    if [[ -n "$version_file" && -f "$version_file" ]]; then
        cat "$version_file"
    else
        echo "unknown"
    fi
}

# Get version with 'v' prefix for display
get_version_display() {
    echo "v$(get_version)"
}

# Export version as variable for easy access
HLT_VERSION="$(get_version)"
HLT_VERSION_DISPLAY="$(get_version_display)"

# Export functions
export -f get_version
export -f get_version_display
export HLT_VERSION
export HLT_VERSION_DISPLAY
