# Changelog - Homelab Tools

## v3.6.0-dev (In Development)

**Current development branch** - Building on v3.5.0 release

### ✨ New Features

#### MOTD Management
- `undeploy-motd` - Remove MOTDs from remote hosts (single + bulk with --all)
- `list-templates --status` - Deployment tracking with 🟢🟡🔴 indicators
- `list-templates --view` - Interactive preview mode with arrow navigation
- Deployment logging in `~/.local/share/homelab-tools/deploy-log`

#### Enhanced generate-motd (dev.15-16)
- Non-interactive mode for scripting: accepts Web UI choice + port via stdin
- Creates minimal but functional templates from stdin input
- Useful for automation and batch template generation
- Translates remaining Dutch strings to English

#### Enhanced edit-hosts (dev.13)
- Interactive host menu with arrow key navigation
- Add new host wizard with validation (IP/hostname, port, username)
- Host operations: view details, edit, delete, copy (with -copy1 suffix)
- Search/filter hosts by pattern
- Bulk operations: export list, timestamped backup, batch delete
- Automatic backup before any modification
- Classic --edit mode preserved for direct editor access

#### Code Quality
- Removed Jellyfin bias - replaced with Pi-hole examples
- All version scripts now update VERSION file
- Dynamic version display in homelab menu (reads from VERSION)
- Translated remaining Dutch text to English
- Centralized constants in `lib/constants.sh` with `UNSUPPORTED_SYSTEMS` array

### 🐛 Bug Fixes

#### v3.6.0-dev.21 (Current)
- Fixed install.sh .bashrc escape codes (single quotes → echo -e)
- Fixed install.sh duplicate Homelab entries in .bashrc
- Fixed test-runner.sh progress counter (72 tests, not 80)
- All 72 tests now pass with 100% success rate

#### v3.6.0-dev.20
- Fixed missing title arguments in edit-hosts show_arrow_menu calls (3 locations)
  - Host Options menu, Bulk Operations menu, Select Host menu
- Fixed list-templates --view using wrong function (choose_menu → show_arrow_menu)
- Fixed delete-template --help escape codes not displaying (heredoc → echo -e)

#### v3.6.0-dev.19
- Fixed edit-hosts hanging on startup (missing title argument to show_arrow_menu)
- show_arrow_menu requires title as first parameter; edit-hosts was calling without title
- Now properly displays interactive menu with all host options
- Menu works correctly: arrow navigation, selection, q=quit

#### v3.6.0-dev.18
- Identified root cause: banner prompt on Update installation
- Sed removes banner block before grep checks for HLT_BANNER
- Solution: Save HLT_BANNER before cleanup, skip prompt if already configured
- Added TODO for fix implementation

#### v3.6.0-dev.17
- Complete CHANGELOG documentation for all v3.6.0-dev commits (dev.1-dev.17)
- Full audit of 5 days development work

#### v3.6.0-dev.16
- Fixed symlink resolution in `edit-hosts` and `list-templates --view`
- Prevents "Bestand of map bestaat niet" error when called via ~/.local/bin symlinks
- Consistent BASH_SOURCE symlink handling across all commands (resolves symlinks before sourcing lib/)

#### v3.6.0-dev.15
- Non-interactive `generate-motd` support for stdin input
- Complete English translation of remaining Dutch user-facing text in deploy-motd:
  - Usage/Example/Validation messages
  - SSH connection check messages
- Centralized constants in `lib/constants.sh`
- Create minimal MOTD templates from stdin (Web UI y/n + port)

#### v3.6.0-dev.14
- Add lib/constants.sh for shared UNSUPPORTED_SYSTEMS array
- Source constants in generate-motd for detection logic

#### v3.6.0-dev.13
- Enhanced edit-hosts with full interactive SSH config manager
- Interactive host menu with arrow key navigation
- Add host wizard with validation
- Bulk operations: export, backup, batch delete

#### v3.6.0-dev.12
- Archive redundant version scripts (bump-version.sh, update-version.sh to .archive/)
- Translate all Dutch text to English in scripts and comments

#### v3.6.0-dev.11
- Archive redundant version scripts per consolidation plan
- All version references now dynamic via lib/version.sh

#### v3.6.0-dev.10
- Fix undeploy-motd mismatch: removes `/etc/profile.d/00-motd.sh` (not 99-homelab-*.sh)
- Adjust undeploy-motd help text and messages

#### v3.6.0-dev.9
- Centralize version display system
- Ensure bin/homelab shows version via lib/version.sh
- Remove hardcoded versions in headers ("See VERSION file")

#### v3.6.0-dev.8
- Add deploy-motd debug connection option
- Improve error messages (English)

#### v3.6.0-dev.7
- Add undeploy-motd script for removing MOTDs
- Single host: `undeploy-motd <hostname>`
- Bulk removal: `undeploy-motd --all`

#### v3.6.0-dev.6
- Fix version mismatch in VERSION file
- Add comprehensive testing guide structure

#### v3.6.0-dev.5
- Translate deploy-motd strings to English
- Translate generate-motd comments to English

