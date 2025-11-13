#!/bin/bash
# AllSky Camera MOTD

cat << 'EOF'
    ___    ____   _____ __  __
   /   |  / / /  / ___// /__/ /
  / /| | / / /   \__ \/ //_/ / /
 / ___ |/ / /______/ / ,< / /_/
/_/  |_/_/_/_____/____/_/|_\__, /
                          /____/
      All-Sky Camera
       by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}')"
echo "=========================================="
echo ""
