#!/bin/bash
# Radarr MOTD

cat << 'EOF'
    ____            __
   / __ \____ _____/ /___ ___  _____
  / /_/ / __ `/ __  / __ `/ / / / ___/
 / _, _/ /_/ / /_/ / /_/ / /_/ / /
/_/ |_|\__,_/\__,_/\__,_/\__,_/_/

     Movie Collection Manager
           by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):7878"
echo "=========================================="
echo ""
