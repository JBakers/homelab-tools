#!/bin/bash
set -euo pipefail

# Migrate homelab-tools from ~/homelab-tools to /opt/homelab-tools
# Author: J.Bakers
# Version: 3.5.0-dev.5

# Kleuren
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
echo -e "║         🔄 MIGRATIE: ~/homelab-tools → /opt           ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Check for sudo/root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}✗ Dit script moet als root gedraaid worden${RESET}"
   echo -e "  ${YELLOW}Gebruik: sudo ./migrate-to-opt.sh${RESET}"
   exit 1
fi

CURRENT_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$CURRENT_USER)
OLD_INSTALL="$USER_HOME/homelab-tools"
NEW_INSTALL="/opt/homelab-tools"

echo -e "${BOLD}Huidige situatie:${RESET}"
echo -e "  Oude locatie: ${CYAN}$OLD_INSTALL${RESET}"
echo -e "  Nieuwe locatie: ${CYAN}$NEW_INSTALL${RESET}"
echo -e "  User: ${CYAN}$CURRENT_USER${RESET}"
echo ""

# Check if old installation exists
if [[ ! -d "$OLD_INSTALL" ]]; then
    echo -e "${RED}✗ Geen installatie gevonden in $OLD_INSTALL${RESET}"
    exit 1
fi

# Check if this is a git repo (development folder)
if [[ -d "$OLD_INSTALL/.git" ]]; then
    echo -e "${YELLOW}⚠ Dit is een Git repository (development folder)${RESET}"
    echo -e "  Na migratie kun je deze folder blijven gebruiken voor development."
    echo ""
fi

echo -e "${YELLOW}Wat gaat er gebeuren:${RESET}"
echo -e "  1. Backup huidige templates (indien aanwezig)"
echo -e "  2. Verwijder oude PATH entry uit ~/.bashrc"
echo -e "  3. Installeer fresh naar /opt/homelab-tools"
echo -e "  4. Maak symlinks in /usr/local/bin"
echo -e "  5. Kopieer je config (indien aanwezig)"
echo ""

read -p "Doorgaan met migratie? (y/N): " confirm
confirm=${confirm:-n}

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Migratie geannuleerd${RESET}"
    exit 0
fi

echo ""
echo -e "${BOLD}${CYAN}Start migratie...${RESET}"
echo ""

# Stap 1: Backup templates
echo -e "${YELLOW}[1/6]${RESET} Backup templates..."
if [[ -d "$USER_HOME/.local/share/homelab-tools/templates" ]]; then
    template_count=$(find "$USER_HOME/.local/share/homelab-tools/templates" -name "*.sh" 2>/dev/null | wc -l)
    if [[ $template_count -gt 0 ]]; then
        echo -e "${GREEN}  ✓${RESET} Gevonden $template_count template(s) (blijven behouden)"
    else
        echo -e "${YELLOW}  →${RESET} Geen templates gevonden"
    fi
else
    echo -e "${YELLOW}  →${RESET} Geen templates directory"
fi
echo ""

# Stap 2: Backup config
echo -e "${YELLOW}[2/6]${RESET} Backup configuratie..."
if [[ -f "$OLD_INSTALL/config.sh" ]]; then
    cp "$OLD_INSTALL/config.sh" "/tmp/homelab-config.sh.backup"
    echo -e "${GREEN}  ✓${RESET} Config backed-up naar /tmp/homelab-config.sh.backup"
else
    echo -e "${YELLOW}  →${RESET} Geen config gevonden"
fi
echo ""

# Stap 3: Clean oude PATH entries
echo -e "${YELLOW}[3/6]${RESET} Cleanup oude PATH in ~/.bashrc..."
if [[ -f "$USER_HOME/.bashrc" ]] && grep -q "homelab-tools/bin" "$USER_HOME/.bashrc" 2>/dev/null; then
    # Backup bashrc
    cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Remove oude entries (zowel ~/homelab-tools als /opt/homelab-tools)
    sed -i '/# Homelab Management Tools/d' "$USER_HOME/.bashrc"
    sed -i '\|homelab-tools/bin|d' "$USER_HOME/.bashrc"
    
    chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.bashrc"*
    echo -e "${GREEN}  ✓${RESET} Oude PATH entries verwijderd"
