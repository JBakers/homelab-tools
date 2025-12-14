#!/bin/bash
set -euo pipefail

# Update version across all project files
# Author: J.Bakers

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

NEW_VERSION="$1"

if [[ -z "$NEW_VERSION" ]]; then
    echo -e "${RED}✗ Error: No version specified${RESET}"
    echo ""
    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  ${GREEN}./update-version.sh 3.4.0${RESET}"
    echo ""
    exit 1
fi

# Validate version format (X.Y.Z)
if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}✗ Error: Invalid version format${RESET}"
    echo -e "  Expected format: ${YELLOW}X.Y.Z${RESET} (e.g., 3.4.0)"
    echo -e "  You provided: ${YELLOW}$NEW_VERSION${RESET}"
    exit 1
fi

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         📝 VERSION UPDATE TOOL                            ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}Updating to version:${RESET} ${CYAN}v$NEW_VERSION${RESET}"
echo ""

# Get current version for comparison
CURRENT_VERSION=$(grep -m1 "Version: " bin/homelab | sed 's/.*Version: //')
echo -e "${YELLOW}Current version:${RESET} v$CURRENT_VERSION"
echo ""

if [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
    echo -e "${YELLOW}⚠ Warning: Version is already $NEW_VERSION${RESET}"
    read -p "Continue anyway? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✓ Cancelled${RESET}"
        exit 0
    fi
fi

echo -e "${YELLOW}[1/5]${RESET} Update script headers (Version: X.Y.Z)..."

# Update "Version: X.Y.Z" in all scripts
find . -type f \( -name "*.sh" -o -path "*/bin/*" \) \
    ! -path "./.git/*" \
    -exec sed -i "s/^# Version: [0-9]\+\.[0-9]\+\.[0-9]\+/# Version: $NEW_VERSION/g" {} \;
sed -i "s/^# Version: .*/# Version: $NEW_VERSION/" lib/menu-helpers.sh 2>/dev/null || true

# Update VERSION file
echo "$NEW_VERSION" > VERSION

echo -e "${GREEN}  ✓${RESET} Updated version headers"
echo ""

echo -e "${YELLOW}[2/5]${RESET} Update README.md..."

# Update README version badge and title
sed -i "s/version-[0-9]\+\.[0-9]\+\.[0-9]\+-blue/version-$NEW_VERSION-blue/g" README.md
sed -i "s/# 🏠 Homelab Management Tools v[0-9]\+\.[0-9]\+\.[0-9]\+/# 🏠 Homelab Management Tools v$NEW_VERSION/g" README.md
sed -i "s/HOMELAB MANAGEMENT TOOLS v[0-9]\+\.[0-9]\+\.[0-9]\+/HOMELAB MANAGEMENT TOOLS v$NEW_VERSION/g" README.md

echo -e "${GREEN}  ✓${RESET} Updated README.md"
echo ""

echo -e "${YELLOW}[3/5]${RESET} Update CHANGELOG.md..."

# Add new version section to CHANGELOG if it doesn't exist
if ! grep -q "## v$NEW_VERSION" CHANGELOG.md; then
    # Create new entry at top (after title)
    sed -i "2i\\
## v$NEW_VERSION ($(date '+%d %B %Y'))\\
\\
### Changes\\
\\
- TBD: Add your changes here\\
\\
---\\
" CHANGELOG.md
    echo -e "${GREEN}  ✓${RESET} Added new version section to CHANGELOG"
else
    echo -e "${YELLOW}  →${RESET} Version section already exists in CHANGELOG"
fi
echo ""

echo -e "${YELLOW}[4/5]${RESET} Create/update release notes..."

# Create or update release notes
RELEASE_NOTES="RELEASE_NOTES_v$NEW_VERSION.md"
if [[ ! -f "$RELEASE_NOTES" ]]; then
    cat > "$RELEASE_NOTES" << EOF
# 🚀 Homelab Tools v$NEW_VERSION Release Notes

**Release Date:** $(date '+%d %B %Y')
**Author:** J.Bakers
**Type:** TBD

---

## 🚀 What's New

### TBD

TODO: Add release notes here

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
    echo -e "${YELLOW}  →${RESET} $RELEASE_NOTES already exists"
fi
echo ""

echo -e "${YELLOW}[5/5]${RESET} Verify changes..."

# Count updated files
UPDATED_COUNT=$(git diff --name-only | wc -l)

echo -e "${GREEN}  ✓${RESET} Updated $UPDATED_COUNT file(s)"
echo ""

# Show summary
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║           ✅ VERSION UPDATE COMPLETE                  ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}Updated to:${RESET} ${CYAN}v$NEW_VERSION${RESET}"
echo ""
echo -e "${BOLD}${YELLOW}Next steps:${RESET}"
echo ""
echo -e "1. ${CYAN}Review changes:${RESET}"
echo -e "   ${GREEN}git diff${RESET}"
echo ""
echo -e "2. ${CYAN}Update CHANGELOG.md:${RESET}"
echo -e "   ${GREEN}nano CHANGELOG.md${RESET}"
echo ""
echo -e "3. ${CYAN}Update release notes:${RESET}"
echo -e "   ${GREEN}nano $RELEASE_NOTES${RESET}"
echo ""
echo -e "4. ${CYAN}Commit changes:${RESET}"
echo -e "   ${GREEN}git add -A${RESET}"
echo -e "   ${GREEN}git commit -m \"Release v$NEW_VERSION\"${RESET}"
echo ""
echo -e "5. ${CYAN}Create git tag:${RESET}"
echo -e "   ${GREEN}git tag -a v$NEW_VERSION -m \"Release v$NEW_VERSION\"${RESET}"
echo ""
