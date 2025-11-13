#!/bin/bash
# SABnzbd MOTD

cat << 'EOF'
   _____   ___    ____             __    __
  / ___/  /   |  / __ )____  _____/ /_  / /
  \__ \  / /| | / __  / __ \/_  / __ \/ __ \
 ___/ / / ___ |/ /_/ / / / / / /_/ /_/ /_/ /
/____/ /_/  |_/_____/_/ /_/ /___/_.___/_.___/

         Usenet Downloader
           by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):8080"
echo "=========================================="
echo ""
