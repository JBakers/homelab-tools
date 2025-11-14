# 🏠 Homelab Management Tools v3.1

Professional command-line tools for managing your homelab with stylish, colorful interfaces and intelligent automation.

## ✨ Features

- 🎯 **Auto-Detection** - Recognizes 60+ popular homelab services automatically
- 🌈 **Rainbow ASCII Art** - Beautiful centered banners with toilet -F gay
- ⚡ **Bulk Operations** - Generate and deploy MOTDs for all hosts at once
- 🔧 **SSH Setup Wizard** - Automated SSH key generation and configuration
- 📝 **MOTD Generator** - Create dynamic MOTDs with smart defaults
- 🚀 **One-click Deploy** - Deploy MOTDs directly to your hosts
- 🔑 **SSH Key Distribution** - Distribute SSH keys to all servers
- 🧹 **Host Key Management** - Clean up old host keys easily with interactive menu
- 📄 **Template Management** - Overview of all your MOTD templates
- 💡 **Extensive  Help** - Every command has `--help` documentation

## 📦 Installation

### Quick Install (Recommended)

```bash
# 1. Clone or download to your home directory
cd ~
git clone <your-repo-url> homelab-tools
# OR: scp -r /path/to/homelab-tools/ <your-server>:~/

# 2. Run the installation script
cd homelab-tools
./install.sh
```

The installer will:
- Copy files to `~/homelab-tools/`
- Add to your PATH
- Create templates directory at `~/.local/share/homelab-tools/templates/`
- Set executable permissions

### Manual Installation

```bash
# 1. Ensure homelab-tools directory exists in ~/
cd ~
# make sure homelab-tools directory exists

# 2. Add to PATH
echo 'export PATH="$HOME/homelab-tools/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 3. Test
homelab
```

## 🎮 Usage

### Interactive Menu

Start the coloured menu:
```bash
homelab
```

This displays:
```
╔════════════════════════════════════════════════════════════╗
║           🏠 HOMELAB MANAGEMENT TOOLS v2.0              ║
║                    by J.Bakers                           ║
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

### Direct Commands

All commands can also be used directly:

```bash
# Generate MOTD for a service
generate-motd jellyfin

# Deploy to container
deploy-motd jellyfin

# List all templates
list-templates

# Clean up SSH keys after rebuild
cleanup-keys jellyfin
# or
cleanup-keys 192.168.1.30

# Distribute SSH keys to all servers
copykey
```

### Help  for Each Command

```bash
homelab help
generate-motd --help
deploy-motd --help
cleanup-keys --help
list-templates --help
copykey --help
```

## 📝 Workflow Example: New Container

```bash
# 1. Create MOTD
generate-motd frigate
> Service name: Frigate
> Description: Network Video Recorder
> Web UI? y
> Port: 5000

# 2. If there are SSH key conflicts
cleanup-keys frigate

# 3. Deploy
deploy-motd frigate

# 4. Test
ssh frigate
```

## �� Requirements

- `bash` - Bourne Again Shell
- `ssh` - SSH client
- `toilet` - For ASCII art in MOTDs (optional but recommended)

Install on Debian/Ubuntu:
```bash
sudo apt install ssh toilet toilet-fonts
```

## 📁 Project Structure

```
homelab-tools/
├── bin/                    # Executable scripts
│   ├── homelab            # Main interactive menu
│   ├── generate-motd      # MOTD generator
│   ├── deploy-motd        # MOTD deployment
│   ├── cleanup-keys       # SSH key cleanup
│   ├── list-templates     # Template overview
│   └── copykey            # SSH key distributor
├── install.sh            # Installation script
├── uninstall.sh          # Uninstallation script
├── QUICKSTART.md         # Quick start guide
└── README.md             # This file
```

Note: Templates are stored in `~/.local/share/homelab-tools/templates/` (not in this directory)

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
  HostName 192.168.1.30
  User root

Host jellyfin
  HostName 192.168.1.25
  User root
  
Host pihole
  HostName 192.168.1.3
  User root
```

Then use: `ssh frigate`

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| `command not found: homelab` | `source ~/.bashrc` |
| SSH connection fails | Check SSH config, test with `ssh <host> echo test` |
| Host key warning | `cleanup-keys <host>` |
| MOTD not visible | Log out completely and log back in |
| No colors | Check terminal ANSI support |
| No ASCII art | `sudo apt install toilet` (optional) |

## 💡 Tips & Tricks

**Re-deploy**: You can reuse templates, just run `deploy-motd <service>` again

**Edit template**: Edit `~/.local/share/homelab-tools/templates/<service>.sh` and redeploy

**Bulk deploy**:
```bash
for service in jellyfin pihole frigate; do
    deploy-motd $service
done
```

**Backup templates**:
```bash
tar -czf templates-backup.tar.gz ~/.local/share/homelab-tools/templates/
```

## 📜 License

MIT License - Made by J.Bakers

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📚 Documentation

- See [QUICKSTART.md](QUICKSTART.md) for a quick start guide
- Use `--help` flag on any command for detailed usage

---

**Happy homelab managing!** 🏠✨
