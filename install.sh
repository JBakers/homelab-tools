#!/bin/bash
set -euo pipefail

# Installatie script voor Homelab Management Tools
# Author: J.Bakers
# Version: 3.5.0-dev.15

# Detect actual user (not root when using sudo)
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo "~$ACTUAL_USER")

# Helper function to run commands with or without sudo
run_sudo() {
    if [[ $EUID -eq 0 ]]; then
        # Already root, no sudo needed
        "$@"
    else
        sudo "$@"
    fi
}

# Kleuren
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# Get version and branch info
VERSION=$(grep -m1 "Version: " bin/homelab | sed 's/.*Version: //')
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
INSTALL_DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
echo -e "║         🏠 HOMELAB TOOLS - INSTALLATIE                    ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}Installatie Info:${RESET}"
echo -e "  Versie:  ${CYAN}$VERSION${RESET}"
echo -e "  Branch:  ${CYAN}$BRANCH${RESET}"
echo -e "  Datum:   ${CYAN}$INSTALL_DATE${RESET}"
echo -e "  User:    ${CYAN}$ACTUAL_USER${RESET}"
echo ""

# Check of we in de juiste directory zijn
if [[ ! -f "$(pwd)/bin/homelab" ]]; then
    echo -e "${RED}✗ Fout: Run dit script vanuit de homelab-tools directory${RESET}"
    echo -e "  ${YELLOW}cd ~/homelab-tools && ./install.sh${RESET}"
    exit 1
fi

INSTALL_DIR="/opt/homelab-tools"

echo -e "${BOLD}Installatie directory: ${CYAN}$INSTALL_DIR${RESET}"
echo ""

# 1. Installeer bestanden naar /opt
echo -e "${YELLOW}[1/5]${RESET} Installeer naar /opt (vereist sudo)..."

# Backup oude installatie
if [[ -d "$INSTALL_DIR" ]]; then
    backup_dir="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}  →${RESET} Backup oude installatie naar $backup_dir"
    run_sudo mv "$INSTALL_DIR" "$backup_dir"
fi

