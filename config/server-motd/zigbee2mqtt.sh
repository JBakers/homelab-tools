#!/bin/bash
# Zigbee2MQTT MOTD

cat << 'EOF'
   _______ __                ___
  /_  __/(_)___ _/ /_  ___  ___    |__ \
   / / / / __ `/ __ \/ _ \/ _ \   __/ /
  / /_/ / /_/ / /_/ /  __/  __/  / __/
  \__,_/_/\__, /_.___/\___/\___/  /____/
   __  __/____/  ______
  /  |/  / __ \/_  __/
 / /|_/ / / / / / /
/ /  / / /_/ / / /
/_/  /_/\___\_\/_/

  Zigbee to MQTT Bridge
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
