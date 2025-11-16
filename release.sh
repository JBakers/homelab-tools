#!/bin/bash
set -euo pipefail

# Smart Release Tool - Combines version bumping with intelligent CHANGELOG generation
# Author: J.Bakers
# Version: 3.5.0-dev.5

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
# BLUE removed - using CYAN instead
BOLD='\033[1m'
RESET='\033[0m'

# Determine bump type
BUMP_TYPE="${1:-patch}"

# Validate bump type
case "$BUMP_TYPE" in
    major|minor|patch) ;;
    *)
        echo -e "${RED}✗ Error: Invalid bump type${RESET}"
        echo ""
        echo -e "${BOLD}Usage:${RESET}"
        echo -e "  ${GREEN}./release.sh [major|minor|patch]${RESET}"
        echo ""
        echo -e "${BOLD}Examples:${RESET}"
        echo -e "  ${GREEN}./release.sh patch${RESET}   # 3.4.0 → 3.4.1 (bug fixes)"
        echo -e "  ${GREEN}./release.sh minor${RESET}   # 3.4.0 → 3.5.0 (new features)"
        echo -e "  ${GREEN}./release.sh major${RESET}   # 3.4.0 → 4.0.0 (breaking changes)"
        echo ""
        exit 1
        ;;
esac

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         🚀 SMART RELEASE TOOL                             ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Get current version from git tags
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "3.4.0")

# Parse version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Calculate new version
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
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo -e "${BOLD}Bump type:${RESET}       ${YELLOW}$BUMP_TYPE${RESET}"
echo -e "${BOLD}Current version:${RESET}  ${CYAN}v$CURRENT_VERSION${RESET}"
echo -e "${BOLD}New version:${RESET}      ${GREEN}v$NEW_VERSION${RESET}"
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

# ============================================================================
# Step 1: Analyze Git Commits
# ============================================================================
echo -e "${YELLOW}[1/7]${RESET} Analyzing commits since v$CURRENT_VERSION..."

# Get commits since last tag
LAST_TAG="v$CURRENT_VERSION"
COMMITS=$(git log ${LAST_TAG}..HEAD --pretty=format:"%s|%h" 2>/dev/null || git log --pretty=format:"%s|%h" -10)

# Categorize commits
FEATURES=""
FIXES=""
DOCS=""
REFACTORS=""
SECURITY=""
OTHER=""

while IFS='|' read -r msg hash; do
    # Skip empty lines
    [[ -z "$msg" ]] && continue

    # Categorize based on conventional commit format or keywords
    if [[ "$msg" =~ ^[Ff]eat:|^[Aa]dd:|^[Ff]eature: ]] || echo "$msg" | grep -iq "add\|new feature"; then
        desc=$(echo "$msg" | sed -E 's/^[Ff]eat: ?|^[Aa]dd: ?|^[Ff]eature: ?//')
        FEATURES="${FEATURES}- ${desc} (${hash})\n"
    elif [[ "$msg" =~ ^[Ff]ix:|^[Bb]ug: ]] || echo "$msg" | grep -iq "fix\|bug"; then
        desc=$(echo "$msg" | sed -E 's/^[Ff]ix: ?|^[Bb]ug: ?//')
        FIXES="${FIXES}- ${desc} (${hash})\n"
    elif [[ "$msg" =~ ^[Ss]ec:|^[Ss]ecurity: ]] || echo "$msg" | grep -iq "security\|vulnerability"; then
        desc=$(echo "$msg" | sed -E 's/^[Ss]ec: ?|^[Ss]ecurity: ?//')
        SECURITY="${SECURITY}- ${desc} (${hash})\n"
    elif [[ "$msg" =~ ^[Dd]ocs?:|^[Dd]ocument ]] || echo "$msg" | grep -iq "docs\|documentation"; then
        desc=$(echo "$msg" | sed -E 's/^[Dd]ocs?: ?|^[Dd]ocument: ?//')
        DOCS="${DOCS}- ${desc} (${hash})\n"
    elif [[ "$msg" =~ ^[Rr]efactor: ]] || echo "$msg" | grep -iq "refactor\|cleanup"; then
        desc=$(echo "$msg" | sed -E 's/^[Rr]efactor: ?//')
        REFACTORS="${REFACTORS}- ${desc} (${hash})\n"
    else
        OTHER="${OTHER}- ${msg} (${hash})\n"
    fi
done <<< "$COMMITS"

# Count changes
TOTAL_COMMITS=$(echo "$COMMITS" | wc -l)
echo -e "${GREEN}  ✓${RESET} Analyzed $TOTAL_COMMITS commit(s)"
echo ""

# ============================================================================
# Step 2: Update Version Numbers
# ============================================================================
echo -e "${YELLOW}[2/7]${RESET} Update version numbers..."

# Update script headers
find . -type f \( -name "*.sh" -o -path "*/bin/*" \) \
    ! -path "./.git/*" \
    -exec sed -i "s/^# Version: [0-9]\+\.[0-9]\+\.[0-9]\+/# Version: $NEW_VERSION/g" {} \;

# Update README
sed -i "s/version-[0-9]\+\.[0-9]\+\.[0-9]\+-blue/version-$NEW_VERSION-blue/g" README.md
sed -i "s/# 🏠 Homelab Management Tools v[0-9]\+\.[0-9]\+\.[0-9]\+/# 🏠 Homelab Management Tools v$NEW_VERSION/g" README.md
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v$NEW_VERSION/g" bin/homelab

echo -e "${GREEN}  ✓${RESET} Updated version numbers"
echo ""

# ============================================================================
# Step 3: Generate CHANGELOG Entry
# ============================================================================
echo -e "${YELLOW}[3/7]${RESET} Generate CHANGELOG entry..."

