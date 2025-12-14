#!/bin/bash
set -euo pipefail

# Export homelab tools to an archive
# Author: J.Bakers
# Version: 3.6.0-dev.13

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="homelab-tools_${TIMESTAMP}.tar.gz"

echo "Exporting to $ARCHIVE_NAME..."

cd ~
tar -czf "$ARCHIVE_NAME" \
    --exclude='homelab-tools/.git' \
    --exclude='homelab-tools/*.tar.gz' \
    homelab-tools/

echo "✓ Done: ~/$ARCHIVE_NAME"
echo ""
echo "Copy this archive to a new machine and extract with:"
echo "  tar -xzf $ARCHIVE_NAME"
echo "  cd homelab-tools"
echo "  ./install.sh"