# Kopieer bestanden naar /opt (vereist sudo)
echo -e "${YELLOW}  →${RESET} Kopieer bestanden naar $INSTALL_DIR..."
run_sudo mkdir -p "$INSTALL_DIR"
run_sudo cp -r "$(pwd)"/* "$INSTALL_DIR/"
run_sudo cp -r "$(pwd)"/.gitignore "$INSTALL_DIR/" 2>/dev/null || true
echo -e "${GREEN}  ✓${RESET} Bestanden geïnstalleerd in /opt"
# Verwijder oude config.sh zodat deze opnieuw wordt aangemaakt
run_sudo rm -f "$INSTALL_DIR/config.sh" 2>/dev/null || true
echo ""

# 2. Maak alle scripts executable
echo -e "${YELLOW}[2/5]${RESET} Configureer permissions..."
run_sudo chmod +x "$INSTALL_DIR"/bin/* 2>/dev/null
run_sudo chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null
echo -e "${GREEN}  ✓${RESET} Scripts zijn executable"
echo ""

# 3. Configureer PATH
echo -e "${YELLOW}[3/5]${RESET} Configureer PATH..."

# Maak ~/.local/bin directory
BIN_DIR="$ACTUAL_HOME/.local/bin"
mkdir -p "$BIN_DIR"
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.local" 2>/dev/null || true

# Creëer symlinks in ~/.local/bin (geen sudo nodig)
echo -e "${YELLOW}  →${RESET} Maak symlinks in ~/.local/bin..."
for cmd in "$INSTALL_DIR"/bin/*; do
    cmd_name=$(basename "$cmd")
    ln -sf "$INSTALL_DIR/bin/$cmd_name" "$BIN_DIR/$cmd_name"
    chown -h "$ACTUAL_USER:$ACTUAL_USER" "$BIN_DIR/$cmd_name" 2>/dev/null || true
done
echo -e "${GREEN}  ✓${RESET} Commando's beschikbaar in ~/.local/bin"
echo ""

# Voeg ~/.local/bin toe aan PATH in bashrc
echo -e "${YELLOW}  →${RESET} Configureer PATH in ~/.bashrc..."

if [[ -f "$ACTUAL_HOME/.bashrc" ]]; then
    # Check of ~/.local/bin al in PATH staat
    if grep -q 'PATH.*\.local/bin' "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
        echo -e "${GREEN}  ✓${RESET} ~/.local/bin al in PATH"
    else
        echo "" >> "$ACTUAL_HOME/.bashrc"
        echo "# Homelab Management Tools" >> "$ACTUAL_HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ACTUAL_HOME/.bashrc"
        echo -e "${GREEN}  ✓${RESET} PATH toegevoegd aan ~/.bashrc"
    fi
else
    echo -e "${YELLOW}  ⚠${RESET} Geen .bashrc gevonden, maak nieuwe aan"
    echo '# Homelab Management Tools' > "$ACTUAL_HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ACTUAL_HOME/.bashrc"
    echo -e "${GREEN}  ✓${RESET} .bashrc aangemaakt met PATH"
fi

# Voeg MOTD tip toe aan bashrc (alleen als nog niet aanwezig)
if ! grep -q "Tip: Type.*homelab" "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$ACTUAL_HOME/.bashrc"
    echo "# Homelab Tools tip" >> "$ACTUAL_HOME/.bashrc"
    echo 'echo -e "\033[0;36mTip:\033[0m Type \033[1mhomelab\033[0m for available commands"' >> "$ACTUAL_HOME/.bashrc"
    echo -e "${GREEN}  ✓${RESET} MOTD tip toegevoegd aan ~/.bashrc"
fi
echo ""

# 4. Maak templates directory
echo -e "${YELLOW}[4/5]${RESET} Initialiseer templates..."

# Templates in user home directory
mkdir -p "$ACTUAL_HOME/.local/share/homelab-tools/templates"
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.local/share/homelab-tools" 2>/dev/null || true
echo -e "${GREEN}  ✓${RESET} Templates directory: $ACTUAL_HOME/.local/share/homelab-tools/templates"
echo ""

# 5. Configuratie
echo -e "${YELLOW}[5/5]${RESET} Configureer homelab settings..."
echo ""

# Config file in /opt (system-wide)
CONFIG_FILE="$INSTALL_DIR/config.sh"

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

    # Create config in temp file first, then move with sudo
    TEMP_CONFIG=$(mktemp)
    cat > "$TEMP_CONFIG" << EOF
#!/bin/bash
# Homelab Tools Installer
# Installs to /opt/homelab-tools with system-wide access
# Author: J.Bakers
# Version: 3.5.0-dev.15

# Domain suffix voor je homelab
# Wordt gebruikt voor Web UI URLs
DOMAIN_SUFFIX="$domain_suffix"

# IP detectie methode
# Opties: "hostname" of "ip"
IP_METHOD="hostname"
EOF

    # Move temp config to final location with sudo
    run_sudo mv "$TEMP_CONFIG" "$CONFIG_FILE"
    run_sudo chmod 644 "$CONFIG_FILE"

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

SSH_DIR="$ACTUAL_HOME/.ssh"
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
echo -e "║           ✅ INSTALLATIE VOLTOOID                      ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}✓ Homelab Tools zijn geïnstalleerd!${RESET}"
echo ""
echo -e "${BOLD}Geïnstalleerde Versie:${RESET}"
echo -e "  • Versie:     ${CYAN}$VERSION${RESET}"
echo -e "  • Branch:     ${CYAN}$BRANCH${RESET}"
echo -e "  • Datum:      ${CYAN}$INSTALL_DATE${RESET}"
echo ""
echo -e "${BOLD}Installatie locaties:${RESET}"
echo -e "  • Programma:  ${CYAN}/opt/homelab-tools/${RESET}"
echo -e "  • Commando's: ${CYAN}~/.local/bin/${RESET}"
echo -e "  • Templates:  ${CYAN}~/.local/share/homelab-tools/templates/${RESET}"
echo -e "  • Config:     ${CYAN}/opt/homelab-tools/config.sh${RESET}"
echo ""
echo -e "${BOLD}${YELLOW}Volgende stappen:${RESET}"
echo ""
echo -e "1. ${CYAN}Start een nieuwe terminal of reload shell:${RESET}"
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
