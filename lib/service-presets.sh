#!/bin/bash
# lib/service-presets.sh - Service preset detection for MOTD generation
# 
# This library contains the service detection logic extracted from generate-motd.
# It provides auto-detection of 60+ homelab services with their default configurations.
#
# Usage:
#   source "$LIB_DIR/service-presets.sh"
#   detect_service_preset "pihole"
#   echo "$HLT_SERVICE_NAME"    # "Pi-hole"
#   echo "$HLT_SERVICE_DESC"    # "Network-wide Ad Blocking"
#   echo "$HLT_HAS_WEBUI"       # "y"
#   echo "$HLT_WEBUI_PORT"      # "80/admin"
#
# Author: J.Bakers
# Version: See VERSION file

#──────────────────────────────────────────────────────────────────────────────
# Function: detect_service_preset
# Description: Detect service type and set preset configuration values
# Arguments:
#   $1 - Service name (e.g., "pihole", "jellyfin2", "sonarr")
# Returns: 0 on success
# Globals Modified:
#   HLT_SERVICE_NAME - Human-readable service name (e.g., "Pi-hole", "Jellyfin 2")
#   HLT_SERVICE_DESC - Service description
#   HLT_HAS_WEBUI    - "y" if service has web UI, "n" otherwise
#   HLT_WEBUI_PORT   - Default web UI port (e.g., "8080", "32400/web")
#   HLT_VERSION_CMD  - Optional version detection command
# Notes: Service names ending in numbers get proper spacing (pihole2 → "Pi-hole 2")
#──────────────────────────────────────────────────────────────────────────────
detect_service_preset() {
    local service="$1"
    local number
    
    # Reset globals
    HLT_SERVICE_NAME=""
    HLT_SERVICE_DESC=""
    HLT_HAS_WEBUI="n"
    HLT_WEBUI_PORT=""
    HLT_VERSION_CMD=""
    
    case "$service" in
        # ══════════════════════════════════════════════════════════════════════
        # MEDIA SERVERS
        # ══════════════════════════════════════════════════════════════════════
        jellyfin*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Jellyfin${number:+ $number}"
            HLT_SERVICE_DESC="Media Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8096"
            ;;
        plex*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Plex${number:+ $number}"
            HLT_SERVICE_DESC="Media Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="32400/web"
            ;;
        emby*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Emby${number:+ $number}"
            HLT_SERVICE_DESC="Media Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8096"
            ;;
        navidrome)
            HLT_SERVICE_NAME="Navidrome"
            HLT_SERVICE_DESC="Music Streaming Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="4533"
            ;;
        audiobookshelf)
            HLT_SERVICE_NAME="Audiobookshelf"
            HLT_SERVICE_DESC="Audiobook & Podcast Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="13378"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # DOWNLOAD & INDEXING (ARR STACK)
        # ══════════════════════════════════════════════════════════════════════
        sonarr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Sonarr${number:+ $number}"
            HLT_SERVICE_DESC="TV Series Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8989"
            ;;
        radarr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Radarr${number:+ $number}"
            HLT_SERVICE_DESC="Movie Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="7878"
            ;;
        lidarr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Lidarr${number:+ $number}"
            HLT_SERVICE_DESC="Music Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8686"
            ;;
        readarr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Readarr${number:+ $number}"
            HLT_SERVICE_DESC="Book Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8787"
            ;;
        prowlarr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Prowlarr${number:+ $number}"
            HLT_SERVICE_DESC="Indexer Manager"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="9696"
            ;;
        bazarr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Bazarr${number:+ $number}"
            HLT_SERVICE_DESC="Subtitle Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="6767"
            ;;
        overseerr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Overseerr${number:+ $number}"
            HLT_SERVICE_DESC="Media Request Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="5055"
            ;;
        ombi*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Ombi${number:+ $number}"
            HLT_SERVICE_DESC="Media Request Manager"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="5000"
            ;;
        jackett*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Jackett${number:+ $number}"
            HLT_SERVICE_DESC="Torrent Indexer Proxy"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="9117"
            ;;
        sabnzbd*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="SABnzbd${number:+ $number}"
            HLT_SERVICE_DESC="Usenet Downloader"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8080"
            ;;
        nzbget*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="NZBGet${number:+ $number}"
            HLT_SERVICE_DESC="Usenet Downloader"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="6789"
            ;;
        transmission*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Transmission${number:+ $number}"
            HLT_SERVICE_DESC="BitTorrent Client"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="9091"
            ;;
        qbittorrent*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="qBittorrent${number:+ $number}"
            HLT_SERVICE_DESC="BitTorrent Client"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8080"
            ;;
        deluge*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Deluge${number:+ $number}"
            HLT_SERVICE_DESC="BitTorrent Client"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8112"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # NETWORK & DNS
        # ══════════════════════════════════════════════════════════════════════
        pihole*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Pi-hole${number:+ $number}"
            HLT_SERVICE_DESC="Network-wide Ad Blocking"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="80/admin"
            ;;
        adguard*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="AdGuard Home${number:+ $number}"
            HLT_SERVICE_DESC="Network-wide Ad Blocking"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="3000"
            ;;
        unifi*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="UniFi Controller${number:+ $number}"
            HLT_SERVICE_DESC="Network Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8443"
            ;;
        opnsense*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="OPNsense${number:+ $number}"
            HLT_SERVICE_DESC="Firewall & Router"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="443"
            ;;
        pfsense*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="pfSense${number:+ $number}"
            HLT_SERVICE_DESC="Firewall & Router"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="443"
            ;;
        nginx*proxy*|npm*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Nginx Proxy Manager${number:+ $number}"
            HLT_SERVICE_DESC="Reverse Proxy Manager"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="81"
            ;;
        traefik*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Traefik${number:+ $number}"
            HLT_SERVICE_DESC="Reverse Proxy & Load Balancer"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8080"
            ;;
        caddy*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Caddy${number:+ $number}"
            HLT_SERVICE_DESC="Web Server & Reverse Proxy"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        wireguard*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="WireGuard${number:+ $number}"
            HLT_SERVICE_DESC="VPN Server"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        tailscale*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Tailscale${number:+ $number}"
            HLT_SERVICE_DESC="VPN & Mesh Network"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # MONITORING & DASHBOARDS
        # ══════════════════════════════════════════════════════════════════════
        grafana*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Grafana${number:+ $number}"
            HLT_SERVICE_DESC="Observability Dashboard"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="3000"
            ;;
        prometheus*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Prometheus${number:+ $number}"
            HLT_SERVICE_DESC="Monitoring & Alerting"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="9090"
            ;;
        uptime*kuma*|uptimekuma*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Uptime Kuma${number:+ $number}"
            HLT_SERVICE_DESC="Uptime Monitoring"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="3001"
            ;;
        portainer*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Portainer${number:+ $number}"
            HLT_SERVICE_DESC="Container Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="9443"
            ;;
        homepage*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Homepage${number:+ $number}"
            HLT_SERVICE_DESC="Application Dashboard"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="3000"
            ;;
        heimdall*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Heimdall${number:+ $number}"
            HLT_SERVICE_DESC="Application Dashboard"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="443"
            ;;
        homarr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Homarr${number:+ $number}"
            HLT_SERVICE_DESC="Dashboard & Bookmark Manager"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="7575"
            ;;
        organizr*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Organizr${number:+ $number}"
            HLT_SERVICE_DESC="HTPC/Homelab Organizer"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="80"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # VIRTUALIZATION & CONTAINERS
        # ══════════════════════════════════════════════════════════════════════
        proxmox*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Proxmox VE${number:+ $number}"
            HLT_SERVICE_DESC="Virtualization Platform"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8006"
            ;;
        docker*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Docker Host${number:+ $number}"
            HLT_SERVICE_DESC="Container Runtime"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        kubernetes*|k8s*|k3s*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Kubernetes${number:+ $number}"
            HLT_SERVICE_DESC="Container Orchestration"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # HOME AUTOMATION
        # ══════════════════════════════════════════════════════════════════════
        homeassistant|hass|ha)
            HLT_SERVICE_NAME="Home Assistant"
            HLT_SERVICE_DESC="Home Automation"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8123"
            ;;
        nodered|node-red)
            HLT_SERVICE_NAME="Node-RED"
            HLT_SERVICE_DESC="Flow-based Programming"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="1880"
            ;;
        mqtt|mosquitto)
            HLT_SERVICE_NAME="MQTT Broker"
            HLT_SERVICE_DESC="Message Broker"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        zigbee2mqtt|z2m)
            HLT_SERVICE_NAME="Zigbee2MQTT"
            HLT_SERVICE_DESC="Zigbee to MQTT Bridge"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8080"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # FILE STORAGE & SYNC
        # ══════════════════════════════════════════════════════════════════════
        nextcloud*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Nextcloud${number:+ $number}"
            HLT_SERVICE_DESC="File Storage & Sync"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="443"
            ;;
        syncthing*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Syncthing${number:+ $number}"
            HLT_SERVICE_DESC="File Synchronization"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8384"
            ;;
        seafile*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Seafile${number:+ $number}"
            HLT_SERVICE_DESC="File Sync & Share"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8000"
            ;;
        filebrowser*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="File Browser${number:+ $number}"
            HLT_SERVICE_DESC="Web File Manager"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8080"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # DATABASES & CACHING
        # ══════════════════════════════════════════════════════════════════════
        mariadb*|mysql*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="MariaDB${number:+ $number}"
            HLT_SERVICE_DESC="Database Server"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        postgres*|postgresql*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="PostgreSQL${number:+ $number}"
            HLT_SERVICE_DESC="Database Server"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        redis*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Redis${number:+ $number}"
            HLT_SERVICE_DESC="In-Memory Data Store"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        influxdb*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="InfluxDB${number:+ $number}"
            HLT_SERVICE_DESC="Time Series Database"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8086"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # SECURITY & AUTHENTICATION
        # ══════════════════════════════════════════════════════════════════════
        vaultwarden*|bitwarden*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Vaultwarden${number:+ $number}"
            HLT_SERVICE_DESC="Password Manager"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="80"
            ;;
        authelia*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Authelia${number:+ $number}"
            HLT_SERVICE_DESC="Authentication Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="9091"
            ;;
        authentik*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Authentik${number:+ $number}"
            HLT_SERVICE_DESC="Identity Provider"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="9000"
            ;;
        crowdsec*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="CrowdSec${number:+ $number}"
            HLT_SERVICE_DESC="Security Automation"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # PHOTOS & DOCUMENTS
        # ══════════════════════════════════════════════════════════════════════
        immich*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Immich${number:+ $number}"
            HLT_SERVICE_DESC="Photo & Video Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="2283"
            ;;
        photoprism*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="PhotoPrism${number:+ $number}"
            HLT_SERVICE_DESC="AI-Powered Photo App"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="2342"
            ;;
        paperless*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Paperless-ngx${number:+ $number}"
            HLT_SERVICE_DESC="Document Management"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8000"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # GAMING & ENTERTAINMENT
        # ══════════════════════════════════════════════════════════════════════
        minecraft*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Minecraft${number:+ $number}"
            HLT_SERVICE_DESC="Game Server"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # DEVELOPMENT & TOOLS
        # ══════════════════════════════════════════════════════════════════════
        gitea*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Gitea${number:+ $number}"
            HLT_SERVICE_DESC="Git Service"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="3000"
            ;;
        gitlab*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="GitLab${number:+ $number}"
            HLT_SERVICE_DESC="DevOps Platform"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="80"
            ;;
        drone*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Drone CI${number:+ $number}"
            HLT_SERVICE_DESC="Continuous Integration"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="80"
            ;;
        jenkins*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Jenkins${number:+ $number}"
            HLT_SERVICE_DESC="Automation Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8080"
            ;;
        codeserver*|code-server*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Code Server${number:+ $number}"
            HLT_SERVICE_DESC="VS Code in Browser"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8443"
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # BACKUP & SYNC
        # ══════════════════════════════════════════════════════════════════════
        duplicati*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Duplicati${number:+ $number}"
            HLT_SERVICE_DESC="Backup Solution"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="8200"
            ;;
        restic*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Restic${number:+ $number}"
            HLT_SERVICE_DESC="Backup Program"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        borg*|borgmatic*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Borg Backup${number:+ $number}"
            HLT_SERVICE_DESC="Deduplicating Backup"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # GENERIC SERVERS
        # ══════════════════════════════════════════════════════════════════════
        webserver*|web*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Web Server${number:+ $number}"
            HLT_SERVICE_DESC="HTTP Server"
            HLT_HAS_WEBUI="y"
            HLT_WEBUI_PORT="80"
            ;;
        fileserver*|nas*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="File Server${number:+ $number}"
            HLT_SERVICE_DESC="Network Storage"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        mailserver*|mail*)
            number=$(echo "$service" | grep -o '[0-9]\+$' || true)
            HLT_SERVICE_NAME="Mail Server${number:+ $number}"
            HLT_SERVICE_DESC="Email Server"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            ;;
        
        # ══════════════════════════════════════════════════════════════════════
        # DEFAULT (Unknown Service)
        # ══════════════════════════════════════════════════════════════════════
        *)
            # Capitalize first letter of service name
            HLT_SERVICE_NAME="${service^}"
            HLT_SERVICE_DESC="Server"
            HLT_HAS_WEBUI="n"
            HLT_WEBUI_PORT=""
            
            # Preserve numbers in service name for unknown services (e.g., myservice2 → Myservice 2)
            if [[ "$service" =~ ([0-9]+)$ ]]; then
                local num="${BASH_REMATCH[1]}"
                # Remove number from HLT_SERVICE_NAME and add it back with space
                HLT_SERVICE_NAME="${HLT_SERVICE_NAME%$num} $num"
            fi
            ;;
    esac
    
    return 0
}

#──────────────────────────────────────────────────────────────────────────────
# Function: get_all_service_presets
# Description: Get list of all known service presets
# Arguments: None
# Returns: Newline-separated list of service names
# Notes: Useful for autocomplete and validation
#──────────────────────────────────────────────────────────────────────────────
get_all_service_presets() {
    cat << 'EOF'
jellyfin
plex
emby
navidrome
audiobookshelf
sonarr
radarr
lidarr
readarr
prowlarr
bazarr
overseerr
ombi
jackett
sabnzbd
nzbget
transmission
qbittorrent
deluge
pihole
adguard
unifi
opnsense
pfsense
npm
traefik
caddy
wireguard
tailscale
grafana
prometheus
uptimekuma
portainer
homepage
heimdall
homarr
organizr
proxmox
docker
kubernetes
homeassistant
nodered
mqtt
zigbee2mqtt
nextcloud
syncthing
seafile
filebrowser
mariadb
postgres
redis
influxdb
vaultwarden
authelia
authentik
crowdsec
immich
photoprism
paperless
minecraft
gitea
gitlab
drone
jenkins
codeserver
duplicati
restic
borgmatic
EOF
}
