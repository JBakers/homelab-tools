#!/bin/bash
# PowerNukkitX Server MOTD

cat << 'EOF'
    ____                        _   __      __    __   _ __  __
   / __ \____ _      _____  ____/ | / /_  __/ /__ / /__(_) /_| |/ /
  / /_/ / __ \ | /| / / _ \/ ___/  |/ / / / / /_/ / //_/ / __/>  <
 / ____/ /_/ / |/ |/ /  __/ /  / /|  / /_/ / /_/ / ,< / / /_/ /| |
/_/    \____/|__/|__/\___/_/  /_/ |_/\__,_/\__,_/_/|_/_/\__/_/ |_|

           Minecraft Bedrock Server
                by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Server:      PowerNukkitX (Bedrock Edition)"
echo "  Port:        19132 (UDP)"
echo "=========================================="
echo ""
