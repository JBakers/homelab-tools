#!/bin/bash
# Test service auto-detection for all 60+ presets
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

pass() {
    echo -e "  ${GREEN}[PASS]${RESET} $1"
    ((PASS_COUNT++)) || true
}

fail() {
    echo -e "  ${RED}[FAIL]${RESET} $1"
    ((FAIL_COUNT++)) || true
}

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}  Service Preset Auto-Detection Test Suite${RESET}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# Test function: generate MOTD and check expected values
test_service() {
    local service="$1"
    local expected_name="$2"
    local expected_port="$3"
    
    echo -e "${BOLD}Testing: $service${RESET}"
    
    # Generate template non-interactively (send empty lines to use auto-detected defaults)
    if printf "\n\n\n" | /opt/homelab-tools/bin/generate-motd "$service" &>/dev/null; then
        local template="$HOME/.local/share/homelab-tools/templates/$service.sh"
        
        if [[ ! -f "$template" ]]; then
            fail "$service: Template not created"
            return
        fi
        
        # Check service name in template (case-insensitive)
        if grep -qi "$expected_name" "$template"; then
            pass "$service: Name detected ($expected_name)"
        else
            fail "$service: Name not found (expected: $expected_name)"
        fi
        
        # Check port if specified
        if [[ -n "$expected_port" ]]; then
            if grep -q ":$expected_port" "$template"; then
                pass "$service: Port detected ($expected_port)"
            else
                fail "$service: Port not found (expected: $expected_port)"
            fi
        fi
        
        # Cleanup
        rm -f "$template"
    else
        fail "$service: Generation failed"
    fi
}

# Media Servers (8)
echo -e "${BOLD}${CYAN}Media Servers${RESET}"
test_service "jellyfin" "Jellyfin" "8096"
test_service "plex" "Plex" "32400"
test_service "emby" "Emby" "8096"
test_service "navidrome" "Navidrome" "4533"
test_service "audiobookshelf" "Audiobookshelf" "13378"

# *arr Stack (7)
echo -e "\n${BOLD}${CYAN}*arr Stack${RESET}"
test_service "sonarr" "Sonarr" "8989"
test_service "radarr" "Radarr" "7878"
test_service "prowlarr" "Prowlarr" "9696"
test_service "lidarr" "Lidarr" "8686"
test_service "readarr" "Readarr" "8787"
test_service "bazarr" "Bazarr" "6767"
test_service "whisparr" "Whisparr" "6969"

# Download Clients (5)
echo -e "\n${BOLD}${CYAN}Download Clients${RESET}"
test_service "sabnzbd" "SABnzbd" "8080"
test_service "nzbget" "NZBGet" "6789"
test_service "transmission" "Transmission" "9091"
test_service "qbittorrent" "qBittorrent" "8080"
test_service "deluge" "Deluge" "8112"

# Network/DNS (6)
echo -e "\n${BOLD}${CYAN}Network & DNS${RESET}"
test_service "pihole" "Pi-hole" "80"
test_service "adguard" "AdGuard" "3000"
test_service "unbound" "Unbound" ""
test_service "unifi" "UniFi" "8443"
test_service "nginx" "Nginx" ""
test_service "traefik" "Traefik" "8080"

# Containers (4)
echo -e "\n${BOLD}${CYAN}Virtualization & Containers${RESET}"
test_service "portainer" "Portainer" "9000"
test_service "proxmox" "Proxmox" "8006"
test_service "pbs" "PBS" "8007"
test_service "yacht" "Yacht" "8000"

# Home Automation (5)
echo -e "\n${BOLD}${CYAN}Home Automation${RESET}"
test_service "nodered" "Node-RED" "1880"
test_service "zigbee2mqtt" "Zigbee2MQTT" "8080"
test_service "mosquitto" "Mosquitto" ""
test_service "esphome" "ESPHome" "6052"
test_service "frigate" "Frigate" "5000"

# Monitoring (7)
echo -e "\n${BOLD}${CYAN}Monitoring & Analytics${RESET}"
test_service "uptime-kuma" "Uptime Kuma" "3001"
test_service "grafana" "Grafana" "3000"
test_service "prometheus" "Prometheus" "9090"
test_service "influxdb" "InfluxDB" "8086"
test_service "tautulli" "Tautulli" "8181"
test_service "netdata" "Netdata" "19999"
test_service "glances" "Glances" "61208"

# Request Management (2)
echo -e "\n${BOLD}${CYAN}Request Management${RESET}"
test_service "overseerr" "Overseerr" "5055"
test_service "ombi" "Ombi" "3579"

# VPN (2)
echo -e "\n${BOLD}${CYAN}VPN Services${RESET}"
test_service "wireguard" "WireGuard" ""
test_service "openvpn" "OpenVPN" ""

# File Sync (2)
echo -e "\n${BOLD}${CYAN}File Sync & Share${RESET}"
test_service "nextcloud" "Nextcloud" "443"
test_service "syncthing" "Syncthing" "8384"

# Summary
echo ""
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "  Test Summary"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${GREEN}PASSED:${RESET} $PASS_COUNT"
echo -e "  ${RED}FAILED:${RESET} $FAIL_COUNT"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}✓✓✓ ALL SERVICE PRESETS VALIDATED! 🎉${RESET}"
    exit 0
else
    echo -e "${RED}✗ Some presets failed validation${RESET}"
    exit 1
fi
