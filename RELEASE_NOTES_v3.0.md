# 🎉 Homelab Tools v3.0 Release Notes

**Release Date:** 14 November 2025  
**Author:** J.Bakers  
**Type:** Major Release (v2.0 → v3.0)

---

## 🚀 What's New

### 🎯 Auto-Detection System
The biggest feature in v3.0 is the **intelligent service detection system** with support for **60+ popular homelab services**!

Just type the hostname and the tool automatically detects:
- Service name
- Description
- Web UI availability
- Default port

**Example:**
```bash
generate-motd frigate
# Automatically detects: Frigate, "NVR with AI Detection", port 5000
```

**Supported Categories:**
- 📺 **Media Servers** - Jellyfin, Plex, Emby, Navidrome, Audiobookshelf
- 🎬 ***arr Stack** - Sonarr, Radarr, Prowlarr, Lidarr, Readarr, Bazarr, Whisparr
- ⬇️ **Download Clients** - SABnzbd, NZBGet, qBittorrent, Transmission, Deluge
- 🏠 **Home Automation** - Home Assistant, Node-RED, Zigbee2MQTT, Mosquitto, ESPHome
- 📹 **Monitoring** - Frigate, Uptime Kuma, Grafana, Prometheus, InfluxDB
- 🌐 **Network** - Pi-hole, AdGuard, Unifi Controller, OPNsense, pfSense
- 🖥️ **Virtualization** - Proxmox, PBS, Portainer, Yacht
- 🎮 **Gaming** - Minecraft variants, Factorio, Terraria, Valheim
- 💻 **Development** - Gitea, GitLab, Code-Server, Jupyter
- And 40+ more services!

---

### ⚡ Bulk Operations

**Bulk Generate**
```bash
bulk-generate-motd
```
- Scans all hosts in `~/.ssh/config`
- Generate MOTDs for all hosts at once
- Smart prompts with "Y" defaults
- Skip, auto-generate, or interactive mode per host

**Bulk Deploy**
After generating, you get prompted:
```
Deploy all generated MOTDs to hosts? (Y/n):
```
Just press Enter and all MOTDs are deployed automatically!

---

### 🔧 SSH Setup Wizard

New clean install support in `install.sh`:

1. **Auto-detect missing SSH directory**
   - Creates `~/.ssh` with correct permissions (700)

2. **SSH Key Generation**
   - Generates modern ed25519 keys
   - Prompts for your email
   - Shows public key for easy copying

3. **SSH Config Template**
   - Creates `~/.ssh/config` with examples
   - Opens editor for immediate host configuration

All with smart "Y" defaults - just press Enter!

---

### ⚡ Optimized Workflow

**Before v3.0:**
```bash
generate-motd jellyfin
Service name: Jellyfin
Description: Media Server
Web UI? (y/n): y
Port: 8096
Customize? (y/n): n
Deploy now? (y/n): y
```

**After v3.0:**
```bash
generate-motd jellyfin
# Auto-detected: Jellyfin, Media Server, port 8096
Customize? (y/N): [just press Enter]
Deploy now? (Y/n): [just press Enter]
✓ Done!
```

---

### 🔄 Better Terminology

SSH-specific terminology replaced with host-based terminology:

| Old (v2.0) | New (v3.0) |
|------------|------------|
| `edit-ssh` | `edit-hosts` |
| "SSH config" | "host configuration" |
| "SSH keys cleanup" | "host keys cleanup" |
| "Deploy to container" | "Deploy to host" |

More intuitive for homelab context where SSH is just one component.

---

### 🎨 Visual Improvements

**Fixed Box Borders**
All `╔══╗` borders now properly aligned:
```
╔══════════════════════════════════════════════════════════╗
║         🏠 HOMELAB MANAGEMENT TOOLS v3.0              ║
╚══════════════════════════════════════════════════════════╝
```
Previously the emoji width caused misalignment - now fixed!

**Rainbow ASCII Art**
Beautiful centered rainbow text using `toilet -F gay`:
```bash
     ▄▄▄▄▄▄▄ █▀▀▀▀▀█ ▄▄▄▄▄▄ ▄▄▄▄▄▄▄
     █ ███ █ █ ▄▄▄ █ █  ▄  ▄ █ ███ █
     # Rainbow colored!
```

---

### 🛠️ Enhanced Tools

**cleanup-keys**
- Fully automatic with interactive menu
- Shows numbered list of all hosts
- Options: number, 'a' for all, 'q' to quit
- No more manual `ssh-keygen -R` commands

**generate-motd**
- 60+ service auto-detection
- Smart defaults (customize=N, deploy=Y)
- Automatic deployment option
- Rainbow ASCII art generation

**bulk-generate-motd** *(new)*
- Process all hosts in one session
- Smart prompts with Y defaults
- Automatic bulk deployment
- Progress tracking and summary

---

## 📊 Statistics

- **Files Changed:** 8 core scripts + install.sh
- **Services Supported:** 60+
- **New Features:** 5 major
- **UI Improvements:** 10+
- **Bug Fixes:** Border alignment, emoji spacing

---

## 🔧 Upgrade Instructions

### From v2.0:
```bash
cd ~/homelab-tools
git pull
./install.sh
source ~/.bashrc
```

### Fresh Install:
```bash
git clone git@github.com:JBakers/homelab-tools.git
cd homelab-tools
./install.sh
source ~/.bashrc
homelab
```

The new SSH setup wizard will guide you through SSH configuration if needed.

---

## 📝 Breaking Changes

None! v3.0 is fully backward compatible with v2.0.

**Migration notes:**
- Command `edit-ssh` still works (symlink to `edit-hosts`)
- Old templates remain valid
- Existing SSH config unchanged

---

## 🐛 Known Issues

None reported.

---

## 🙏 Credits

- **Rainbow ASCII:** `toilet` with `-F gay` filter
- **Service Database:** Community knowledge + popular homelab services
- **Testing:** Debian 13 (bookworm)
- **AI Assistance:** GitHub Copilot (Claude Sonnet 4.5)

---

## 📚 Documentation

- **README.md** - Getting started guide
- **CHANGELOG.md** - Full version history
- **QUICKSTART.md** - Quick reference
- Built-in help: `homelab help` or `<command> --help`

---

## 🔮 What's Next (v3.1)

Planned features:
- Docker container detection
- Service health checks
- Custom service definitions (user config)
- Template themes
- Backup/restore functionality

---

## 💬 Feedback

Found a bug? Want a feature?
- Open an issue on GitHub
- Submit a pull request
- Contact: @JBakers

---

**Enjoy v3.0! 🎉**

*Making homelab management beautiful, one MOTD at a time.*
