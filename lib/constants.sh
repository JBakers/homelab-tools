#!/bin/bash
# Shared constants for Homelab Tools
# Source this file where common arrays/constants are needed
# Author: J.Bakers
# Version: See VERSION file

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

export UNSUPPORTED_SYSTEMS