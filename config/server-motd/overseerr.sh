#!/bin/bash
# Overseerr MOTD

cat << 'EOF'
   ____
  / __ \   _____  ____________  ___  _____
 / / / / | / / _ \/ ___/ ___/ _ \/ _ \/ ___/
/ /_/ /| |/ /  __/ /  (__  )  __/  __/ /
\____/ |___/\___/_/  /____/\___/\___/_/

     Media Request Management
            by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):5055"
echo "=========================================="
echo ""
