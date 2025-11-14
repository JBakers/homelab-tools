# 🚀 Quick Start Guide

## Direct aan de slag

```bash
# 1. Download/clone naar je homelab
cd ~
# ... download homelab-tools ...

# 2. Installeer
cd homelab-tools
./install.sh
source ~/.bashrc

# 3. Start!
homelab
```

## Meest gebruikte commando's

### MOTD maken voor een nieuwe service
```bash
generate-motd jellyfin
# Beantwoord de vragen
```

### MOTD deployen
```bash
deploy-motd jellyfin
```

### SSH keys opruimen na rebuild
```bash
cleanup-keys jellyfin
# of
cleanup-keys 192.168.1.30
```

### Overzicht van templates
```bash
list-templates
```

### Help
```bash
homelab help
generate-motd --help
deploy-motd --help
```

## Workflow: Nieuwe Container

```bash
# 1. Maak MOTD
generate-motd frigate
> Service naam: Frigate
> Beschrijving: Network Video Recorder
> Web UI? j
> Poort: 5000

# 2. Als er SSH key conflicts zijn
cleanup-keys frigate

# 3. Deploy
deploy-motd frigate

# 4. Test
ssh frigate
```

## Handige SSH Config

Voeg toe aan `~/.ssh/config`:

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

Dan kun je gewoon `ssh frigate` gebruiken!

## Troubleshooting Cheat Sheet

| Probleem | Oplossing |
|----------|-----------|
| `command not found: homelab` | `source ~/.bashrc` |
| SSH connectie mislukt | Check SSH config, test met `ssh <host> echo test` |
| Host key warning | `cleanup-keys <host>` |
| MOTD niet zichtbaar | Log helemaal uit en weer in |
| Geen kleuren | Check terminal ANSI support |
| Geen ASCII art | `sudo apt install toilet` (optioneel) |

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
