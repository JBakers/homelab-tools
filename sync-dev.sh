#!/bin/bash
# Quick sync from workspace to /opt for testing
# Author: J.Bakers

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="/opt/homelab-tools"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║  🔄 Sync Dev → /opt                                      ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Check if running from workspace
if [[ ! -f "$SOURCE_DIR/.dev-workspace" ]]; then
    echo -e "${YELLOW}⚠  Not in dev workspace, creating marker...${RESET}"
    echo "# Dev workspace marker" > "$SOURCE_DIR/.dev-workspace"
fi

# Check if target exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo -e "${RED}✗ /opt/homelab-tools not found${RESET}"
    echo -e "  Run: ${CYAN}./install.sh${RESET} first"
    exit 1
fi

# Show what will be synced
echo -e "${YELLOW}Source:${RESET} $SOURCE_DIR"
echo -e "${YELLOW}Target:${RESET} $TARGET_DIR"
echo ""

# Sync files (excluding dev files)
echo -e "${CYAN}→${RESET} Syncing files..."
sudo rsync -av --delete \
    --exclude='.git' \
    --exclude='.gitignore' \
    --exclude='.dev-workspace' \
    --exclude='*.backup.*' \
    --exclude='.test-env' \
    --exclude='TEST_*.txt' \
    --exclude='test-runner.sh' \
    --exclude='sync-dev.sh' \
    "$SOURCE_DIR/" "$TARGET_DIR/"

# Fix permissions
echo -e "${CYAN}→${RESET} Fixing permissions..."
sudo chmod +x "$TARGET_DIR"/bin/* 2>/dev/null
sudo chmod +x "$TARGET_DIR"/*.sh 2>/dev/null
sudo chmod 755 "$TARGET_DIR"/lib/* 2>/dev/null

echo ""
echo -e "${GREEN}✓ Synced successfully!${RESET}"
echo ""
echo -e "${YELLOW}Test your changes:${RESET}"
echo -e "  ${CYAN}homelab${RESET}"
echo -e "  ${CYAN}edit-hosts${RESET}"
echo -e "  ${CYAN}generate-motd${RESET}"
echo ""
