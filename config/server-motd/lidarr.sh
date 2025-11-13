#!/bin/bash
# Lidarr MOTD

cat << 'EOF'
    __    _     __
   / /   (_)___/ /___ ___________
  / /   / / __  / __ `/ ___/ ___/
 / /___/ / /_/ / /_/ / /  / /
/_____/_/\__,_/\__,_/_/  /_/

     Music Collection Manager
           by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):8686"
echo "=========================================="
echo ""
