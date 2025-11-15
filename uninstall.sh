#!/bin/bash
set -euo pipefail

# Homelab Tools Uninstaller
# Author: J.Bakers
# Version: 3.2.0

# Kleuren
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         🗑️  HOMELAB TOOLS - UNINSTALL                 ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Safety check - don't uninstall from development directory
if [[ -d ".git" ]] && [[ -f "uninstall.sh" ]]; then
    echo -e "${RED}✗ ERROR: You're running uninstall from the development directory!${RESET}"
    echo ""
    echo -e "  This will delete your entire project, including:"
    echo -e "  • All source code"
    echo -e "  • Git history"
    echo -e "  • Uncommitted changes"
    echo ""
    echo -e "${YELLOW}To uninstall safely:${RESET}"
    echo -e "  1. ${CYAN}cd ~${RESET}  (change to home directory)"
    echo -e "  2. ${CYAN}./homelab-tools/uninstall.sh${RESET}"
    echo ""
    echo -e "Or if you want to keep development folder:"
    echo -e "  • Just remove scripts: ${CYAN}rm ~/.local/bin/{homelab,generate-motd,deploy-motd,cleanup-keys,list-templates,edit-hosts,edit-config,copykey,bulk-generate-motd}${RESET}"
    echo ""
    exit 1
fi

echo -e "${YELLOW}⚠  WARNING:${RESET} This will remove Homelab Tools from your system."
echo ""
echo -e "${BOLD}What will be removed:${RESET}"
echo -e "  • All scripts from ~/.local/bin/"
echo -e "  • ~/homelab-tools/ directory"
echo -e "  • PATH entry from ~/.bashrc"
echo ""
echo -e "${BOLD}${GREEN}What will be KEPT (your data is safe):${RESET}"
echo -e "  • ~/.ssh/ directory (SSH keys & config)"
echo -e "  • All your host configurations"
echo -e "  • Deployed MOTDs on remote hosts"
echo ""

read -p "Continue with uninstall? (y/N): " confirm
confirm=${confirm:-n}

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${GREEN}✓ Uninstall cancelled${RESET}"
    exit 0
fi

echo ""
echo -e "${YELLOW}[1/4]${RESET} Verwijder symlinks uit /usr/local/bin/..."

# Remove symlinks
scripts=(
    "homelab"
    "generate-motd"
    "bulk-generate-motd"
    "deploy-motd"
    "cleanup-keys"
    "list-templates"
    "edit-hosts"
    "edit-config"
    "copykey"
    "cleanup-homelab"
)

removed=0
for script in "${scripts[@]}"; do
    if [[ -L "/usr/local/bin/$script" ]]; then
        rm "/usr/local/bin/$script"
        removed=$((removed + 1))
    fi
done

echo -e "${GREEN}  ✓${RESET} Verwijderd $removed symlink(s)"
echo ""

# Backup templates
CURRENT_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$CURRENT_USER)

echo -e "${YELLOW}[2/4]${RESET} Check MOTD templates..."
if [[ -d "$USER_HOME/.local/share/homelab-tools/templates" ]]; then
    template_count=$(find "$USER_HOME/.local/share/homelab-tools/templates" -name "*.sh" 2>/dev/null | wc -l)
    
    if [[ $template_count -gt 0 ]]; then
        backup_dir="$USER_HOME/homelab-tools-backup-$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}  →${RESET} Gevonden $template_count template(s)"
        read -p "  Backup maken? (Y/n): " backup
        backup=${backup:-y}
        
        if [[ "$backup" =~ ^[Yy]$ ]]; then
            mkdir -p "$backup_dir"
            cp -r "$USER_HOME/.local/share/homelab-tools/templates" "$backup_dir/"
            chown -R "$CURRENT_USER:$CURRENT_USER" "$backup_dir"
            echo -e "${GREEN}  ✓${RESET} Backup: ${CYAN}$backup_dir${RESET}"
        else
            echo -e "${YELLOW}  →${RESET} Skip backup"
        fi
    else
        echo -e "${GREEN}  ✓${RESET} Geen templates gevonden"
    fi
else
    echo -e "${GREEN}  ✓${RESET} Geen templates directory"
fi
echo ""

# Remove /opt directory
echo -e "${YELLOW}[3/4]${RESET} Verwijder /opt/homelab-tools/..."
if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}  ✓${RESET} Directory verwijderd"
else
    echo -e "${YELLOW}  →${RESET} Directory niet gevonden"
fi
echo ""

# Remove from bashrc
echo -e "${YELLOW}[4/4]${RESET} Cleanup ~/.bashrc..."
if [[ -f "$USER_HOME/.bashrc" ]] && grep -q "/opt/homelab-tools" "$USER_HOME/.bashrc" 2>/dev/null; then
    # Create backup
    cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Remove homelab-tools lines
    sed -i '/# Homelab Management Tools/d' "$USER_HOME/.bashrc"
    sed -i '\|/opt/homelab-tools|d' "$USER_HOME/.bashrc"
    
    chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.bashrc"*
    echo -e "${GREEN}  ✓${RESET} PATH entry verwijderd"
    echo -e "${YELLOW}  →${RESET} Backup: ${CYAN}~/.bashrc.backup.*${RESET}"
else
    echo -e "${GREEN}  ✓${RESET} Geen entries in ~/.bashrc"
fi
echo ""

# Summary
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║           ✅ UNINSTALL VOLTOOID                       ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}✓ Homelab Tools succesvol verwijderd!${RESET}"
echo ""
echo -e "${BOLD}${GREEN}Je data is veilig:${RESET}"
echo -e "  • SSH keys:       ${CYAN}~/.ssh/${RESET}"
echo -e "  • SSH config:     ${CYAN}~/.ssh/config${RESET}"
echo -e "  • Templates:      ${CYAN}$USER_HOME/.local/share/homelab-tools/${RESET}"
echo -e "  • Remote MOTDs:   ${CYAN}Nog steeds deployed${RESET}"

if [[ -n "${backup_dir:-}" ]] && [[ -d "$backup_dir" ]]; then
    echo -e "  • Backup:         ${CYAN}$backup_dir${RESET}"
fi

echo ""
echo -e "${YELLOW}Note:${RESET} Herlaad je shell:"
echo -e "  ${GREEN}source ~/.bashrc${RESET}"
echo ""
echo -e "${CYAN}Bedankt voor het gebruiken van Homelab Tools! 👋${RESET}"
echo ""
