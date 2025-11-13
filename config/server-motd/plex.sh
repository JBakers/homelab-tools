#!/bin/bash
# Plex Media Server MOTD

cat << 'EOF'
    ____  __
   / __ \/ /__  _  __
  / /_/ / / _ \| |/_/
 / ____/ /  __/>  <
/_/   /_/\___/_/|_|

   Media Server
   by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):32400/web"
echo "=========================================="
echo ""
