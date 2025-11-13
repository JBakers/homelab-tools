#!/bin/bash
# Frigate NVR MOTD

cat << 'EOF'
    ______     _            __
   / ____/____(_)___ _____ _/ /____
  / /_  / ___/ / __ `/ __ `/ __/ _ \
 / __/ / /  / / /_/ / /_/ / /_/  __/
/_/   /_/  /_/\__, /\__,_/\__/\___/
             /____/
       Network Video Recorder
            by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
if command -v docker &> /dev/null; then
    echo "  Docker:      $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')"
fi
echo "=========================================="
echo ""
