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

# SSH Configuration Constants
readonly SSH_CONNECT_TIMEOUT=5          # Seconds before SSH connection times out
readonly SSH_BATCH_MODE=yes             # Disable interactive prompts
readonly SSH_CONNECT_OPTS=(
    -o ConnectTimeout=$SSH_CONNECT_TIMEOUT
    -o BatchMode=$SSH_BATCH_MODE
)

# Timeouts (seconds)
readonly TEST_TIMEOUT_SHORT=5           # For quick operations
readonly TEST_TIMEOUT_MEDIUM=30         # For medium operations
readonly TEST_TIMEOUT_LONG=60           # For long operations

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