#### v3.6.0-dev.4
- Update TODO to mark audit items as complete
- Archive bump-version.sh and update-version.sh to .archive/

#### v3.6.0-dev.3
- Add lib/constants.sh for shared constants
- Source in generate-motd for detection rules

#### v3.6.0-dev.2
- Non-interactive generate-motd via stdin/heredoc
- Syntax validation across all scripts (bash -n)

#### v3.6.0-dev.1
- Repository audit and cleanup (2025-12-14)
- Archive redundant version management scripts
- Centralize version display and management
- Remove Jellyfin examples, replace with Pi-hole
- Complete Dutch → English translation

---

## v3.5.0 (Released 2025-12-14)

After v3.4.0 release, multiple critical bugs were discovered. Development was rolled back to the `develop` branch for systematic bugfixing before the next stable release.

### 🐛 Bug Fixes

#### Installation & Configuration
- **dev.1** - Initial development build numbering system with bump-dev.sh
- **dev.2** - Add run_sudo helper for root environments (container compatibility)
- **dev.3** - Fix config.sh creation using temp file + proper sudo handling
- **dev.4** - Fix templates directory ownership for actual user (not root)

#### Bulk Generate & Loop Issues
- **dev.5** - Remove conflicting stdin redirection in bulk-generate
- **dev.6** - Replace `(())` arithmetic with `$(())`, fixes bulk-generate loop hang
- **dev.11** - Replace all remaining `(())` arithmetic - fixes copykey & cleanup-keys loops

#### Uninstall Improvements
- **dev.7** - Improve bashrc cleanup + add backup removal option
- **dev.8** - Simplify with numbered defaults (1/2) + fix backup removal
- **dev.10** - Add remote MOTD removal option + fix menu borders

#### MOTD Generation
- **dev.9** - Remove duplicate help output + fix config write permissions + default hostname
- **dev.12** - Fix grep exit code causing script hang with `set -e` (plex and others)
- **dev.13** - Skip Home Assistant detection (Docker incompatible)
- **dev.14** - Add global unsupported systems list for better service detection

#### Installation & Migration
- **dev.23** - Add VERSION file for centralized version management
- **dev.23** - Detect and handle legacy ~/homelab-tools installations with user choice
- **dev.23** - Clean up old homelab-tools references in .bashrc (keep .ssh untouched)
- **dev.23** - Add optional ASCII welcome banner with version info (HLT_BANNER=0 to disable)
- **dev.23** - Convert all Dutch text to English in install.sh (complete)

#### Internationalization
- **dev.23** - Add i18n roadmap to TODO.md (support for en/nl/de/fr/es planned)

#### Security & Privacy
- **dev.23** - Create SECURITY.md with security policy and responsible disclosure
- **dev.23** - Remove broken reference to claude.md from README
- **dev.23** - Add security warning to config.sh.example (DO NOT commit sensitive data)
- **dev.23** - Translate config.sh.example comments to English
- **dev.23** - Audit example configs (all safe - only generic usernames)

#### Uninstall & Migration
- **dev.23** - Complete English translation of uninstall.sh
- **dev.23** - Improve uninstall.sh flow and user prompts
- **dev.23** - Mark migrate-to-opt.sh for removal (functionality now in install.sh)

### ✨ New Features (dev.24)

#### Interactive Menu System
- **dev.24** - Fix arrow key navigation in xfce4-terminal (read from /dev/tty)
- **dev.24** - Fix timeout handling with set -e (proper set +e around read)
- **dev.24** - Add global MENU_RESULT variable to avoid subshell issues
- **dev.24** - Add q=cancel support to all user input prompts
- **dev.24** - Add wait_for_continue helper with q=back option

#### Configuration Menu
- **dev.24** - Add Uninstall option to Configuration menu
- **dev.24** - Update Configuration help with Uninstall documentation

#### Installation & Cleanup
- **dev.24** - Add duplicate HLT section detection in .bashrc
- **dev.24** - Skip adding sections if already present (PATH, tip, banner)
- **dev.24** - Clean up duplicate tip lines on re-install
- **dev.24** - Always create backup before .bashrc modifications

#### Code Cleanup
- **dev.24** - Remove migrate-to-opt.sh (integrated into install.sh)
- **dev.24** - Remove .todos.md (superseded by TODO.md)
- **dev.24** - Remove config/hosts.txt.example (obsolete, using ~/.ssh/config)
- **dev.24** - Remove config/server-motd/test.sh (obsolete test template)
- **dev.24** - Fix all ShellCheck warnings (unused vars, non-constant source)
- **dev.24** - Add shellcheck directives for false positives

### 📝 Documentation (dev.24)
- **dev.24** - Complete file audit in TODO.md with status for all files
- **dev.24** - Mark completed HIGH PRIORITY items
- **dev.24** - Document all removed/obsolete files

### 📝 Changes from Previous Session
- Version display in install menu (version/branch/date)
- Bashrc tip now works correctly with sudo user detection
- ASCII art preview menu in bulk-generate
- All menu choices changed from letters (A/D/Y/N) to numbers (1/2/3)
- Bulk-generate no longer stops after first server

---

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
