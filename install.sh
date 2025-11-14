#!/bin/bash

# Installatie script voor Homelab Management Tools
# Author: J.Bakers

# Kleuren
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
echo -e "║         🏠 HOMELAB TOOLS - INSTALLATIE                  ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Check of we in de juiste directory zijn
if [[ ! -f "$(pwd)/bin/homelab" ]]; then
    echo -e "${RED}✗ Fout: Run dit script vanuit de homelab-tools directory${RESET}"
    echo -e "  ${YELLOW}cd ~/homelab-tools && ./install.sh${RESET}"
    exit 1
fi

INSTALL_DIR="$HOME/homelab-tools"

echo -e "${BOLD}Installatie directory: ${CYAN}$INSTALL_DIR${RESET}"
echo ""

# 1. Check of directory al bestaat
echo -e "${YELLOW}[1/4]${RESET} Controleer installatie..."
if [[ "$PWD" != "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}  →${RESET} Verplaats naar $INSTALL_DIR..."
    
    # Backup oude installatie
    if [[ -d "$INSTALL_DIR" ]]; then
        backup_dir="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}  →${RESET} Backup oude installatie naar $backup_dir"
        mv "$INSTALL_DIR" "$backup_dir"
    fi
    
    # Kopieer nieuwe bestanden
    mkdir -p "$HOME"
    cp -r "$(pwd)" "$INSTALL_DIR"
    echo -e "${GREEN}  ✓${RESET} Bestanden gekopieerd"
else
    echo -e "${GREEN}  ✓${RESET} Al in juiste directory"
fi
echo ""

# 2. Maak alle scripts executable
echo -e "${YELLOW}[2/4]${RESET} Configureer permissions..."
chmod +x "$INSTALL_DIR"/bin/* 2>/dev/null
chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null
echo -e "${GREEN}  ✓${RESET} Scripts zijn executable"
echo ""

# 3. Voeg toe aan PATH
echo -e "${YELLOW}[3/4]${RESET} Configureer PATH..."

# Check of al in bashrc staat
if grep -q "homelab-tools/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo -e "${GREEN}  ✓${RESET} PATH is al geconfigureerd in ~/.bashrc"
else
    echo "" >> "$HOME/.bashrc"
    echo "# Homelab Management Tools" >> "$HOME/.bashrc"
    echo "export PATH=\"\$HOME/homelab-tools/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo -e "${GREEN}  ✓${RESET} PATH toegevoegd aan ~/.bashrc"
fi
echo ""

# 4. Maak templates directory
echo -e "${YELLOW}[4/5]${RESET} Initialiseer templates..."
mkdir -p "$INSTALL_DIR/templates"
echo -e "${GREEN}  ✓${RESET} Templates directory aangemaakt"
echo ""

# 5. Configuratie
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}           ⚙️  HOMELAB CONFIGURATIE                      ${RESET}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo ""

CONFIG_FILE="$INSTALL_DIR/.config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}→${RESET} Configureer domein instellingen..."
    echo ""
    echo -e "  Wat is je homelab domein suffix?"
    echo -e "  ${CYAN}Voorbeelden:${RESET}"
    echo -e "    .home  → http://jellyfin.home:8096"
    echo -e "    .local → http://jellyfin.local:8096"
    echo -e "    (leeg) → http://jellyfin:8096"
    echo ""
    
    while true; do
        read -p "  Domein suffix (bijv. .home): " domain_suffix
        domain_suffix=${domain_suffix:-.home}
        
        # Validate domain starts with dot if not empty
        if [[ -n "$domain_suffix" ]] && [[ ! "$domain_suffix" =~ ^\. ]]; then
            echo -e "  ${RED}✗ Domein moet beginnen met een punt (bijv. .home)${RESET}"
            echo -e "  ${YELLOW}Of druk Enter voor geen domein${RESET}"
            continue
        fi
        break
    done
    
    cat > "$CONFIG_FILE" << EOF
# Homelab Tools Configuration
# Author: J.Bakers
# Version: 3.0

# Domain suffix voor je homelab
# Wordt gebruikt voor Web UI URLs
DOMAIN_SUFFIX="$domain_suffix"

# IP detectie methode
# Opties: "hostname" of "ip"
IP_METHOD="ip"
EOF
    
    echo -e "${GREEN}  ✓${RESET} Configuratie opgeslagen: ${CYAN}$domain_suffix${RESET}"
else
    echo -e "${GREEN}  ✓${RESET} Configuratie bestaat al"
    source "$CONFIG_FILE"
    echo -e "    Domein: ${CYAN}${DOMAIN_SUFFIX}${RESET}"
fi
echo ""

# 6. SSH Setup
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}           🔑 SSH CONFIGURATIE                           ${RESET}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo ""

SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SSH_KEY="$SSH_DIR/id_ed25519"

# Check of .ssh directory bestaat
if [[ ! -d "$SSH_DIR" ]]; then
    echo -e "${YELLOW}⚠ SSH directory niet gevonden${RESET}"
    echo ""
    read -p "SSH setup aanmaken? (Y/n): " setup_ssh
    setup_ssh=${setup_ssh:-y}
    
    if [[ "$setup_ssh" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Aanmaken van ~/.ssh directory..."
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
        echo -e "${GREEN}✓${RESET} Directory aangemaakt"
        echo ""
    fi
fi

# Check of er SSH keys zijn
if [[ -d "$SSH_DIR" ]] && [[ ! -f "$SSH_KEY" ]] && [[ ! -f "$SSH_DIR/id_rsa" ]]; then
    echo -e "${YELLOW}⚠ Geen SSH keys gevonden${RESET}"
    echo ""
    read -p "SSH key genereren? (Y/n): " gen_key
    gen_key=${gen_key:-y}
    
    if [[ "$gen_key" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Genereren van SSH key (ed25519)..."
        read -p "Email voor SSH key: " ssh_email
        
        if [[ -n "$ssh_email" ]]; then
            ssh-keygen -t ed25519 -C "$ssh_email" -f "$SSH_KEY" -N ""
            echo -e "${GREEN}✓${RESET} SSH key gegenereerd: $SSH_KEY"
            echo -e "${GREEN}✓${RESET} Public key: ${SSH_KEY}.pub"
            echo ""
            echo -e "${BOLD}Je public key:${RESET}"
            cat "${SSH_KEY}.pub"
            echo ""
        else
            echo -e "${RED}✗${RESET} Geen email opgegeven, key niet gegenereerd"
        fi
    fi
fi

# Check of SSH config bestaat
if [[ -d "$SSH_DIR" ]] && [[ ! -f "$SSH_CONFIG" ]]; then
    echo -e "${YELLOW}⚠ SSH config niet gevonden${RESET}"
    echo ""
    read -p "SSH config aanmaken? (Y/n): " create_config
    create_config=${create_config:-y}
    
    if [[ "$create_config" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Aanmaken van ~/.ssh/config..."
        
        cat > "$SSH_CONFIG" << 'EOF'
# SSH Configuration for Homelab
# Beheer met: edit-hosts

# Voorbeeld host configuratie:
# Host jellyfin
#     HostName 192.168.1.100
#     User youruser
#     Port 22
#     IdentityFile ~/.ssh/id_ed25519

EOF
        chmod 600 "$SSH_CONFIG"
        echo -e "${GREEN}✓${RESET} SSH config aangemaakt"
        echo ""
        echo -e "${BOLD}Wil je nu hosts toevoegen?${RESET}"
        read -p "SSH config bewerken? (Y/n): " edit_config
        edit_config=${edit_config:-y}
        
        if [[ "$edit_config" =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} "$SSH_CONFIG"
            echo -e "${GREEN}✓${RESET} SSH config bijgewerkt"
        fi
    fi
fi

echo ""

# Check of toilet is geïnstalleerd
if ! command -v toilet &> /dev/null; then
    echo -e "${YELLOW}⚠ Optioneel: 'toilet' niet gevonden${RESET}"
    echo -e "  Voor mooie ASCII art, installeer met:"
    echo -e "  ${CYAN}sudo apt install toilet toilet-fonts${RESET}"
    echo ""
fi

# Voltooiing
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
echo -e "║           ✅ INSTALLATIE VOLTOOID                       ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}✓ Homelab Tools zijn geïnstalleerd!${RESET}"
echo ""
echo -e "${BOLD}${YELLOW}Volgende stappen:${RESET}"
echo ""
echo -e "1. ${CYAN}Herlaad je bash configuratie:${RESET}"
echo -e "   ${GREEN}source ~/.bashrc${RESET}"
echo ""
echo -e "2. ${CYAN}Start het menu:${RESET}"
echo -e "   ${GREEN}homelab${RESET}"
echo ""
echo -e "3. ${CYAN}Of gebruik direct de commando's:${RESET}"
echo -e "   ${GREEN}generate-motd <service>${RESET}"
echo -e "   ${GREEN}deploy-motd <service>${RESET}"
echo -e "   ${GREEN}list-templates${RESET}"
echo ""
echo -e "4. ${CYAN}Voor help:${RESET}"
echo -e "   ${GREEN}homelab help${RESET}"
echo -e "   ${GREEN}generate-motd --help${RESET}"
echo ""
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo ""

# Source bashrc automatisch (alleen voor huidige sessie)
echo -e "${YELLOW}Tip:${RESET} Activeer nu meteen met:"
echo -e "  ${GREEN}source ~/.bashrc${RESET}"
echo ""
