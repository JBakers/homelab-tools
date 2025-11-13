#!/bin/bash
# Docker Debian Server MOTD

cat << 'EOF'
    ____             __
   / __ \____  _____/ /_____  _____
  / / / / __ \/ ___/ //_/ _ \/ ___/
 / /_/ / /_/ / /__/ ,< /  __/ /
/_____/\____/\___/_/|_|\___/_/
    ____       __    _
   / __ \___  / /_  (_)___ _____
  / / / / _ \/ __ \/ / __ `/ __ \
 / /_/ /  __/ /_/ / / /_/ / / / /
/_____/\___/_.___/_/\__,_/_/ /_/

    Container Platform
       by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
if command -v docker &> /dev/null; then
    echo "  Docker:      $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')"
    echo "  Containers:  $(docker ps -q 2>/dev/null | wc -l) running"
fi
echo "=========================================="
echo ""
