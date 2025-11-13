#!/bin/bash
# Test Server MOTD

cat << 'EOF'
   ______          __     _____
  /_  __/__  _____/ /_   / ___/___  ______   _____  _____
   / / / _ \/ ___/ __/   \__ \/ _ \/ ___/ | / / _ \/ ___/
  / / /  __(__  ) /_    ___/ /  __/ /   | |/ /  __/ /
 /_/  \___/____/\__/   /____/\___/_/    |___/\___/_/

         Development & Testing
              by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "=========================================="
echo ""
