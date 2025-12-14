#!/bin/bash
set -euo pipefail

# Homelab Tools Uninstaller
# Author: J.Bakers
# Version: 3.6.0-dev.13

# Kleuren
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         🗑️  HOMELAB TOOLS - UNINSTALL                ║"
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

# Ask for confirmation
read -p "Uninstall Homelab Tools? (Y/n): " confirm
confirm=${confirm:-y}

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${GREEN}✓ Uninstall cancelled${RESET}"
    exit 0
fi

echo ""
echo -e "${YELLOW}[1/4]${RESET} Removing symlinks from ~/.local/bin/..."

# Remove symlinks from ~/.local/bin
BIN_DIR="$HOME/.local/bin"
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
    if [[ -L "$BIN_DIR/$script" ]] || [[ -f "$BIN_DIR/$script" ]]; then
        rm -f "$BIN_DIR/$script"
        removed=$((removed + 1))
    fi
done

echo -e "${GREEN}  ✓${RESET} Removed $removed symlink(s)"
echo ""

# Templates
TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"

echo -e "${YELLOW}[2/5]${RESET} Checking MOTD templates..."
if [[ -d "$TEMPLATES_DIR" ]]; then
    template_count=$(find "$TEMPLATES_DIR" -name "*.sh" 2>/dev/null | wc -l)

    if [[ $template_count -gt 0 ]]; then
        echo -e "${YELLOW}  →${RESET} Found $template_count template(s)"
        read -p "  Remove templates? (Y/n): " remove_templates
        remove_templates=${remove_templates:-y}

        if [[ "$remove_templates" =~ ^[Yy]$ ]]; then
            rm -rf "$TEMPLATES_DIR"
            echo -e "${GREEN}  ✓${RESET} Templates removed"
        else
            echo -e "${YELLOW}  →${RESET} Templates kept"
        fi
    else
        echo -e "${GREEN}  ✓${RESET} No templates found"
    fi
else
    echo -e "${GREEN}  ✓${RESET} No templates directory"
fi
echo ""

# Backup directories in /opt
echo -e "${YELLOW}[3/5]${RESET} Checking backup directories..."
backup_count=$(sudo find /opt -maxdepth 1 -name "homelab-tools.backup.*" -type d 2>/dev/null | wc -l)
if [[ $backup_count -gt 0 ]]; then
    echo -e "${YELLOW}  →${RESET} Found $backup_count backup director(y/ies)"
    read -p "  Remove backups? (Y/n): " remove_backups
    remove_backups=${remove_backups:-y}

    if [[ "$remove_backups" =~ ^[Yy]$ ]]; then
        sudo rm -rf /opt/homelab-tools.backup.*
        echo -e "${GREEN}  ✓${RESET} Backups removed"
    else
        echo -e "${YELLOW}  →${RESET} Backups kept"
    fi
else
    echo -e "${GREEN}  ✓${RESET} No backups found"
fi
echo ""

# Remove MOTDs from remote hosts
echo -e "${YELLOW}[4/6]${RESET} Checking deployed MOTDs..."
SSH_CONFIG="$HOME/.ssh/config"
if [[ -f "$SSH_CONFIG" ]]; then
    hosts=$(grep "^Host " "$SSH_CONFIG" | awk '{print $2}' | grep -v '\*' | sort -u)
    host_count=$(echo "$hosts" | wc -w)

    if [[ $host_count -gt 0 ]]; then
        echo -e "${YELLOW}  →${RESET} Found $host_count host(s) in SSH config"
        read -p "  Remove MOTDs from remote hosts? (Y/n): " remove_motds
        remove_motds=${remove_motds:-y}

        if [[ "$remove_motds" =~ ^[Yy]$ ]]; then
            echo ""
            removed=0
            failed=0

            for hostname in $hosts; do
                echo -e "  ${CYAN}$hostname${RESET}..."
                if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$hostname" "sudo rm -f /etc/update-motd.d/99-homelab" 2>/dev/null; then
                    echo -e "    ${GREEN}✓${RESET} MOTD removed"
                    removed=$((removed + 1))
                else
                    echo -e "    ${YELLOW}→${RESET} Not reachable or no MOTD"
                    failed=$((failed + 1))
                fi
            done

            echo ""
            echo -e "${GREEN}  ✓${RESET} Removed from $removed host(s)"
            if [[ $failed -gt 0 ]]; then
                echo -e "${YELLOW}  →${RESET} $failed host(s) not reachable"
            fi
        else
            echo -e "${YELLOW}  →${RESET} MOTDs kept on remote hosts"
        fi
    else
        echo -e "${GREEN}  ✓${RESET} No hosts found in SSH config"
    fi
else
    echo -e "${GREEN}  ✓${RESET} No SSH config found"
fi
echo ""

