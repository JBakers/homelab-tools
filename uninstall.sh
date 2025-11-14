#!/bin/bash

# Uninstall script voor Homelab Management Tools
# Author: J.Bakers
# Version: 3.0

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
echo -e "${YELLOW}[1/4]${RESET} Removing scripts from ~/.local/bin/..."

# Remove scripts
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
)

removed=0
for script in "${scripts[@]}"; do
    if [[ -f "$HOME/.local/bin/$script" ]]; then
        rm "$HOME/.local/bin/$script"
        ((removed++))
    fi
done

echo -e "${GREEN}  ✓${RESET} Removed $removed script(s)"
echo ""

# Backup templates
echo -e "${YELLOW}[2/4]${RESET} Checking for MOTD templates..."
if [[ -d "$HOME/homelab-tools/templates" ]]; then
    template_count=$(find "$HOME/homelab-tools/templates" -name "*.sh" 2>/dev/null | wc -l)
    
    if [[ $template_count -gt 0 ]]; then
        backup_dir="$HOME/homelab-tools-backup-$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}  →${RESET} Found $template_count template(s)"
        read -p "  Create backup before removing? (Y/n): " backup
        backup=${backup:-y}
        
        if [[ "$backup" =~ ^[Yy]$ ]]; then
            mkdir -p "$backup_dir"
            cp -r "$HOME/homelab-tools/templates" "$backup_dir/"
            echo -e "${GREEN}  ✓${RESET} Backup created: ${CYAN}$backup_dir${RESET}"
        else
            echo -e "${YELLOW}  →${RESET} Skipping backup"
        fi
    else
        echo -e "${GREEN}  ✓${RESET} No templates found"
    fi
else
    echo -e "${GREEN}  ✓${RESET} No templates directory"
fi
echo ""

# Remove directory
echo -e "${YELLOW}[3/4]${RESET} Removing ~/homelab-tools/..."
if [[ -d "$HOME/homelab-tools" ]]; then
    rm -rf "$HOME/homelab-tools"
    echo -e "${GREEN}  ✓${RESET} Directory removed"
else
    echo -e "${YELLOW}  →${RESET} Directory not found"
fi
echo ""

# Remove from bashrc
echo -e "${YELLOW}[4/4]${RESET} Cleaning up ~/.bashrc..."
if grep -q "homelab-tools" "$HOME/.bashrc" 2>/dev/null; then
    # Create backup
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Remove homelab-tools lines
    sed -i '/# Homelab Management Tools/d' "$HOME/.bashrc"
    sed -i '\|homelab-tools/bin|d' "$HOME/.bashrc"
    
    echo -e "${GREEN}  ✓${RESET} PATH entry removed"
    echo -e "${YELLOW}  →${RESET} Backup created: ${CYAN}~/.bashrc.backup.*${RESET}"
else
    echo -e "${GREEN}  ✓${RESET} No entries found in ~/.bashrc"
fi
echo ""

# Summary
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║           ✅ UNINSTALL COMPLETE                       ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}✓ Homelab Tools successfully removed!${RESET}"
echo ""
echo -e "${BOLD}${GREEN}Your data is safe:${RESET}"
echo -e "  • SSH keys:       ${CYAN}~/.ssh/${RESET}"
echo -e "  • SSH config:     ${CYAN}~/.ssh/config${RESET}"
echo -e "  • Remote MOTDs:   ${CYAN}Still deployed on hosts${RESET}"

if [[ -n "$backup_dir" ]] && [[ -d "$backup_dir" ]]; then
    echo -e "  • MOTD backups:   ${CYAN}$backup_dir${RESET}"
fi

echo ""
echo -e "${YELLOW}Note:${RESET} Reload your shell to update PATH:"
echo -e "  ${GREEN}source ~/.bashrc${RESET}"
echo ""
echo -e "${CYAN}Thanks for using Homelab Tools! 👋${RESET}"
echo ""
