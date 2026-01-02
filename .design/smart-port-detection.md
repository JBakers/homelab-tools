# Smart Port Detection - Feature Design

**Priority:** P2 (Medium)
**Estimated Time:** 2-3 hours
**Status:** Planned

---

## 🎯 Problem Statement

Users run custom ports in their homelabs, causing incorrect Web UI URLs in MOTDs.

**Example:**
- Zigbee2MQTT default: 8080
- User's config: 2804
- Current behavior: Shows wrong URL (http://host:8080)
- Expected: Detect and show correct URL (http://host:2804)

---

## 💡 Solution: Multi-Layer Port Detection

### Strategy (in order of execution)

```
1. Config File Check
   ↓ (if not found)
2. SSH Port Scan
   ↓ (if fails)
3. Docker Container Check
   ↓ (if fails)
4. Interactive Prompt
```

---

## 📋 Implementation Details

### Layer 1: Config File (~/.config/homelab-tools/custom-ports.conf)

```bash
# Format: service@hostname=port
zigbee2mqtt@homeserver=2804
pihole@dns1=8080
jellyfin@media=8097

# Wildcards supported
pihole@*=8080
*@media=8096
```

**Function:**
```bash
get_custom_port() {
    local service="$1"
    local hostname="$2"
    local config="$HOME/.config/homelab-tools/custom-ports.conf"
    
    # Exact match
    grep "^${service}@${hostname}=" "$config" | cut -d= -f2
    
    # Fallback: wildcard
    grep "^${service}@\*=" "$config" | cut -d= -f2
}
```

### Layer 2: SSH Port Scan

```bash
detect_port_ssh() {
    local service="$1"
    local hostname="$2"
    local default_port="$3"
    
    # Check if default port is listening
    if ssh "$hostname" "ss -tlnp 2>/dev/null | grep -q :${default_port}"; then
        echo "$default_port"
        return 0
    fi
    
    # Scan common range (8000-9999)
    local found_port
    found_port=$(ssh "$hostname" "ss -tlnp 2>/dev/null | grep -oP ':\K(8[0-9]{3}|9[0-9]{3})' | sort -u | head -1")
    
    if [[ -n "$found_port" ]]; then
        echo "$found_port"
        return 0
    fi
    
    return 1
}
```

### Layer 3: Docker Container Check

```bash
detect_port_docker() {
    local service="$1"
    local hostname="$2"
    
    # Find container by name/image
    local port_mapping
    port_mapping=$(ssh "$hostname" "docker ps --filter name=${service} --format '{{.Ports}}' 2>/dev/null")
    
    # Extract host port from mapping (0.0.0.0:2804->8080/tcp)
    echo "$port_mapping" | grep -oP ':\K\d+(?=->)'
}
```

### Layer 4: Interactive Prompt

```bash
prompt_custom_port() {
    local service="$1"
    local default_port="$2"
    
    echo -e "${YELLOW}⚠ Default port $default_port not detected${RESET}"
    echo ""
    read -p "Enter custom port (or press Enter for $default_port, q to skip): " custom_port
    
    case "$custom_port" in
        ""|"$default_port") echo "$default_port" ;;
        q|Q) return 1 ;;
        *) 
            if [[ "$custom_port" =~ ^[0-9]+$ ]]; then
                echo "$custom_port"
            else
                echo -e "${RED}Invalid port${RESET}"
                return 1
            fi
            ;;
    esac
}
```

---

## 🔧 Integration in generate-motd

```bash
# After service detection (line ~450)
if [[ "$has_webui" == "y" ]]; then
    # Try to detect actual port
    detected_port=""
    
    # Layer 1: Config file
    detected_port=$(get_custom_port "$SERVICE" "$(hostname -s)" 2>/dev/null)
    
    # Layer 2: SSH scan (if hostname provided)
    if [[ -z "$detected_port" ]] && [[ -n "$DEPLOY_HOST" ]]; then
        detected_port=$(detect_port_ssh "$SERVICE" "$DEPLOY_HOST" "$webui_port" 2>/dev/null)
    fi
    
    # Layer 3: Docker check
    if [[ -z "$detected_port" ]] && [[ -n "$DEPLOY_HOST" ]]; then
        detected_port=$(detect_port_docker "$SERVICE" "$DEPLOY_HOST" 2>/dev/null)
    fi
    
    # Layer 4: Interactive prompt
    if [[ -z "$detected_port" ]]; then
        detected_port=$(prompt_custom_port "$SERVICE" "$webui_port")
    fi
    
    # Use detected port or fall back to default
    webui_port="${detected_port:-$webui_port}"
fi
```

---

## 🎨 User Experience

### Scenario 1: Config file exists
```bash
$ generate-motd zigbee2mqtt
✓ Auto-detected: Zigbee2MQTT - Zigbee to MQTT Bridge
✓ Custom port detected: 2804 (from config)
✓ Template created: ~/.local/share/homelab-tools/templates/zigbee2mqtt.sh
```

### Scenario 2: SSH detection
```bash
$ generate-motd jellyfin
✓ Auto-detected: Jellyfin - Media Server
⌛ Scanning ports on jellyfin...
✓ Port detected: 8097 (via SSH scan)
💡 Save to config? (Y/n): y
✓ Saved to ~/.config/homelab-tools/custom-ports.conf
✓ Template created
```

### Scenario 3: Manual entry
```bash
$ generate-motd pihole
✓ Auto-detected: Pi-hole - Network-wide Ad Blocking
⚠ Default port 80 not detected

Enter custom port (or press Enter for 80, q to skip): 8080
✓ Using port: 8080
💡 Save to config for next time? (Y/n): y
✓ Template created
```

---

## 🧪 Testing Strategy

### Test Cases

1. **Config file priority**
   - Create custom-ports.conf with zigbee2mqtt@test=2804
   - Run generate-motd zigbee2mqtt
   - Verify port 2804 is used

2. **SSH detection fallback**
   - No config entry
   - Mock SSH response with ss output
   - Verify detected port is used

3. **Docker detection**
   - No config, SSH fails
   - Mock docker ps output
   - Verify extracted port is used

4. **Interactive prompt**
   - No config, SSH fails, Docker fails
   - Simulate user input
   - Verify custom port accepted

5. **Invalid input handling**
   - Test non-numeric input
   - Test port out of range
   - Verify error messages

6. **Save to config**
   - Detect port via SSH
   - Confirm save prompt
   - Verify config file updated

---

## 📁 File Changes

### New Files
1. `lib/port-detection.sh` - Port detection functions
2. `config/custom-ports.conf.example` - Example config

### Modified Files
1. `bin/generate-motd` - Integrate port detection
2. `README.md` - Document custom port feature
3. `QUICKSTART.md` - Add port detection examples

### Test Files
1. `.test-env/test-port-detection.sh` - Port detection tests
2. `.test-env/fixtures/custom-ports.conf` - Test config

---

## ⚠️ Edge Cases

### Handle gracefully:
1. **SSH timeout** - Fall back to next method (max 5s wait)
2. **Permission denied** - Skip SSH, try Docker
3. **Multiple ports** - Show menu to select
4. **No network** - Skip auto-detect, go to prompt
5. **Invalid hostname** - Warn but allow manual entry

---

## 🚀 Future Enhancements

### Phase 2 (P3):
1. **Port caching** - Remember detected ports
2. **Bulk detection** - Scan all services at once
3. **Web UI** - Visual port configuration
4. **API integration** - Query service APIs for ports
5. **Port conflicts** - Warn if multiple services on same port

---

## 📊 Success Metrics

**Before:**
- 100% manual port entry for custom configs
- Incorrect URLs in 30%+ of MOTDs

**After:**
- 90%+ automatic detection
- <5% incorrect URLs
- Reduced generation time by ~50%

---

## 🔗 Related Features

- Service preset expansion (P1 #5)
- Non-interactive mode (P1 #6)
- Configuration management (edit-config)

---

**Status:** Ready for implementation (P2 priority)
**Dependencies:** None (independent feature)
**Risk:** Low (graceful fallbacks at each layer)
