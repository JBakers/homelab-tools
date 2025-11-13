#!/bin/bash
# Tautulli MOTD

cat << 'EOF'
   ______            __        __   __
  /_  __/___ ___  __/ /___  __/ /  / (_)
   / / / __ `/ / / / __/ / / / /  / / /
  / / / /_/ / /_/ / /_/ /_/ / /  / / /
 /_/  \__,_/\__,_/\__/\__,_/_/  /_/_/

       Plex Monitoring & Stats
            by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):8181"
echo "=========================================="
echo ""
