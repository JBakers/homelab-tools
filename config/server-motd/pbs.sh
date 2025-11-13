#!/bin/bash
# PBS MOTD

cat << 'ASCIIEOF'
   === PBS ===

     PVE Backup Server
       by J.Bakers

ASCIIEOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "=========================================="
echo ""
