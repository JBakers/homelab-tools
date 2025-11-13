#!/bin/bash
# EMQX MQTT Broker MOTD

cat << 'EOF'
   ________  _____ _    __
  / ____/  |/  / __ \  / /
 / __/ / /|_/ / / / / / /
/ /___/ /  / / /_/ / /_/
\____/_/  /_/\___\_\(_)

    MQTT Broker
    by J.Bakers

EOF

echo "=========================================="
echo "System Information:"
echo "  Hostname:    $(hostname)"
echo "  IP Address:  $(hostname -I | awk '{print $1}')"
echo "  Uptime:      $(uptime -p)"
echo "  MQTT Port:   1883"
echo "  Web UI:      http://$(hostname -I | awk '{print $1}'):18083"
echo "=========================================="
echo ""
