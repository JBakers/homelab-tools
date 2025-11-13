#!/bin/bash
# Proxmox MOTD

cat << 'EOF'
    ____
   / __ \_________  _  ______ ___  ____  _  __
  / /_/ / ___/ __ \| |/_/ __ `__ \/ __ \| |/_/
 / ____/ /  / /_/ />  </ / / / / / /_/ />  <
/_/   /_/   \____/_/|_/_/ /_/ /_/\____/_/|_|

       Hypervisor & Virtualization Platform
                   by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
if command -v pveversion &> /dev/null; then
    echo "  PVE Version: $(pveversion | head -n1)"
fi
echo "  Uptime:      $(uptime -p)"
echo "=========================================="
echo ""
