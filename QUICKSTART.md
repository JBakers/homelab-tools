# 🚀 Quick Start Guide

## Getting Started

```bash
# 1. Clone to your homelab
cd ~
git clone https://github.com/JBakers/homelab-tools.git

# 2. Install
cd homelab-tools
./install.sh
source ~/.bashrc

# 3. Launch!
homelab
```

## Most Used Commands

### Create MOTD for a new service
```bash
generate-motd pihole
# Answer the prompts
```

### Deploy MOTD
```bash
deploy-motd pihole
```

### Clean up SSH keys after rebuild
```bash
cleanup-keys pihole
# or
cleanup-keys 192.168.1.100
```

### View templates
```bash
list-templates
list-templates --status  # Shows deployment status
```

### Help
```bash
homelab help
generate-motd --help
deploy-motd --help
```

## Workflow: New Container

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

## SSH Config Example

Add to `~/.ssh/config` (or use `edit-hosts`):

```
Host frigate
  HostName 192.168.1.30
  User root

Host pihole
  HostName 192.168.1.100
  User root
  
Host plex
  HostName 192.168.1.50
  User root
```

Then just use `ssh frigate`!

## Troubleshooting Cheat Sheet

| Problem | Solution |
|---------|----------|
| `command not found: homelab` | `source ~/.bashrc` |
| SSH connection failed | Check SSH config, test with `ssh <host> echo test` |
| Host key warning | `cleanup-keys <host>` |
| MOTD not visible | Log out completely and log back in |
| No colors | Check terminal ANSI support |
| No ASCII art | `sudo apt install toilet` (optional) |

## Handige Aliases (optioneel)

Voeg toe aan `~/.bashrc`:

```bash
alias hl='homelab'
alias gm='generate-motd'
alias dm='deploy-motd'
alias ck='cleanup-keys'
alias lt='list-templates'
```

## Lokaal testen voordat je deploy

```bash
# Test script
./test.sh

# Test individuele commando
generate-motd test
cat templates/test.sh
```

## Tips & Tricks

1. **Re-deployen**: Je kunt templates hergebruiken, gewoon `deploy-motd <service>` opnieuw runnen

2. **Template aanpassen**: Edit `~/homelab-tools/templates/<service>.sh` en deploy opnieuw

3. **Bulk deploy**: 
   ```bash
   for service in jellyfin pihole frigate; do
       deploy-motd $service
   done
   ```

4. **Backup templates**:
   ```bash
   tar -czf templates-backup.tar.gz templates/
   ```

## Kleuren Aanpassen

Edit de kleur variabelen in de scripts:

```bash
CYAN='\033[0;36m'     # Cyan
BLUE='\033[0;34m'     # Blauw
GREEN='\033[0;32m'    # Groen
YELLOW='\033[1;33m'   # Geel
RED='\033[0;31m'      # Rood
MAGENTA='\033[0;35m'  # Magenta
```

Andere opties:
- `\033[0;31m` - Rood
- `\033[0;32m` - Groen
- `\033[0;33m` - Geel
- `\033[0;34m` - Blauw
- `\033[0;35m` - Magenta
- `\033[0;36m` - Cyan
- `\033[1;3Xm` - Bold versies

---

**Happy homelab managing!** 🏠✨
