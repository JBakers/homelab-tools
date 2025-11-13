#!/bin/bash
# PocketMine-MP Server MOTD

cat << 'EOF'
    ____             __        __  ____
   / __ \____  _____/ /_____  / /_/ __ \___ ___
  / /_/ / __ \/ ___/ //_/ _ \/ __/ / / / _ `__ \
 / ____/ /_/ / /__/ ,< /  __/ /_/ /_/ / / / / / /
/_/    \____/\___/_/|_|\___/\__/_____/_/ /_/ /_/
            __  _______
           /  |/  / __ \
          / /|_/ / /_/ /
         / /  / / ____/
        /_/  /_/_/

      Minecraft Bedrock Server
           by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  Server:      PocketMine-MP (Bedrock Edition)"
echo "  Port:        19132 (UDP)"
echo "=========================================="
echo ""