else
    echo -e "${YELLOW}  →${RESET} Geen PATH entries gevonden"
fi
echo ""

# Stap 4: Installeer naar /opt
echo -e "${YELLOW}[4/6]${RESET} Installeer naar /opt..."

# Backup oude /opt installatie indien aanwezig
if [[ -d "$NEW_INSTALL" ]]; then
    backup_dir="$NEW_INSTALL.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}  →${RESET} Backup oude /opt installatie naar $backup_dir"
    mv "$NEW_INSTALL" "$backup_dir"
fi

# Kopieer bestanden
echo -e "${YELLOW}  →${RESET} Kopieer bestanden naar /opt..."
mkdir -p "$NEW_INSTALL"
cp -r "$OLD_INSTALL"/* "$NEW_INSTALL/"
cp "$OLD_INSTALL"/.gitignore "$NEW_INSTALL/" 2>/dev/null || true

# Exclude .git directory
rm -rf "$NEW_INSTALL/.git" 2>/dev/null || true

echo -e "${GREEN}  ✓${RESET} Bestanden geïnstalleerd in /opt"
echo ""

# Stap 5: Maak executable en symlinks
echo -e "${YELLOW}[5/6]${RESET} Configureer permissions en symlinks..."
chmod +x "$NEW_INSTALL"/bin/* 2>/dev/null
chmod +x "$NEW_INSTALL"/*.sh 2>/dev/null

# Maak symlinks in /usr/local/bin
for cmd in "$NEW_INSTALL"/bin/*; do
    cmd_name=$(basename "$cmd")
    ln -sf "$NEW_INSTALL/bin/$cmd_name" "/usr/local/bin/$cmd_name"
done
echo -e "${GREEN}  ✓${RESET} Symlinks aangemaakt in /usr/local/bin"
echo ""

# Stap 6: Restore config
echo -e "${YELLOW}[6/6]${RESET} Restore configuratie..."
if [[ -f "/tmp/homelab-config.sh.backup" ]]; then
    cp "/tmp/homelab-config.sh.backup" "$NEW_INSTALL/config.sh"
    rm "/tmp/homelab-config.sh.backup"
    echo -e "${GREEN}  ✓${RESET} Configuratie hersteld"
else
    echo -e "${YELLOW}  →${RESET} Geen config om te restoren"
fi
echo ""

# Voltooiing
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
echo -e "║           ✅ MIGRATIE VOLTOOID                         ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}✓ Homelab Tools zijn gemigreerd naar /opt!${RESET}"
echo ""

echo -e "${BOLD}Nieuwe locaties:${RESET}"
echo -e "  • Programma:  ${CYAN}/opt/homelab-tools/${RESET}"
echo -e "  • Commando's: ${CYAN}/usr/local/bin/${RESET}"
echo -e "  • Templates:  ${CYAN}$USER_HOME/.local/share/homelab-tools/templates/${RESET}"
echo -e "  • Config:     ${CYAN}/opt/homelab-tools/config.sh${RESET}"
echo ""

echo -e "${BOLD}${GREEN}Development folder:${RESET}"
echo -e "  • ${CYAN}$OLD_INSTALL/${RESET} blijft beschikbaar voor Git/development"
echo -e "  • Je kunt hier blijven werken en changes pushen"
echo -e "  • Om updates te installeren: ${CYAN}cd $OLD_INSTALL && sudo ./install.sh${RESET}"
echo ""

echo -e "${BOLD}${YELLOW}Volgende stappen:${RESET}"
echo ""
echo -e "1. ${CYAN}Test de installatie:${RESET}"
echo -e "   ${GREEN}homelab${RESET}"
echo ""
echo -e "2. ${CYAN}Herlaad je shell (optioneel):${RESET}"
echo -e "   ${GREEN}source ~/.bashrc${RESET}"
echo ""
echo -e "3. ${CYAN}Voor development werk:${RESET}"
echo -e "   ${GREEN}cd $OLD_INSTALL${RESET}"
echo -e "   ${GREEN}git status${RESET}"
echo ""

echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo ""
