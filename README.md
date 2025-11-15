# 🏠 Homelab Management Tools v3.4.0 

[![Version](https://img.shields.io/badge/version-3.4.0-blue.svg)](https://github.com/JBakers/homelab-tools/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-lightgrey.svg)](https://www.gnu.org/software/bash/)

> **Professional command-line toolkit for managing homelab infrastructure with beautiful, colorful interfaces and intelligent automation.**

Streamline your homelab management with auto-detecting MOTD generators, bulk operations, and SSH tooling - all with a stunning terminal UI.

## ✨ Features

### 🎯 Smart Detection

- **60+ Services Auto-Detected** - Jellyfin, Plex, *arr stack, Pi-hole, Home Assistant, and more
- **Intelligent Defaults** - Automatic service names, descriptions, and port configurations
- **Custom Services** - Easy fallback for any custom application

### 🎨 Beautiful Interface

- **Clean & Functional MOTDs** - Professional login screens with system info (default)
- **Optional ASCII Art** - 5 colorful styles including rainbow banners with `toilet -F gay`
- **Color-Coded Output** - Clear visual feedback with ANSI colors
- **Interactive Menus** - Intuitive TUI for all operations

### ⚡ Automation & Efficiency

- **Bulk Operations** - Generate and deploy MOTDs for all hosts at once
- **One-Click Deploy** - SSH-based deployment to remote hosts
- **Template System** - Reusable, customizable MOTD templates

### 🔐 SSH Management

- **Setup Wizard** - Automated SSH key generation and configuration
- **Key Distribution** - Push keys to all servers automatically
- **Host Key Cleanup** - Interactive tool for managing known_hosts

### 📚 Developer Experience

- **Comprehensive Help** - Every command has detailed `--help` documentation
- **Error Handling** - Robust error checking with `set -euo pipefail`
- **Input Validation** - Protection against command injection attacks

## 📦 Installation

### 🚀 Quick Install (Recommended)

```bash
# Clone the repository
cd ~
git clone https://github.com/JBakers/homelab-tools.git

# Run the installer (requires sudo for /opt installation)
cd homelab-tools
sudo ./install.sh

# Reload your shell
source ~/.bashrc
```

**What the installer does:**

- ✅ Sets up `~/homelab-tools/` directory structure
- ✅ Adds commands to your `PATH` via `~/.bashrc`
- ✅ Creates templates directory at `~/.local/share/homelab-tools/templates/`
- ✅ Configures executable permissions
- ✅ Optionally sets up SSH keys and config
- ✅ Configures domain suffix for your homelab

### ⚙️ Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

```bash
# 1. Clone to temporary location
cd /tmp
git clone https://github.com/JBakers/homelab-tools.git
cd homelab-tools

# 2. Copy to /opt (requires sudo)
sudo mkdir -p /opt/homelab-tools
sudo cp -r * /opt/homelab-tools/

# 3. Create symlinks
for cmd in /opt/homelab-tools/bin/*; do
    sudo ln -sf "$cmd" /usr/local/bin/$(basename "$cmd")
done

# 4. Create templates directory
mkdir -p ~/.local/share/homelab-tools/templates

# 5. Set permissions
sudo chmod +x /opt/homelab-tools/bin/*
sudo chmod +x /opt/homelab-tools/*.sh

# 6. Test installation
homelab
```

</details>

---

## 🚀 Quick Start

**Get up and running in 60 seconds:**

```bash
# 1. Generate MOTD for your service
generate-motd jellyfin
# Auto-detects: "Jellyfin - Media Server" with port 8096

# 2. Deploy to your host
deploy-motd jellyfin
# Uploads via SSH and activates MOTD

# 3. Test it!
ssh jellyfin
# See your beautiful new MOTD!
```

**That's it!** The tool auto-detected the service, created a template, and deployed it.

## 🎨 MOTD Styles

The tool offers clean, functional MOTDs by default, with optional ASCII art for a more colorful look.

### Clean & Functional (Default)

**Professional, informative, and always readable:**

```
==========================================
  Jellyfin
  Media Server
  by J.Bakers
==========================================

📊 System Information:

  🖥️  Hostname:    jellyfin
  🌐 IP Address:  192.168.1.10
  ⏱️  Uptime:      3 days, 12 hours
  🐋 Docker:      24.0.7
  🔗 Web UI:      http://jellyfin:8096

==========================================
```

### Optional ASCII Art Styles

<details>
<summary><strong>Click to view ASCII art examples</strong></summary>

**1. Rainbow Future** (Colorful, modern)
**2. Rainbow Standard** (Colorful, classic)
**3. Mono Future** (Black & white, modern)
**4. Big Mono** (Large, bold)
**5. Small/Smblock** (Compact)

Choose during generation with `generate-motd <service>`, or press 'p' for a live preview.

**Example Rainbow Future:**

```
     ███████╗███████╗██╗     ██╗  ██╗   ██╗███████╗██╗███╗   ██╗
     ██╔════╝██╔════╝██║     ██║  ╚██╗ ██╔╝██╔════╝██║████╗  ██║
     █████╗  █████╗  ██║     ██║   ╚████╔╝ █████╗  ██║██╔██╗ ██║
     ██╔══╝  ██╔══╝  ██║     ██║    ╚██╔╝  ██╔══╝  ██║██║╚██╗██║
     ███████╗███████╗███████╗███████╗██║   ██║   ██║██║ ╚████║
     ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝
                                                    (in rainbow colors!)
        Media Server
           by J.Bakers

==========================================
   📊 System Information:
...
```

</details>

## 🎮 Usage

### 📋 Interactive Menu

Launch the main menu for guided operations:

```bash
homelab
```

<details>
<summary>View menu screenshot</summary>

```
╔════════════════════════════════════════════════════════════╗
║           🏠 HOMELAB MANAGEMENT TOOLS v3.4.0               ║
║                    by J.Bakers                             ║
╚════════════════════════════════════════════════════════════╝

Available commands:

  1) generate-motd     - Generate a new MOTD
  2) deploy-motd       - Deploy MOTD to container
  3) cleanup-keys      - Remove old SSH keys
  4) list-templates    - View all templates
  5) copykey           - Distribute SSH keys
  
  h) help              - Detailed help
  q) quit              - Exit
```

</details>

### 💻 Direct Commands

All commands are available directly in your terminal:

| Command | Description | Example |
|---------|-------------|----------|
| `generate-motd` | Create MOTD template | `generate-motd plex` |
| `bulk-generate-motd` | Generate for all hosts | `bulk-generate-motd` |
| `deploy-motd` | Deploy to remote host | `deploy-motd pihole` |
| `cleanup-keys` | Remove SSH host keys | `cleanup-keys jellyfin` |
| `copykey` | Distribute SSH keys | `copykey` |
| `list-templates` | Show all templates | `list-templates` |
| `edit-hosts` | Edit SSH config | `edit-hosts` |
| `edit-config` | Edit homelab config | `edit-config` |

### 📖 Built-in Help

Every command has comprehensive help documentation:

```bash
generate-motd --help    # Detailed usage and examples
deploy-motd -h          # Quick reference
homelab help            # Full documentation
```

## 📝 Complete Workflow Examples

### 🆕 Setting Up a New Container

```bash
# Step 1: Generate MOTD (auto-detected!)
generate-motd frigate
# ✓ Auto-detected: Frigate - NVR with AI Detection
# ✓ Web UI: http://frigate:5000
# Customize? (y/N): n
# Deploy now? (Y/n): y

# Step 2: If SSH host key conflicts occur
cleanup-keys frigate
# ✓ Keys removed for: frigate

# Step 3: Verify the deployment
ssh frigate
# Beautiful MOTD appears!
```

### 🔄 Rebuilding a Container

```bash
# After container rebuild, fix SSH keys and redeploy
cleanup-keys myservice
deploy-motd myservice
```

### 📦 Bulk Setup for Multiple Hosts

```bash
# Generate and deploy MOTDs for all hosts at once
bulk-generate-motd
# Scans ~/.ssh/config for all hosts
# Generates templates for each
# Option to deploy all at once
```

### 🔑 Initial SSH Setup

```bash
# First-time setup: distribute your SSH key to all servers
copykey
# Reads hosts from ~/.ssh/config
# Copies your public key to each server
# Enables passwordless login
```

## 📋 Requirements

### Required

- **bash** 4.0+ - Bourne Again Shell
- **ssh** - OpenSSH client
- **coreutils** - Standard GNU utilities (grep, sed, awk, etc.)

### Optional

- **toilet** - For ASCII art in MOTDs (5 colorful styles available)
- **toilet-fonts** - Additional ASCII art fonts

**Note:** The tool works perfectly without `toilet` - it will use clean, functional MOTDs by default.

### Installation

**Debian/Ubuntu:**

```bash
sudo apt update
sudo apt install ssh toilet toilet-fonts
```

**RHEL/CentOS/Fedora:**

```bash
sudo dnf install openssh-clients toilet
```

**Arch Linux:**

```bash
sudo pacman -S openssh toilet
```

**macOS:**

```bash
brew install toilet
```

## 📁 Project Structure

```
homelab-tools/
├── 📂 bin/                        # Executable commands
│   ├── 🏠 homelab                # Main interactive menu
│   ├── 📝 generate-motd          # MOTD generator (60+ services)
│   ├── 📦 bulk-generate-motd     # Bulk MOTD generation
│   ├── 🚀 deploy-motd            # MOTD deployment via SSH
│   ├── 🧹 cleanup-keys           # SSH host key cleanup
│   ├── 🔑 copykey                # SSH key distribution
│   ├── 📄 list-templates         # Template overview
│   ├── ⚙️  edit-config            # Edit homelab config
│   └── 🔧 edit-hosts             # Edit SSH config
│
├── 📂 config/                     # Example configurations
│   ├── hosts.txt.example         # Example hosts file
│   ├── ssh-config.example        # Example SSH config
│   └── server-motd/              # Server-side MOTD scripts
│
├── 🛠️  install.sh                # Installation script
├── 🗑️  uninstall.sh              # Uninstallation script
├── 📦 export.sh                  # Export/backup tool
├── 📖 README.md                  # This file
├── 🚀 QUICKSTART.md              # Quick start guide
├── 📋 CHANGELOG.md               # Version history
└── 📜 LICENSE                    # MIT License
```

**User Data Locations:**

- Templates: `~/.local/share/homelab-tools/templates/`
- Config: `~/homelab-tools/config.sh`
- SSH Config: `~/.ssh/config`

## 🎨 Color Customization

The tools use these color codes (editible in each script):

```bash
CYAN='\033[0;36m'     # Cyan
BLUE='\033[0;34m'     # Blue
GREEN='\033[0;32m'    # Green
YELLOW='\033[1;33m'   # Yellow (bold)
RED='\033[0;31m'      # Red
MAGENTA='\033[0;35m'  # Magenta
```

## 🔒 SSH Configuration

Add entries to `~/.ssh/config`:

```
Host frigate
  HostName 192.168.178.30
  User root

Host jellyfin
  HostName 192.168.178.25
  User root
  
Host pihole
  HostName 192.168.178.3
  User root
```

Then use: `ssh frigate`

## 🐛 Troubleshooting

<details>
<summary><strong>Command not found: homelab</strong></summary>

**Problem:** Shell can't find the commands after installation.

**Solution:**

```bash
# Reload your shell configuration
source ~/.bashrc

# Or start a new terminal session
```

**Verify PATH:**

```bash
echo $PATH | grep homelab
# Should show: /home/youruser/homelab-tools/bin
```

</details>

<details>
<summary><strong>SSH connection fails</strong></summary>

**Problem:** Can't connect to remote host.

**Diagnosis:**

```bash
# Test basic SSH connectivity
ssh -v yourhost echo "test"

# Check SSH config
cat ~/.ssh/config | grep -A 3 "Host yourhost"
```

**Common fixes:**

- Verify host is online: `ping yourhost`
- Check SSH config syntax: `ssh -G yourhost`
- Verify SSH keys: `ssh-add -l`

</details>

<details>
<summary><strong>Host key verification failed</strong></summary>

**Problem:** SSH complains about changed host keys (after container rebuild).

**Solution:**

```bash
# Remove old host key
cleanup-keys yourhost

# Or manually
ssh-keygen -R yourhost
```

</details>

<details>
<summary><strong>MOTD not visible after deployment</strong></summary>

**Problem:** MOTD doesn't appear when SSHing.

**Checklist:**

1. Log out completely: `exit` (not just close terminal)
2. Log back in: `ssh yourhost`
3. Check file exists: `ssh yourhost "ls -la /etc/profile.d/00-motd.sh"`
4. Check permissions: `ssh yourhost "test -x /etc/profile.d/00-motd.sh && echo OK"`

**Manual fix:**

```bash
ssh yourhost
sudo chmod +x /etc/profile.d/00-motd.sh
exit
ssh yourhost  # Try again
```

</details>

<details>
<summary><strong>No colors in output</strong></summary>

**Problem:** Terminal shows escape codes instead of colors.

**Solution:**

- Use a terminal with ANSI color support (most modern terminals)
- Check `TERM` variable: `echo $TERM`
- Try: `export TERM=xterm-256color`

</details>

<details>
<summary><strong>Want ASCII art in your MOTD?</strong></summary>

**By default, MOTDs use a clean, functional style.** To use ASCII art:

```bash
# Install toilet (optional)
sudo apt install toilet toilet-fonts

# Generate MOTD and choose ASCII style (2-6)
generate-motd yourservice
# When prompted, select option 2-6 for ASCII art
# Or press 'p' to preview all styles

# Deploy
deploy-motd yourservice
```

**Available ASCII styles:** Rainbow Future, Rainbow Standard, Mono Future, Big Mono, Small/Smblock

</details>

### 💬 Still having issues?

1. Check the [QUICKSTART.md](QUICKSTART.md) guide
2. Review command help: `<command> --help`
3. Open an issue on [GitHub](https://github.com/JBakers/homelab-tools/issues)

## 🔒 Security

**This toolkit implements several security best practices:**

### Input Validation

- ✅ All user inputs validated with regex patterns
- ✅ Protection against command injection attacks
- ✅ Hostname and service name sanitization

### Error Handling

- ✅ All scripts use `set -euo pipefail`
- ✅ Exit on undefined variables
- ✅ Exit on command failures
- ✅ Proper error messages and exit codes

### SSH Security

- ✅ Uses modern ed25519 keys by default
- ✅ No passwords stored or transmitted
- ✅ SSH config validation
- ✅ Host key verification support

### Permissions

- ✅ Templates stored in user's home directory
- ✅ No root access required for installation
- ✅ Remote sudo usage only when necessary
- ✅ Proper file permissions (600 for SSH keys, 700 for directories)

**Security Audit:** See [claude.md](claude.md) for the complete security review.

---

## 💡 Tips & Tricks

### 🔄 Redeploying Templates

Templates are reusable - update and redeploy anytime:

```bash
# Edit the template
nano ~/.local/share/homelab-tools/templates/jellyfin.sh

# Redeploy
deploy-motd jellyfin
```

### 📦 Bulk Operations

Process multiple services efficiently:

```bash
# Deploy multiple services
for service in jellyfin plex sonarr radarr; do
    deploy-motd $service
done

# Or use the bulk generator
bulk-generate-motd  # Processes all hosts in SSH config
```

### 💾 Backup Your Templates

Keep your customizations safe:

```bash
# Create backup
tar -czf ~/motd-backup-$(date +%F).tar.gz ~/.local/share/homelab-tools/templates/

# Or use the export tool
./export.sh  # Creates timestamped archive
```

### 🎨 Customize Colors

Edit color codes in any script:

```bash
# Open script for editing
nano ~/homelab-tools/bin/generate-motd

# Find color definitions (top of file)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
# ... modify as needed
```

### 🔗 SSH Config Organization

Keep your SSH config tidy:

```bash
# Add comments for organization
edit-hosts

# Example structure:
# --- Media Servers ---
Host jellyfin
  HostName 192.168.1.10
  User root

Host plex
  HostName 192.168.1.11
  User root

# --- Network Services ---
Host pihole
  HostName 192.168.1.3
  User root
```

### ⚡ Shell Aliases

Add to `~/.bashrc` for quick access:

```bash
alias gm='generate-motd'
alias dm='deploy-motd'
alias hl='homelab'
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

- 🐛 **Report bugs** - Open an issue with details
- 💡 **Suggest features** - Share your ideas
- 📝 **Improve documentation** - Fix typos, add examples
- 🔧 **Submit PRs** - Add new service definitions, improve code

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes
- **[RELEASE_NOTES_v3.0.md](RELEASE_NOTES_v3.0.md)** - What's new in v3.0
- **Built-in help** - `<command> --help` for any command

## 📜 License

MIT License © 2025 J.Bakers

See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- **toilet** - For awesome ASCII art rendering
- **Homelab community** - For inspiration and feedback
- **Claude (Sonnet 4.5)** - AI assistance with code review and security audit

## ⭐ Show Your Support

If you find this tool useful:

- ⭐ Star this repository
- 🐛 Report bugs and suggest features
- 📢 Share with the homelab community
- ☕ [Buy me a coffee](https://github.com/sponsors/JBakers) (if applicable)

---

<div align="center">

**Happy Homelab Managing!** 🏠✨

Made with ❤️ by [J.Bakers](https://github.com/JBakers)

[⬆ Back to Top](#-homelab-management-tools)

</div>
