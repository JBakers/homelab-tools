#!/bin/bash
# Sonarr MOTD

cat << 'EOF'
   _____
  / ___/____  ____  ____ ___________
  \__ \/ __ \/ __ \/ __ `/ ___/ ___/
 ___/ / /_/ / / / / /_/ / /  / /
/____/\____/_/ /_/\__,_/_/  /_/

     TV Series Manager
       by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):8989"
echo "=========================================="
echo ""