# Remove /opt/homelab-tools directory
INSTALL_DIR="/opt/homelab-tools"
echo -e "${YELLOW}[5/6]${RESET} Removing /opt/homelab-tools/..."
if [[ -d "$INSTALL_DIR" ]]; then
    sudo rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}  ✓${RESET} Directory removed"
else
    echo -e "${YELLOW}  →${RESET} Directory not found"
fi
echo ""

# Remove from bashrc
echo -e "${YELLOW}[6/6]${RESET} Cleaning up ~/.bashrc..."
if [[ -f "$HOME/.bashrc" ]] && grep -qi "homelab" "$HOME/.bashrc" 2>/dev/null; then
    # Create backup FIRST - always preserve user data
    backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$HOME/.bashrc" "$backup_file"

    # Safe removal using awk: remove our exact sections
    temp_file="$(mktemp)"
    
    awk '
    BEGIN { 
        in_banner = 0
        banner_depth = 0
    }

    # Never touch VS Code shell integration or other tool sections
    /locate-shell-integration-path/ { print; next }
    
    # Match tip section start
    /^# Homelab Tools tip$/ { 
        getline  # Skip this line and the next (echo line)
        next 
    }
    
    # Match banner section start (exact 3-line header)
    /^# ===============================================$/ {
        line1 = $0
        getline
        line2 = $0
        if (line2 ~ /^# Homelab Tools Welcome Banner$/) {
            getline
            line3 = $0
            if (line3 ~ /^# Set HLT_BANNER=0 to disable$/) {
                getline  # Skip the next === line too
                in_banner = 1
                banner_depth = 0
                next
            } else {
                # Not our banner, print all 3 lines
                print line1
                print line2
                print line3
                next
            }
        } else {
            # Not our banner, print both lines
            print line1
            print line2
            next
        }
    }
    
    # When in banner section, count if/fi pairs to find the right closing fi
    in_banner == 1 {
        # Count nested if statements (including inline if)
        if ($0 ~ /^[[:space:]]*if /) banner_depth++
        if ($0 ~ /^[[:space:]]*fi$/) {
            if (banner_depth == 0) {
                # This is the closing fi for the HLT_BANNER if
                in_banner = 0
                next
            } else {
                banner_depth--
            }
        }
        # Skip all lines while in banner
        next
    }
    
    # Print all other lines
    { print }
    ' "$HOME/.bashrc" > "$temp_file"
    
    # Verify the result is valid bash before applying
    if bash -n "$temp_file" 2>/dev/null; then
        # Double-check: make sure we didn't accidentally remove too much
        orig_lines=$(wc -l < "$HOME/.bashrc")
        new_lines=$(wc -l < "$temp_file")
        removed=$((orig_lines - new_lines))
        
        # Sanity check: we should remove 20-40 lines max (tip + banner)
        if [[ $removed -ge 0 && $removed -le 50 ]]; then
            mv "$temp_file" "$HOME/.bashrc"
            # Ensure correct ownership
            chown "$(id -un):$(id -gn)" "$HOME/.bashrc" 2>/dev/null || true
            echo -e "${GREEN}  ✓${RESET} Homelab entries removed ($removed lines)"
            echo -e "${YELLOW}  →${RESET} Backup: ${CYAN}${backup_file}${RESET}"
        else
            echo -e "${RED}  ✗${RESET} Unexpected line count change ($removed lines) - keeping original"
            echo -e "${YELLOW}  →${RESET} Check backup: ${CYAN}${backup_file}${RESET}"
            rm -f "$temp_file"
        fi
    else
        echo -e "${RED}  ✗${RESET} Cleanup would break .bashrc - keeping original"
        echo -e "${YELLOW}  →${RESET} Check backup: ${CYAN}${backup_file}${RESET}"
        rm -f "$temp_file"
    fi
else
    echo -e "${GREEN}  ✓${RESET} No entries in ~/.bashrc"
fi
echo ""

# Summary
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         ✅ UNINSTALL COMPLETE                        ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}✓ Homelab Tools successfully removed!${RESET}"
echo ""
echo -e "${BOLD}${GREEN}Important information:${RESET}"
echo -e "  • SSH keys:       ${CYAN}Kept in ~/.ssh/${RESET}"
echo -e "  • SSH config:     ${CYAN}Kept in ~/.ssh/config${RESET}"

# Only show remote MOTDs message if they weren't removed
if [[ "${remove_motds:-n}" != "y" ]]; then
    echo -e "  • Remote MOTDs:   ${YELLOW}Still deployed on hosts${RESET}"
fi

if [[ -n "${backup_dir:-}" ]] && [[ -d "${backup_dir}" ]]; then
    echo -e "  • Backup:         ${CYAN}$backup_dir${RESET}"
fi

echo ""
echo -e "${YELLOW}Note:${RESET} Reload your shell:"
echo -e "  ${GREEN}source ~/.bashrc${RESET}"
echo ""
echo -e "${CYAN}Thank you for using Homelab Tools! 👋${RESET}"
echo ""