# Build CHANGELOG content
CHANGELOG_ENTRY="## v$NEW_VERSION ($(date '+%d %B %Y'))\n\n"

# Add sections based on what we found
if [[ -n "$SECURITY" ]]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### 🔒 Security\n\n$(echo -e "$SECURITY")\n"
fi

if [[ -n "$FEATURES" ]]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### ✨ Features\n\n$(echo -e "$FEATURES")\n"
fi

if [[ -n "$FIXES" ]]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### 🐛 Bug Fixes\n\n$(echo -e "$FIXES")\n"
fi

if [[ -n "$REFACTORS" ]]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### ♻️ Refactoring\n\n$(echo -e "$REFACTORS")\n"
fi

if [[ -n "$DOCS" ]]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### 📝 Documentation\n\n$(echo -e "$DOCS")\n"
fi

if [[ -n "$OTHER" ]]; then
    CHANGELOG_ENTRY="${CHANGELOG_ENTRY}### 🔧 Other Changes\n\n$(echo -e "$OTHER")\n"
fi

CHANGELOG_ENTRY="${CHANGELOG_ENTRY}---\n\n"

# Insert into CHANGELOG.md (after title, line 2)
if ! grep -q "## v$NEW_VERSION" CHANGELOG.md; then
    # Create temp file with new entry
    echo -e "$CHANGELOG_ENTRY" > /tmp/changelog_entry.txt

    # Insert after line 1 (title)
    sed -i "2r /tmp/changelog_entry.txt" CHANGELOG.md

    echo -e "${GREEN}  ✓${RESET} Generated CHANGELOG entry"
else
    echo -e "${YELLOW}  →${RESET} Version already in CHANGELOG"
fi
echo ""

# ============================================================================
# Step 4: Create Release Notes
# ============================================================================
echo -e "${YELLOW}[4/7]${RESET} Create release notes..."

RELEASE_NOTES="RELEASE_NOTES_v$NEW_VERSION.md"
if [[ ! -f "$RELEASE_NOTES" ]]; then
    # Determine release emoji
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

EOF

    # Add auto-generated sections
    [[ -n "$SECURITY" ]] && echo -e "### 🔒 Security Improvements\n\n$(echo -e "$SECURITY")" >> "$RELEASE_NOTES"
    [[ -n "$FEATURES" ]] && echo -e "### ✨ New Features\n\n$(echo -e "$FEATURES")" >> "$RELEASE_NOTES"
    [[ -n "$FIXES" ]] && echo -e "### 🐛 Bug Fixes\n\n$(echo -e "$FIXES")" >> "$RELEASE_NOTES"

    cat >> "$RELEASE_NOTES" << EOF

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

# ============================================================================
# Step 5: Review Changes
# ============================================================================
echo -e "${YELLOW}[5/7]${RESET} Review changes..."
echo ""
echo -e "${BOLD}${CYAN}Generated CHANGELOG Preview:${RESET}"
echo -e "${CYAN}─────────────────────────────────────────────────────────${RESET}"
head -50 CHANGELOG.md | tail -n +2 | head -40
echo -e "${CYAN}─────────────────────────────────────────────────────────${RESET}"
echo ""

read -p "$(echo -e ${YELLOW}Edit CHANGELOG before committing? \(y/N\):${RESET} )" edit_changelog
if [[ "$edit_changelog" =~ ^[Yy]$ ]]; then
    ${EDITOR:-nano} CHANGELOG.md
fi
echo ""

# ============================================================================
# Step 6: Commit Changes
# ============================================================================
echo -e "${YELLOW}[6/7]${RESET} Stage and commit changes..."

git add -A
git commit -m "Release v$NEW_VERSION

Release type: $BUMP_TYPE
Previous version: v$CURRENT_VERSION

$(echo -e "$CHANGELOG_ENTRY" | sed 's/^#//' | sed 's/^/  /' | head -20)

🤖 Generated with Smart Release Tool
"

echo -e "${GREEN}  ✓${RESET} Created commit"
echo ""

# ============================================================================
# Step 7: Create Git Tag
# ============================================================================
echo -e "${YELLOW}[7/7]${RESET} Create git tag..."

git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION

$TYPE_DESC release

See RELEASE_NOTES_v$NEW_VERSION.md for details.
"

echo -e "${GREEN}  ✓${RESET} Created tag v$NEW_VERSION"
echo ""

# ============================================================================
# Summary
# ============================================================================
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║           ✅ RELEASE COMPLETE                         ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}Released:${RESET} ${GREEN}v$NEW_VERSION${RESET}"
echo ""
echo -e "${BOLD}Changes:${RESET}"
[[ -n "$SECURITY" ]] && echo -e "  🔒 Security:    $(echo -e "$SECURITY" | wc -l) fix(es)"
[[ -n "$FEATURES" ]] && echo -e "  ✨ Features:    $(echo -e "$FEATURES" | wc -l) addition(s)"
[[ -n "$FIXES" ]] && echo -e "  🐛 Bug Fixes:   $(echo -e "$FIXES" | wc -l) fix(es)"
echo ""
echo -e "${BOLD}${YELLOW}Next steps:${RESET}"
echo ""
echo -e "1. ${CYAN}Push to remote:${RESET}"
echo -e "   ${GREEN}git push origin main${RESET}"
echo ""
echo -e "2. ${CYAN}Push tags:${RESET}"
echo -e "   ${GREEN}git push origin v$NEW_VERSION${RESET}"
echo -e "   ${GREEN}# Or push all tags: git push --tags${RESET}"
echo ""
echo -e "3. ${CYAN}Create GitHub release:${RESET}"
echo -e "   ${GREEN}gh release create v$NEW_VERSION -F $RELEASE_NOTES${RESET}"
echo ""
