#!/bin/bash
# Shared constants for Homelab Tools
# Source this file where common arrays/constants are needed
# Author: J.Bakers
# Version: See VERSION file

# Exit codes (standard convention)
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_USER_CANCEL=2
readonly EXIT_INVALID_INPUT=3
readonly EXIT_FILE_NOT_FOUND=4
readonly EXIT_PERMISSION_DENIED=5
readonly EXIT_SSH_ERROR=6

# Systems that don't support MOTD (appliances, Docker, non-Linux, etc.)
declare -a UNSUPPORTED_SYSTEMS=(
    "homeassistant" "hass" "ha"           # Home Assistant (Docker)
    "truenas"                              # TrueNAS (FreeBSD appliance)
    "pfsense" "opnsense"                   # Firewall appliances
    "windows" "win"                        # Windows systems
    "unraid"                               # Unraid (different MOTD)
    "synology" "nas"                       # Synology NAS
    "qnap"                                 # QNAP NAS
)

export UNSUPPORTED_SYSTEMS EXIT_SUCCESS EXIT_ERROR EXIT_USER_CANCEL EXIT_INVALID_INPUT EXIT_FILE_NOT_FOUND EXIT_PERMISSION_DENIED EXIT_SSH_ERROR