# Homelab Management Tools

A collection of scripts to easily manage your homelab infrastructure.

## Installation
```bash
cd homelab-tools/install
./install.sh
```

Choose your installation type:
- **Full installation**: Scripts + config templates
- **Scripts only**: Without MOTD templates (if you already have config)
- **Update**: Update scripts only

## Commands

### `homelab`
Shows an overview of all available commands.

### `generate-motd [hostname]`
Generates MOTD (Message of the Day) templates for your servers.

**Examples:**
```bash
generate-motd              # Scan all hosts without templates
generate-motd frigate      # Create template for specific host
```

### `deploy-motd`
Deploy MOTD templates to all your servers. The MOTD is generated **dynamically** at each login, ensuring information like uptime is always current.

### `copykey`
Copies your SSH keys to all servers in your SSH config.

### `cleanup-homelab`
Cleans up orphaned MOTD templates (templates for servers no longer in your SSH config).

**Options:**
```bash
cleanup-homelab              # Interactive mode
cleanup-homelab --orphaned   # Show list of orphaned templates
cleanup-homelab --remove     # Remove all orphaned templates
```

## Directory Structure
```
homelab-tools/
├── bin/              # All executable scripts
├── config/           # Configuration templates
│   ├── server-motd/  # MOTD templates per server
│   └── ssh-config.example
├── install/          # Installation scripts
└── README.md
```

## Requirements

- `bash`
- `ssh`
- `figlet` (for nice ASCII art in MOTD)

Install on Debian/Ubuntu:
```bash
sudo apt install figlet
```

## SSH Config

Your SSH config (`~/.ssh/config`) must contain hosts. Example:
```
Host proxmox
    HostName 192.168.1.100
    User root

Host frigate
    HostName 192.168.1.30
    User root
```

## Backup & Sync

This repository is already version controlled with Git. To keep it synced:

**Update from GitHub:**
```bash
cd ~/homelab-tools
git pull
```

**Make changes and push:**
```bash
cd ~/homelab-tools
# Make your changes...
git add .
git commit -m "Description of changes"
git push
```

**Clone on another machine:**
```bash
git clone git@github.com:JBakers/homelab-tools.git
cd homelab-tools/install
./install.sh
```

**Export as archive (for machines without git):**
```bash
cd ~/homelab-tools
./export.sh
# Copy the generated .tar.gz file to another machine
```

## Author

J.Bakers

## Version

1.0 - November 2025
