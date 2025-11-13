#!/bin/bash
# Prowlarr MOTD

cat << 'EOF'
    ____                   __
   / __ \_________  _      _/ /___ ___________
  / /_/ / ___/ __ \| | /| / / / __ `/ ___/ ___/
 / ____/ /  / /_/ /| |/ |/ / / /_/ / /  / /
/_/   /_/   \____/ |__/|__/_/\__,_/_/  /_/

        Indexer Manager
          by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):9696"
echo "=========================================="
echo ""
