#!/bin/bash
# Shared constants for Homelab Tools
# Source this file where common arrays/constants are needed
# Author: J.Bakers
# Version: See VERSION file

# Example: unsupported systems list for service detection (extend as needed)
declare -a UNSUPPORTED_SYSTEMS=(
    "hassio"    # Home Assistant OS (Docker-in-Docker detection unsupported)
    "alpine"    # Busybox variants lacking tools
)

export UNSUPPORTED_SYSTEMS