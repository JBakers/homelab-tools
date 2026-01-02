#!/bin/bash
# lib/colors.sh - Centralized color definitions
# Usage: source "$LIB_DIR/colors.sh"

# ANSI color codes
readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

# Export for use in subshells
export CYAN GREEN YELLOW RED BOLD DIM RESET
