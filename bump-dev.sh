#!/bin/bash
set -euo pipefail

# Bump development version (auto-increment build number)
# Usage: ./bump-dev.sh [commit message]
#
# CENTRALIZED VERSION MANAGEMENT:
# - VERSION file is the single source of truth
# - All scripts read from VERSION via lib/version.sh
# - This script ONLY updates the VERSION file

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# Get current version from VERSION file (single source of truth)
if [[ ! -f VERSION ]]; then
    echo -e "${RED}✗ VERSION file not found${RESET}"
    exit 1
fi

CURRENT=$(cat VERSION)

# Extract base version and build number
if [[ "$CURRENT" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)-dev\.([0-9]+)$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
    BUILD="${BASH_REMATCH[4]}"
    
    # Strip leading zeros to avoid octal interpretation
    BUILD=$((10#$BUILD))
    
    # Check if we've reached dev.09 - time to bump minor version
    if [[ $BUILD -ge 9 ]]; then
        # Bump patch version and reset to dev.00
        NEW_PATCH=$((PATCH + 1))
        BASE="${MAJOR}.${MINOR}.${NEW_PATCH}"
        NEW_BUILD=0
        echo -e "${YELLOW}→${RESET} Reached dev.09 limit, bumping to ${BASE}-dev.00"
    else
        BASE="${MAJOR}.${MINOR}.${PATCH}"
        NEW_BUILD=$((BUILD + 1))
    fi
elif [[ "$CURRENT" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)-dev$ ]]; then
    BASE="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
    NEW_BUILD=1
elif [[ "$CURRENT" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    # Released version - start new dev cycle
    BASE="$CURRENT"
    NEW_BUILD=1
else
    echo -e "${RED}✗ Could not parse version: $CURRENT${RESET}"
    exit 1
fi

NEW_VERSION="${BASE}-dev.$(printf "%02d" $NEW_BUILD)"

echo -e "${BOLD}${CYAN}Version Bump${RESET}"
echo -e "  Current: ${YELLOW}$CURRENT${RESET}"
echo -e "  New:     ${GREEN}$NEW_VERSION${RESET}"
echo ""

# Update VERSION file (single source of truth)
echo -e "${YELLOW}→${RESET} Updating VERSION file..."
echo "$NEW_VERSION" > VERSION

echo -e "${GREEN}✓${RESET} Version updated to ${CYAN}$NEW_VERSION${RESET}"
echo ""

# Git add and commit
if [[ $# -gt 0 ]]; then
    MSG="$*"
    echo -e "${YELLOW}→${RESET} Committing with message: ${CYAN}$MSG${RESET}"
    git add -A
    git commit -m "$MSG"
    echo -e "${GREEN}✓${RESET} Committed!"
    echo -e "${GREEN}✓${RESET} Version: $NEW_VERSION"
else
    echo -e "${YELLOW}→${RESET} Ready to commit"
    echo -e "  Version updated to: ${CYAN}$NEW_VERSION${RESET}"
    echo -e "  Run: ${GREEN}git add -A && git commit -m 'type: your message'${RESET}"
fi
