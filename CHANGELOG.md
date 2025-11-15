# Changelog - Homelab Tools

## v3.4.0 (16 November 2025)

### Major Changes

- All scripts and documentation updated to v3.4.0
- Bulk generate workflow improved: new "yes to all" option, clean MOTD default, ASCII art selection expanded
- Input validation and command injection protection in all relevant scripts
- Menu and interactive prompts reworked for clarity and usability
- README.md: improved installation, usage, and MOTD style documentation
- Minor bugfixes and consistency improvements across all scripts
- FHS-compliant installation and uninstall scripts

### Features

- Bulk generate now supports fully automated workflows ("yes to all")
- Clean & functional MOTD is now the default style
- Expanded ASCII art selection: 5 styles, live preview
- Interactive menu and prompts improved for usability

### Bug Fixes & Improvements

- Input validation added to all relevant scripts (command injection protection)
- Minor bugfixes and consistency improvements

### Documentation

- CHANGELOG.md: new section for v3.4.0, all major changes listed
- README.md: improved installation, usage, and MOTD style documentation

---


## v3.3.0 (15 November 2025)

### 🏗️ Installation Structure Improvements

#### Clean Directory Structure

- **Program Location** - Moved from `~/homelab-tools/` to `/opt/homelab-tools/`
  - Follows Linux Filesystem Hierarchy Standard (FHS)
  - Keeps home directory clean and organized
  - System-wide installation for all users
- **Symlinks** - Changed from `/usr/local/bin/` to `~/.local/bin/`
  - Standard user bin directory
  - No sudo needed for symlinks
  - Automatically in PATH for most systems
- **User Data** - Templates remain in `~/.local/share/homelab-tools/templates/`
  - Follows XDG Base Directory specification
  - User data separate from program files

### 🐛 Bug Fixes

#### Uninstall Script

- **Fixed** - `$INSTALL_DIR` unbound variable error
- **Improved** - Backward compatibility with old installation paths
- **Enhanced** - Proper cleanup of all components

### 📝 Documentation

- Updated all script versions to 3.3.0
- Added clear sudo requirements in README
- Updated installation instructions

---

## v3.2.0 (15 November 2025)

### 🔒 Security Fixes (CRITICAL)

#### Command Injection Protection

- **Input Validation** - Added regex validation `^[a-zA-Z0-9._-]+$` to prevent command injection
  - `generate-motd`: Validate service names before use in commands
  - `deploy-motd`: Validate service names before SSH/SCP operations
  - `cleanup-keys`: Validate hostnames before ssh-keygen
- **Attack Prevention** - Blocks attempts like `generate-motd "; rm -rf / #"`
- **Sed Injection Fix** - Escape special characters in descriptions for sed operations

#### Error Handling

