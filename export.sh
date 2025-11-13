#!/bin/bash
# Export homelab tools naar een archief

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="homelab-tools_${TIMESTAMP}.tar.gz"

echo "Exporteren naar $ARCHIVE_NAME..."

cd ~
tar -czf "$ARCHIVE_NAME" \
    --exclude='homelab-tools/.git' \
    --exclude='homelab-tools/*.tar.gz' \
    homelab-tools/

echo "✓ Klaar: ~/$ARCHIVE_NAME"
echo ""
echo "Kopieer dit archief naar een nieuwe machine en pak uit met:"
echo "  tar -xzf $ARCHIVE_NAME"
echo "  cd homelab-tools/install"
echo "  ./install.sh"
