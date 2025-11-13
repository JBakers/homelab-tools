#!/bin/bash
# Generic Server MOTD

cat << 'EOF'
   _____
  / ___/___  ______   _____  _____
  \__ \/ _ \/ ___/ | / / _ \/ ___/
 ___/ /  __/ /   | |/ /  __/ /
/____/\___/_/    |___/\___/_/

      by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
if [ -f /etc/os-release ]; then
    echo "  OS:          $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
fi
echo "=========================================="
echo ""