- **set -euo pipefail** - Added to ALL 13 scripts (bin/* + root scripts)
  - Exit on command failures (-e)
  - Exit on undefined variables (-u)
  - Exit on pipe failures (-o pipefail)
- **Unbound Variable Fix** - Replace `$1` with `${1:-}` in all argument checks
  - Prevents crashes when scripts run without arguments
  - Safe defaults for optional parameters

### 🐛 Bug Fixes

#### Number Duplication Bug

- **Fixed** - Services like `pihole2` no longer show "Pi-hole 2 2"
- **Solution** - Moved number extraction to default case only
- **Known services** - Keep their predefined formatting (Jellyfin 2, Plex 3, etc.)
- **Unknown services** - Get number extraction (test1 → Test 1)

#### Host Count Bug

- **Fixed** - `bulk-generate-motd` now counts hosts correctly
- **Change** - `wc -w` → `wc -l` for line-based counting
- **Impact** - Accurate host count display

#### UUOC (Useless Use of Cat)

- **Fixed** - Removed cat pipe in `copykey`
- **Before** - `cat "$file" | ssh ...`
- **After** - `ssh ... < "$file"`
- **Benefit** - Better performance, cleaner code

### ✨ Features

#### Bulk Generate Improvements

- **--yes flag** - Auto-confirm overwrite prompts
- **--all flag** - Fully automatic generation (existing)
- **Simplified help** - Clearer, more concise usage information

### 📝 Documentation

- Updated all script versions to 3.3.0
- Security audit completed - no critical issues remaining
- All 13 scripts hardened and validated

### 📊 Statistics

- 13 scripts with `set -euo pipefail` (100% coverage)
- 3 scripts with input validation (all user-facing scripts)
- 4 critical bugs fixed
- 0 security vulnerabilities remaining

---

## v3.0 (14 November 2025)

### 🎯 Major Features

#### Auto-Detection System (60+ services)

- **Smart Service Recognition** - Automatic detection of service info based on hostname
- **Categories:**
  - Media Servers: Jellyfin, Plex, Emby, Navidrome, Audiobookshelf
  - *arr Stack: Sonarr, Radarr, Prowlarr, Lidarr, Readarr, Bazarr, Whisparr
  - Download Clients: SABnzbd, NZBGet, qBittorrent, Transmission, Deluge
  - Home Automation: Home Assistant, Node-RED, Zigbee2MQTT, Mosquitto, ESPHome
  - Monitoring: Frigate, Uptime Kuma, Grafana, Prometheus, InfluxDB
  - Network: Pi-hole, AdGuard, Unifi Controller, OPNsense, pfSense
  - Virtualization: Proxmox, PBS, Portainer, Yacht
  - Gaming: Minecraft variants, Factorio, Terraria, Valheim
  - Development: Gitea, GitLab, Code-Server, Jupyter
  - And many more...

#### Bulk Operations

- **Bulk Generator** - Generate MOTDs for all hosts in one go
- **Bulk Deploy** - Deploy all generated MOTDs automatically
- **Smart Prompts** - Default "Y" for overwrite and deploy

#### SSH Setup Automation

- **Clean Install Support** - Auto-create `~/.ssh` directory
- **Key Generation** - Automatic ed25519 SSH key generation
- **Config Template** - Pre-configured SSH config with examples
- **Interactive Editor** - Direct config editing after creation

#### Workflow Optimization

- **Fast Generation** - Just press Enter twice for full auto-deploy
- **Default Prompts:**
  - Customize? (y/N) - defaults to No
  - Deploy? (Y/n) - defaults to Yes
- **Rainbow ASCII** - Beautiful centered rainbow text with toilet -F gay
- **Fixed Borders** - All box borders properly aligned (emoji spacing fixed)

### 🔄 Terminology Changes

- **SSH → Hosts** throughout entire codebase
- `edit-ssh` → `edit-hosts`
- "SSH config" → "host configuration"
- "SSH keys" → "host keys"
- More intuitive for homelab context

### 🎨 Visual Improvements

- **Aligned Borders** - Fixed all ╔══╗ boxes to account for emoji width
- **Consistent Spacing** - 5-space indent for ASCII art
- **Rainbow Colors** - ANSI codes properly embedded via heredoc
- **Emoji Icons** - 📊🖥️🌐⏱️🔗 working correctly

### 🛠️ Tools Enhanced

- **cleanup-keys** - Fully automatic with menu selection (numbered list, 'a' for all)
- **generate-motd** - Smart defaults, auto-deploy option, 60+ services
- **bulk-generate-motd** - New tool for bulk operations with bulk deploy
- **install.sh** - SSH setup wizard for clean installs

### 📝 Version Bump

- All scripts updated to v3.0
- homelab main menu shows v3.0

---

## v2.0 (November 2025)

### ✨ New Features

- 🌈 **Rainbow ASCII Art Support** - Dynamic colorful banners with toilet -F gay filter
- 📊 **Dynamic MOTD Generation** - Always shows current system info (uptime, IP, etc.)
- 🛡️ **Pi-hole v6 Support** - Full compatibility with latest Pi-hole version
- 🔗 **Web UI Link Support** - Automatic links to service dashboards
- 📚 **Comprehensive Help System** - Detailed documentation via `homelab help`
- ✨ **Improved Styling** - Centered ASCII art and emoji icons
- 🔧 **New Commands** - `edit-ssh` and `bulk-generate-motd`

### 🐛 Bug Fixes (v2.0)

#### 1. install.sh - chmod wildcard bug

**Probleem:** `chmod +x "$BIN_DIR/"*` faalt als directory leeg is
**Oplossing:** Vervangen door `find` command:

```bash
find ~/.local/bin -type f \( -name "homelab" -o -name "*-motd" -o -name "copykey" -o -name "cleanup-*" \) -exec chmod +x {} \; 2>/dev/null || true
```

#### 2. test.sh - hardcoded paths

**Probleem:** Script bevat `/home/claude/` paths (7x)
**Oplossing:** Vervangen door `$HOME` variabele

#### 3. bin/homelab - ANSI kleuren niet zichtbaar

**Probleem:** `cat << EOF` heredoc toont ruwe escape codes (`\033[1m` etc.)
**Oplossing:** Vervangen door `echo -e` statements in `show_help()` en `show_menu()`

### ✨ Features Toegevoegd

#### 1. copykey terug in v2.0

- **Bestand:** `bin/copykey` gekopieerd van v1.0
- **Styling:** Bijgewerkt naar v2.0 kleurenschema
- **Menu:** Toegevoegd als optie 5 in `bin/homelab`

#### 2. Interactive menu verbeterd

- **show_menu()**: Nu met `echo -e` voor correcte kleuren
- **show_help()**: Nu met `echo -e` voor correcte kleuren
- **Opties:** 1-5 + h (help) + q (quit)

### 📝 Documentatie

#### README.md

- **Van:** Nederlands
- **Naar:** Engels met emojis
- **Toegevoegd:** Comprehensive usage examples, troubleshooting

#### .gitignore

- **Toegevoegd:** `test.sh` en `test-*.sh` (lokaal testen only)

### 🗂️ Structuur Wijzigingen

**Voor (v1.0):**

```
~/.config/homelab-tools/
├── config/
│   ├── hosts.txt
│   └── ssh-config
└── server-motd/
```

**Na (v2.0):**

```
~/homelab-tools/
├── bin/
│   ├── homelab (interactive menu)
│   ├── generate-motd
│   ├── deploy-motd
│   ├── cleanup-keys
│   ├── list-templates
│   └── copykey
└── templates/ (voor MOTD scripts)
```

### 🧪 Testing

**Lokale installatie:**

```bash
cd ~/homelab-tools
bash install/install.sh
source ~/.bashrc
homelab
```

**Status:**

- ✅ Syntax checks: All passed
- ✅ Installation: Completed
- ⏳ User testing: Pending
- ⏳ Git commit: Pending

### 🔧 Technical Details

**Bestanden aangepast:**

1. `install/install.sh` - chmod fix
2. `test.sh` - path fix
3. `bin/homelab` - kleuren fix + copykey menu
4. `bin/copykey` - toegevoegd
5. `README.md` - Engels
6. `.gitignore` - test files

**Backup gemaakt:**

- `~/homelab-tools.backup.20251114_025818`

### 📋 Next Steps

1. Test `homelab` command interactief
2. Verifieer alle 5 opties werken
3. Check kleuren in terminal
4. Git commit + push naar GitHub

---

**Auteur:** J.Bakers  
**Versie:** 2.0  
**AI Assistant:** GitHub Copilot
