#!/bin/bash
# Pi-hole MOTD

cat << 'EOF'
    ____  _       __          __
   / __ \(_)     / /_  ____  / /__
  / /_/ / /_____/ __ \/ __ \/ / _ \
 / ____/ /_____/ / / / /_/ / /  __/
/_/   /_/     /_/ /_/\____/_/\___/

      Network-wide Ad Blocking
            by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
if command -v pihole &> /dev/null; then
    echo "  Pi-hole:     $(pihole -v 2>/dev/null | grep 'Pi-hole' | awk '{print $3}')"
fi
echo "=========================================="
echo ""
