#!/bin/bash
# Minecraft Server MOTD

cat << 'EOF'
   __  ____                            ______
  /  |/  (_)___  ___  _______________ _/ __/ /_
 / /|_/ / / __ \/ _ \/ ___/ ___/ __ `/ /_/ __/
/ /  / / / / / /  __/ /__/ /  / /_/ / __/ /_
/_/  /_/_/_/ /_/\___/\___/_/   \__,_/_/  \__/

         Game Server
         by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Server Port: 25565"
echo "=========================================="
echo ""
