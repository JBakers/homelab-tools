#!/bin/bash
# Uptime Kuma MOTD

cat << 'EOF'
   __  __      __  _
  / / / /___  / /_(_)___ ___  ___
 / / / / __ \/ __/ / __ `__ \/ _ \
/ /_/ / /_/ / /_/ / / / / / /  __/
\____/ .___/\__/_/_/ /_/ /_/\___/
    /_/   __ __
   / /__ / / / _____ ___  ____ _
  / //_// / / / __ `__ \/ __ `/
 / ,<  / /_/ / / / / / / /_/ /
/_/|_| \____/_/ /_/ /_/\__,_/

    Monitoring Dashboard
        by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):3001"
echo "=========================================="
echo ""
