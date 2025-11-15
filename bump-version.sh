#!/bin/bash
set -euo pipefail

# Automatic version bumping with git tags
# Author: J.Bakers

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# Get current version from git tags
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "3.3.0")

# Parse version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Determine bump type
BUMP_TYPE="${1:-patch}"

case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo -e "${RED}✗ Error: Invalid bump type${RESET}"
        echo ""
        echo -e "${BOLD}Usage:${RESET}"
        echo -e "  ${GREEN}./bump-version.sh [major|minor|patch]${RESET}"
        echo ""
        echo -e "${BOLD}Examples:${RESET}"
        echo -e "  ${GREEN}./bump-version.sh patch${RESET}   # 3.3.0 → 3.3.1 (bug fixes)"
        echo -e "  ${GREEN}./bump-version.sh minor${RESET}   # 3.3.0 → 3.4.0 (new features)"
        echo -e "  ${GREEN}./bump-version.sh major${RESET}   # 3.3.0 → 4.0.0 (breaking changes)"
        echo ""
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         🚀 AUTOMATIC VERSION BUMP                     ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}Bump type:${RESET}      ${YELLOW}$BUMP_TYPE${RESET}"
echo -e "${BOLD}Current version:${RESET} ${CYAN}v$CURRENT_VERSION${RESET}"
echo -e "${BOLD}New version:${RESET}     ${GREEN}v$NEW_VERSION${RESET}"
echo ""

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${YELLOW}⚠ Warning: You have uncommitted changes${RESET}"
    git status --short
    echo ""
    read -p "Continue anyway? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✓ Cancelled${RESET}"
        exit 0
    fi
    echo ""
fi

echo -e "${YELLOW}[1/6]${RESET} Update script headers..."
find . -type f \( -name "*.sh" -o -path "*/bin/*" \) \
    ! -path "./.git/*" \
    -exec sed -i "s/^# Version: [0-9]\+\.[0-9]\+\.[0-9]\+/# Version: $NEW_VERSION/g" {} \;
echo -e "${GREEN}  ✓${RESET} Updated version headers"
echo ""

echo -e "${YELLOW}[2/6]${RESET} Update README.md..."
sed -i "s/version-[0-9]\+\.[0-9]\+\.[0-9]\+-blue/version-$NEW_VERSION-blue/g" README.md
sed -i "s/# 🏠 Homelab Management Tools v[0-9]\+\.[0-9]\+\.[0-9]\+/# 🏠 Homelab Management Tools v$NEW_VERSION/g" README.md
sed -i "s/HOMELAB MANAGEMENT TOOLS v[0-9]\+\.[0-9]\+\.[0-9]\+/HOMELAB MANAGEMENT TOOLS v$NEW_VERSION/g" README.md
echo -e "${GREEN}  ✓${RESET} Updated README.md"
echo ""

echo -e "${YELLOW}[3/6]${RESET} Update CHANGELOG.md..."
if ! grep -q "## v$NEW_VERSION" CHANGELOG.md; then
    sed -i "2i\\
## v$NEW_VERSION ($(date '+%d %B %Y'))\\
\\
### Changes\\
\\
- Version bump: $BUMP_TYPE release\\
- TODO: Add detailed changes here\\
\\
---\\
" CHANGELOG.md
    echo -e "${GREEN}  ✓${RESET} Added new version section"
else
    echo -e "${YELLOW}  →${RESET} Version already in CHANGELOG"
fi
echo ""

echo -e "${YELLOW}[4/6]${RESET} Create release notes..."
RELEASE_NOTES="RELEASE_NOTES_v$NEW_VERSION.md"
if [[ ! -f "$RELEASE_NOTES" ]]; then
    # Determine release type emoji
    case "$BUMP_TYPE" in
        major) TYPE_EMOJI="💥"; TYPE_DESC="Breaking Changes" ;;
        minor) TYPE_EMOJI="✨"; TYPE_DESC="New Features" ;;
        patch) TYPE_EMOJI="🐛"; TYPE_DESC="Bug Fixes" ;;
    esac

    cat > "$RELEASE_NOTES" << EOF
# $TYPE_EMOJI Homelab Tools v$NEW_VERSION Release Notes

**Release Date:** $(date '+%d %B %Y')
**Author:** J.Bakers
**Type:** $TYPE_DESC (v$CURRENT_VERSION → v$NEW_VERSION)

---

## 🚀 What's New

### TODO: Add changes here

---

## 🔧 Upgrade Instructions

### From v$CURRENT_VERSION or earlier

\`\`\`bash
cd ~/homelab-tools
git pull
sudo ./install.sh
source ~/.bashrc
\`\`\`

### Fresh Install

\`\`\`bash
cd ~
git clone https://github.com/JBakers/homelab-tools.git
cd homelab-tools
sudo ./install.sh
source ~/.bashrc
\`\`\`

---

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed changes.

---

Made with ❤️ by [J.Bakers](https://github.com/JBakers)
EOF
    echo -e "${GREEN}  ✓${RESET} Created $RELEASE_NOTES"
else
    echo -e "${YELLOW}  →${RESET} Release notes already exist"
fi
echo ""

echo -e "${YELLOW}[5/6]${RESET} Stage changes..."
git add -A
echo -e "${GREEN}  ✓${RESET} Staged all changes"
echo ""

echo -e "${YELLOW}[6/6]${RESET} Create commit and tag..."
git commit -m "chore: Bump version to v$NEW_VERSION

Release type: $BUMP_TYPE
Previous version: v$CURRENT_VERSION

🤖 Generated with [Claude Code](https://claude.com/claude-code)
"
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
echo -e "${GREEN}  ✓${RESET} Created commit and git tag"
echo ""

# Summary
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║           ✅ VERSION BUMP COMPLETE                   ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}Released:${RESET} ${GREEN}v$NEW_VERSION${RESET}"
echo ""
echo -e "${BOLD}${YELLOW}Next steps:${RESET}"
echo ""
echo -e "1. ${CYAN}Edit release notes:${RESET}"
echo -e "   ${GREEN}nano $RELEASE_NOTES${RESET}"
echo ""
echo -e "2. ${CYAN}Edit CHANGELOG:${RESET}"
echo -e "   ${GREEN}nano CHANGELOG.md${RESET}"
echo ""
echo -e "3. ${CYAN}Amend commit if needed:${RESET}"
echo -e "   ${GREEN}git add -A && git commit --amend${RESET}"
echo ""
echo -e "4. ${CYAN}Push to remote:${RESET}"
echo -e "   ${GREEN}git push && git push --tags${RESET}"
echo ""
echo -e "5. ${CYAN}Create GitHub release:${RESET}"
echo -e "   ${GREEN}gh release create v$NEW_VERSION -F $RELEASE_NOTES${RESET}"
echo ""
