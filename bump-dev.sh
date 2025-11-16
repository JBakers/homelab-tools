#!/bin/bash
set -euo pipefail

# Bump development version (auto-increment build number)
# Usage: ./bump-dev.sh [commit message]

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# Get current version
CURRENT=$(grep -m1 "Version: " bin/homelab | sed 's/.*Version: //')

# Extract base version and build number
if [[ "$CURRENT" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-dev\.([0-9]+)$ ]]; then
    BASE="${BASH_REMATCH[1]}"
    BUILD="${BASH_REMATCH[2]}"
    NEW_BUILD=$((BUILD + 1))
elif [[ "$CURRENT" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-dev$ ]]; then
    BASE="${BASH_REMATCH[1]}"
    NEW_BUILD=1
elif [[ "$CURRENT" =~ ^([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    # Released version - start new dev cycle
    BASE="$CURRENT"
    NEW_BUILD=1
else
    echo -e "${RED}✗ Could not parse version: $CURRENT${RESET}"
    exit 1
fi

NEW_VERSION="${BASE}-dev.${NEW_BUILD}"

echo -e "${BOLD}${CYAN}Version Bump${RESET}"
echo -e "  Current: ${YELLOW}$CURRENT${RESET}"
echo -e "  New:     ${GREEN}$NEW_VERSION${RESET}"
echo ""

# Update all files with version
echo -e "${YELLOW}→${RESET} Updating version in all files..."
find bin -type f -exec sed -i "s/^# Version: .*/# Version: $NEW_VERSION/" {} \;
find . -maxdepth 1 -name "*.sh" -type f -exec sed -i "s/^# Version: .*/# Version: $NEW_VERSION/" {} \;

echo -e "${GREEN}✓${RESET} Version updated to ${CYAN}$NEW_VERSION${RESET}"
echo ""

# Git add and commit
if [[ $# -gt 0 ]]; then
    MSG="$*"
    echo -e "${YELLOW}→${RESET} Committing with message: ${CYAN}$MSG${RESET}"
    git add -A
    git commit -m "Version: $NEW_VERSION - $MSG"
    echo -e "${GREEN}✓${RESET} Committed!"
else
    echo -e "${YELLOW}→${RESET} Files updated, ready to commit"
    echo -e "  Run: ${GREEN}git add -A && git commit -m 'Version: $NEW_VERSION - your message'${RESET}"
fi
