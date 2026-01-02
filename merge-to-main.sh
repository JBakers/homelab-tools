#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# MERGE TO MAIN - Clean release workflow
# Merges develop to main, excluding development-only files
# ═══════════════════════════════════════════════════════════════════════════════

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         🚀 MERGE TO MAIN                                  ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Verify we're on develop
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "develop" ]]; then
    echo -e "${RED}Error: Must be on 'develop' branch${RESET}"
    echo "Current branch: $CURRENT_BRANCH"
    echo "Run: git checkout develop"
    exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${RED}Error: Uncommitted changes detected${RESET}"
    echo "Commit or stash changes before merging."
    git status --short
    exit 1
fi

# Get version
VERSION=$(cat VERSION 2>/dev/null || echo "unknown")
echo -e "${BOLD}Version:${RESET} $VERSION"
echo ""

# Files that should NOT go to main (development only)
DEV_ONLY_FILES=(
    "bump-dev.sh"
    "release.sh"
    "TESTING_CHECKLIST.md"
    "TEST_SUMMARY.txt"
    "TESTING_GUIDE.md"
    ".claude/"
)

echo -e "${YELLOW}Pre-merge checklist:${RESET}"
echo "  1. All tests passed?"
echo "  2. CHANGELOG.md updated?"
echo "  3. VERSION is release version (not -dev)?"
echo ""

# Check if version is still -dev
if [[ "$VERSION" == *"-dev"* ]]; then
    echo -e "${YELLOW}Warning: VERSION contains '-dev'${RESET}"
    echo "For production release, remove '-dev' suffix first."
    echo ""
    read -p "Continue anyway? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo -e "${BOLD}Ready to merge develop → main${RESET}"
read -p "Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${YELLOW}[1/4]${RESET} Fetching latest main..."
git fetch origin main

echo -e "${YELLOW}[2/4]${RESET} Switching to main..."
git checkout main
git pull origin main

echo -e "${YELLOW}[3/4]${RESET} Merging develop into main..."
git merge develop -m "Release: $VERSION"

echo -e "${YELLOW}[4/4]${RESET} Removing dev-only files from main..."
for file in "${DEV_ONLY_FILES[@]}"; do
    if [[ -e "$file" ]]; then
        git rm -rf "$file" 2>/dev/null || true
        echo "  Removed: $file"
    fi
done

# Commit the removals if any
if [[ -n $(git status --porcelain) ]]; then
    git add -A
    git commit -m "chore: remove dev-only files from main"
fi

echo ""
echo -e "${GREEN}✓ Merge complete!${RESET}"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo "  1. Review changes: git log --oneline -5"
echo "  2. Push to remote: git push origin main"
echo "  3. Create GitHub release: v$VERSION"
echo "  4. Switch back: git checkout develop"
echo ""
echo -e "${YELLOW}Don't forget to tag the release:${RESET}"
echo "  git tag -a v$VERSION -m 'Release $VERSION'"
echo "  git push origin v$VERSION"
