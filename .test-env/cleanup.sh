#!/bin/bash
set -euo pipefail

# Cleanup test environment - removes all Docker containers and images

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up test environment..."

cd "$SCRIPT_DIR"

# Stop and remove containers
docker-compose down --rmi local --volumes 2>/dev/null || true

# Remove any orphaned containers
docker rm -f hlt-testhost hlt-mock-pihole hlt-mock-docker hlt-mock-proxmox 2>/dev/null || true

# Clean results
rm -rf "$SCRIPT_DIR/results/logs/"*
rm -f "$SCRIPT_DIR/results/test-report.txt"

echo "✓ Test environment cleaned"
