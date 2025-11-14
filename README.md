# Homelab Tools

A collection of Bash scripts for homelab management and automation.

## Installation

```bash
cd install
./install.sh
```

Add to your `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Available Commands

- `homelab` - Show overview of all available tools
- `generate-motd <hostname>` - Generate MOTD template for a host
- `deploy-motd` - Deploy MOTD banners to servers
- `copykey` - Distribute SSH keys to all servers
- `cleanup-homelab` - Clean up orphaned MOTD templates

## Configuration

Configuration files are stored in `~/.config/homelab-tools/`:
- `server-motd/` - MOTD templates per service type
- `hosts.txt` - List of homelab hosts (one per line)

## SSH Configuration

See `config/ssh-config.example` for an example SSH configuration.

## Usage

### MOTD Management

```bash
# Generate MOTD for a server
generate-motd plex

# Deploy to all servers
deploy-motd
```

### SSH Key Distribution

```bash
# Copy SSH keys to all servers in your SSH config
copykey
```

### Cleanup

```bash
# Scan and remove templates for servers no longer in SSH config
cleanup-homelab

# Show orphaned templates only
cleanup-homelab --orphaned

# Remove all orphaned templates without prompt
cleanup-homelab --remove
```

## MOTD Templates

The project includes pre-defined templates for:

- **Media Servers**: Plex, Radarr, Sonarr, Lidarr, Tautulli, Overseerr
- **Download Tools**: SABnzbd, Prowlarr
- **Infrastructure**: Proxmox, PBS (Backup Server), Docker Debian
- **Network**: Pi-hole, Uptime Kuma
- **IoT/Home Automation**: Zigbee2MQTT, EMQX
- **Security/Monitoring**: Frigate NVR
- **Gaming**: Minecraft, PocketMine, PowerNukkitX
- **Other**: AllSky Camera, Generic template

## Requirements

- `ssh` - SSH client
- `figlet` - For ASCII art in MOTD templates (optional)

Install with:
```bash
sudo apt install ssh figlet
```

## Project Structure

```
homelab-tools/
├── bin/                    # Executable scripts
│   ├── homelab            # Main command/help
│   ├── generate-motd      # MOTD generator
│   ├── deploy-motd        # MOTD deployment
│   ├── copykey            # SSH key distributor
│   └── cleanup-homelab    # Cleanup utility
├── config/                # Configuration files
│   ├── ssh-config.example # Example SSH config
│   ├── hosts.txt.example  # Example hosts list
│   └── server-motd/       # MOTD templates per service
├── install/               # Installation scripts
│   └── install.sh        # Installer
└── README.md             # This file
```

## License

Made by J.Bakers
