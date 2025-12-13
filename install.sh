#!/bin/bash
set -euo pipefail

# Installatie script voor Homelab Management Tools
# Author: J.Bakers
# Version: 3.5.0-dev.23

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
echo -e "║         🏠 HOMELAB TOOLS - INSTALLATION                   ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${BOLD}Installation Info:${RESET}"
echo -e "  Version: ${CYAN}$VERSION${RESET}"
echo -e "  Branch:  ${CYAN}$BRANCH${RESET}"
echo -e "  Date:    ${CYAN}$INSTALL_DATE${RESET}"
echo -e "  User:    ${CYAN}$ACTUAL_USER${RESET}"
echo ""

# Check if we're in the correct directory
if [[ ! -f "$(pwd)/bin/homelab" ]]; then
    echo -e "${RED}✗ Error: Run this script from the homelab-tools directory${RESET}"
    echo -e "  ${YELLOW}cd ~/homelab-tools && ./install.sh${RESET}"
    exit 1
fi

INSTALL_DIR="/opt/homelab-tools"

echo -e "${BOLD}Installation directory: ${CYAN}$INSTALL_DIR${RESET}"
echo ""

# Check for legacy installation in ~/homelab-tools
LEGACY_DIR="$ACTUAL_HOME/homelab-tools"
if [[ -d "$LEGACY_DIR" ]] && [[ "$LEGACY_DIR" != "$(pwd)" ]]; then
    echo -e "${YELLOW}⚠ Old installation found in ~/homelab-tools${RESET}"
    echo ""
    echo -e "${BOLD}What do you want to do with the old installation?${RESET}"
    echo -e "  ${CYAN}1${RESET}) Backup and remove ${YELLOW}(recommended)${RESET}"
    echo -e "  ${CYAN}2${RESET}) Backup only"
    echo -e "  ${CYAN}3${RESET}) Keep it"
    echo ""
    read -p "Choice (1/2/3): " legacy_choice
    legacy_choice=${legacy_choice:-1}
    
    case "$legacy_choice" in
        1)
            # Backup and remove
            BACKUP_DIR="$ACTUAL_HOME/homelab-tools.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "${YELLOW}→${RESET} Creating backup to $BACKUP_DIR..."
            cp -r "$LEGACY_DIR" "$BACKUP_DIR"
            chown -R "$ACTUAL_USER:$ACTUAL_USER" "$BACKUP_DIR"
            echo -e "${GREEN}✓${RESET} Backup created"
            
            echo -e "${YELLOW}→${RESET} Removing old installation..."
            rm -rf "$LEGACY_DIR"
            echo -e "${GREEN}✓${RESET} Old installation removed"
            echo ""
            ;;
        2)
            # Backup only
            BACKUP_DIR="$ACTUAL_HOME/homelab-tools.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "${YELLOW}→${RESET} Creating backup to $BACKUP_DIR..."
            cp -r "$LEGACY_DIR" "$BACKUP_DIR"
            chown -R "$ACTUAL_USER:$ACTUAL_USER" "$BACKUP_DIR"
            echo -e "${GREEN}✓${RESET} Backup created"
            echo -e "${YELLOW}⚠${RESET} Old installation kept in ~/homelab-tools"
            echo ""
            ;;
        3)
            # Keep
            echo -e "${YELLOW}⚠${RESET} Old installation kept"
            echo ""
            ;;
        *)
            echo -e "${RED}✗${RESET} Invalid choice, old installation kept"
            echo ""
            ;;
    esac
fi

# 1. Install files to /opt
echo -e "${YELLOW}[1/5]${RESET} Installing to /opt (requires sudo)..."

# Backup old installation
if [[ -d "$INSTALL_DIR" ]]; then
    backup_dir="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}  →${RESET} Backing up old installation to $backup_dir"
    run_sudo mv "$INSTALL_DIR" "$backup_dir"
fi

# Copy files to /opt (requires sudo)
echo -e "${YELLOW}  →${RESET} Copying files to $INSTALL_DIR..."
run_sudo mkdir -p "$INSTALL_DIR"
run_sudo cp -r "$(pwd)"/* "$INSTALL_DIR/"
run_sudo cp -r "$(pwd)"/.gitignore "$INSTALL_DIR/" 2>/dev/null || true
echo -e "${GREEN}  ✓${RESET} Files installed in /opt"
# Remove old config.sh so it will be recreated
run_sudo rm -f "$INSTALL_DIR/config.sh" 2>/dev/null || true
echo ""

# 2. Make all scripts executable
echo -e "${YELLOW}[2/5]${RESET} Configuring permissions..."
run_sudo chmod +x "$INSTALL_DIR"/bin/* 2>/dev/null
run_sudo chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null
run_sudo chmod 755 "$INSTALL_DIR"/lib/* 2>/dev/null
echo -e "${GREEN}  ✓${RESET} Scripts are executable"
echo -e "${GREEN}  ✓${RESET} Library files are readable"
echo ""

# 3. Configure PATH
echo -e "${YELLOW}[3/5]${RESET} Configuring PATH..."

# Clean up old homelab-tools references in .bashrc (maar niet .ssh!)
if [[ -f "$ACTUAL_HOME/.bashrc" ]]; then
    echo -e "${YELLOW}  →${RESET} Checking .bashrc for old references..."
    
    # Check for old PATH exports or aliases pointing to ~/homelab-tools
    if grep -E "homelab-tools|PATH.*homelab" "$ACTUAL_HOME/.bashrc" | grep -v "Tip: Type.*homelab" | grep -qv "^#"; then
        echo -e "${YELLOW}  ⚠${RESET} Old homelab-tools references found in .bashrc"
        
        # Create backup
        cp "$ACTUAL_HOME/.bashrc" "$ACTUAL_HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Remove old homelab-tools lines (but keep .ssh lines)
        sed -i '/export PATH.*homelab-tools/d' "$ACTUAL_HOME/.bashrc"
        sed -i '/PATH=.*homelab-tools/d' "$ACTUAL_HOME/.bashrc"
        sed -i '/alias.*homelab-tools/d' "$ACTUAL_HOME/.bashrc"
        
        echo -e "${GREEN}  ✓${RESET} Old references removed (backup created)"
    else
        echo -e "${GREEN}  ✓${RESET} No old references found"
    fi
fi

# Create ~/.local/bin directory
BIN_DIR="$ACTUAL_HOME/.local/bin"
mkdir -p "$BIN_DIR"
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.local" 2>/dev/null || true

# Create symlinks in ~/.local/bin (no sudo needed)
echo -e "${YELLOW}  →${RESET} Creating symlinks in ~/.local/bin..."
for cmd in "$INSTALL_DIR"/bin/*; do
    cmd_name=$(basename "$cmd")
    ln -sf "$INSTALL_DIR/bin/$cmd_name" "$BIN_DIR/$cmd_name"
    chown -h "$ACTUAL_USER:$ACTUAL_USER" "$BIN_DIR/$cmd_name" 2>/dev/null || true
done
echo -e "${GREEN}  ✓${RESET} Commands available in ~/.local/bin"
echo ""

# Add ~/.local/bin to PATH in bashrc
echo -e "${YELLOW}  →${RESET} Configuring PATH in ~/.bashrc..."

if [[ -f "$ACTUAL_HOME/.bashrc" ]]; then
    # Check if ~/.local/bin is already in PATH
    if grep -q 'PATH.*\.local/bin' "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
        echo -e "${GREEN}  ✓${RESET} ~/.local/bin already in PATH"
    else
        echo "" >> "$ACTUAL_HOME/.bashrc"
        echo "# Homelab Management Tools" >> "$ACTUAL_HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ACTUAL_HOME/.bashrc"
        echo -e "${GREEN}  ✓${RESET} PATH added to ~/.bashrc"
    fi
else
    echo -e "${YELLOW}  ⚠${RESET} No .bashrc found, creating new one"
    echo '# Homelab Management Tools' > "$ACTUAL_HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ACTUAL_HOME/.bashrc"
    echo -e "${GREEN}  ✓${RESET} .bashrc created with PATH"
fi

# Voeg MOTD tip toe aan bashrc (alleen als nog niet aanwezig)
if ! grep -q "Tip: Type.*homelab" "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$ACTUAL_HOME/.bashrc"
    echo "# Homelab Tools tip" >> "$ACTUAL_HOME/.bashrc"
    echo 'echo -e "\033[0;36mTip:\033[0m Type \033[1mhomelab\033[0m for available commands"' >> "$ACTUAL_HOME/.bashrc"
    echo -e "${GREEN}  ✓${RESET} MOTD tip added to ~/.bashrc"
fi

# Add optional welcome banner
if ! grep -q "HLT_BANNER" "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
    echo ""
    read -p "Add a welcome banner to your shell? (Y/n): " add_banner
    add_banner=${add_banner:-y}
    
    if [[ "$add_banner" =~ ^[Yy]$ ]]; then
        cat >> "$ACTUAL_HOME/.bashrc" << 'BANNER_EOF'

# ===============================================
# Homelab Tools Welcome Banner
# Set HLT_BANNER=0 to disable
# ===============================================
if [[ -z "$HLT_BANNER" ]] || [[ "$HLT_BANNER" != "0" ]]; then
    # Show banner only for interactive shells, not in VS Code
    if [[ $- == *i* ]] && [[ -z "$VSCODE_INJECTION" ]] && [[ -z "$TERM_PROGRAM" ]]; then
        cat << "EOF"

  _   _                      _       _       _____           _     
 | | | | ___  _ __ ___   ___| | __ _| |__   |_   _|__   ___ | |___ 
 | |_| |/ _ \| '_ ` _ \ / _ \ |/ _` | '_ \    | |/ _ \ / _ \| / __|
 |  _  | (_) | | | | | |  __/ | (_| | |_) |   | | (_) | (_) | \__ \
 |_| |_|\___/|_| |_| |_|\___|_|\__,_|_.__/    |_|\___/ \___/|_|___/

EOF
        echo -e "\033[0;36m------------------------------------------------------------\033[0m"
        echo -e "\033[0;32mWelkom terug, $USER!\033[0m"
        echo "Hostname: $HOSTNAME"
        echo "$(date +'%A %d %B %Y, %H:%M')"
        
        # Show version if available
        if [[ -f /opt/homelab-tools/VERSION ]]; then
            HLT_VERSION=$(cat /opt/homelab-tools/VERSION)
            echo -e "Homelab Tools: \033[0;36mv${HLT_VERSION}\033[0m"
        fi
        
        echo -e "\033[0;36m------------------------------------------------------------\033[0m"
        echo ""
    fi
fi
BANNER_EOF
        echo -e "${GREEN}  ✓${RESET} Welcome banner added to ~/.bashrc"
        echo -e "${YELLOW}  →${RESET} Set HLT_BANNER=0 in ~/.bashrc to disable"
    fi
fi
echo ""

# 4. Create templates directory
echo -e "${YELLOW}[4/5]${RESET} Initializing templates..."

# Templates in user home directory
mkdir -p "$ACTUAL_HOME/.local/share/homelab-tools/templates"
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.local/share/homelab-tools" 2>/dev/null || true
echo -e "${GREEN}  ✓${RESET} Templates directory: $ACTUAL_HOME/.local/share/homelab-tools/templates"
echo ""

# 5. Configuration
echo -e "${YELLOW}[5/5]${RESET} Configuring homelab settings..."
echo ""

# Config file in /opt (system-wide)
CONFIG_FILE="$INSTALL_DIR/config.sh"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}→${RESET} Configuring domain settings..."
    echo ""
    echo -e "  What is your homelab domain suffix?"
    echo -e "  ${CYAN}Examples:${RESET}"
    echo -e "    .home  → http://jellyfin.home:8096"
    echo -e "    .local → http://jellyfin.local:8096"
    echo -e "    (empty) → http://jellyfin:8096"
    echo ""
    
    while true; do
        read -p "  Domain suffix (e.g. .home): " domain_suffix
        domain_suffix=${domain_suffix:-.home}

        # Validate domain starts with dot if not empty
        if [[ -n "$domain_suffix" ]] && [[ ! "$domain_suffix" =~ ^\. ]]; then
            echo -e "  ${RED}✗ Domain must start with a dot (e.g. .home)${RESET}"
            echo -e "  ${YELLOW}Or press Enter for no domain${RESET}"
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
# Version: 3.5.0-dev.23

# Domain suffix for your homelab
# Used for Web UI URLs
DOMAIN_SUFFIX="$domain_suffix"

# IP detection method
# Options: "hostname" or "ip"
IP_METHOD="hostname"
EOF

    # Move temp config to final location with sudo
    run_sudo mv "$TEMP_CONFIG" "$CONFIG_FILE"
    run_sudo chmod 644 "$CONFIG_FILE"

    echo -e "${GREEN}  ✓${RESET} Configuration saved: ${CYAN}$domain_suffix${RESET}"
else
    echo -e "${GREEN}  ✓${RESET} Configuration already exists"
    source "$CONFIG_FILE"
    echo -e "    Domain: ${CYAN}${DOMAIN_SUFFIX}${RESET}"
fi
echo ""

# 6. SSH Setup
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${CYAN}           🔑 SSH CONFIGURATION                           ${RESET}"
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo ""

SSH_DIR="$ACTUAL_HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SSH_KEY="$SSH_DIR/id_ed25519"

# Check if .ssh directory exists
if [[ ! -d "$SSH_DIR" ]]; then
    echo -e "${YELLOW}⚠ SSH directory not found${RESET}"
    echo ""
    read -p "Create SSH setup? (Y/n): " setup_ssh
    setup_ssh=${setup_ssh:-y}
    
    if [[ "$setup_ssh" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Creating ~/.ssh directory..."
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
        echo -e "${GREEN}✓${RESET} Directory created"
        echo ""
    fi
fi

# Check if there are SSH keys
if [[ -d "$SSH_DIR" ]] && [[ ! -f "$SSH_KEY" ]] && [[ ! -f "$SSH_DIR/id_rsa" ]]; then
    echo -e "${YELLOW}⚠ No SSH keys found${RESET}"
    echo ""
    read -p "Generate SSH key? (Y/n): " gen_key
    gen_key=${gen_key:-y}
    
    if [[ "$gen_key" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Generating SSH key (ed25519)..."
        read -p "Email for SSH key: " ssh_email
        
        if [[ -n "$ssh_email" ]]; then
            ssh-keygen -t ed25519 -C "$ssh_email" -f "$SSH_KEY" -N ""
            echo -e "${GREEN}✓${RESET} SSH key generated: $SSH_KEY"
            echo -e "${GREEN}✓${RESET} Public key: ${SSH_KEY}.pub"
            echo ""
            echo -e "${BOLD}Your public key:${RESET}"
            cat "${SSH_KEY}.pub"
            echo ""
        else
            echo -e "${RED}✗${RESET} No email provided, key not generated"
        fi
    fi
fi

# Check if SSH config exists
if [[ -d "$SSH_DIR" ]] && [[ ! -f "$SSH_CONFIG" ]]; then
    echo -e "${YELLOW}⚠ SSH config not found${RESET}"
    echo ""
    read -p "Create SSH config? (Y/n): " create_config
    create_config=${create_config:-y}
    
    if [[ "$create_config" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Creating ~/.ssh/config..."
        
        cat > "$SSH_CONFIG" << 'EOF'
# SSH Configuration for Homelab
# Manage with: edit-hosts

# Example host configuration:
# Host jellyfin
#     HostName 192.168.1.100
#     User jochem
#     Port 22
#     IdentityFile ~/.ssh/id_ed25519

EOF
        chmod 600 "$SSH_CONFIG"
        echo -e "${GREEN}✓${RESET} SSH config created"
        echo ""
        echo -e "${BOLD}Add hosts now?${RESET}"
        read -p "Edit SSH config? (Y/n): " edit_config
        edit_config=${edit_config:-y}
        
        if [[ "$edit_config" =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} "$SSH_CONFIG"
            echo -e "${GREEN}✓${RESET} SSH config updated"
        fi
    fi
fi

echo ""

# Check if toilet is installed
if ! command -v toilet &> /dev/null; then
    echo -e "${YELLOW}⚠ Optional: 'toilet' not found${RESET}"
    echo -e "  For ASCII art, install with:"
    echo -e "  ${CYAN}sudo apt install toilet toilet-fonts${RESET}"
    echo ""
fi

# Completion
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
echo -e "║           ✅ INSTALLATION COMPLETE                      ║"
echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${GREEN}✓ Homelab Tools installed!${RESET}"
echo ""
echo -e "${BOLD}Installed Version:${RESET}"
echo -e "  • Version:  ${CYAN}$VERSION${RESET}"
echo -e "  • Branch:   ${CYAN}$BRANCH${RESET}"
echo -e "  • Date:     ${CYAN}$INSTALL_DATE${RESET}"
echo ""
echo -e "${BOLD}Installation Locations:${RESET}"
echo -e "  • Program:   ${CYAN}/opt/homelab-tools/${RESET}"
echo -e "  • Commands:  ${CYAN}~/.local/bin/${RESET}"
echo -e "  • Templates: ${CYAN}~/.local/share/homelab-tools/templates/${RESET}"
echo -e "  • Config:    ${CYAN}/opt/homelab-tools/config.sh${RESET}"
echo ""
echo -e "${BOLD}${YELLOW}Next Steps:${RESET}"
echo ""
echo -e "1. ${CYAN}Start a new terminal or reload shell:${RESET}"
echo -e "   ${GREEN}source ~/.bashrc${RESET}"
echo ""
echo -e "2. ${CYAN}Start the menu:${RESET}"
echo -e "   ${GREEN}homelab${RESET}"
echo ""
echo -e "3. ${CYAN}Or use commands directly:${RESET}"
echo -e "   ${GREEN}generate-motd <service>${RESET}"
echo -e "   ${GREEN}deploy-motd <service>${RESET}"
echo -e "   ${GREEN}list-templates${RESET}"
echo ""
echo -e "4. ${CYAN}For help:${RESET}"
echo -e "   ${GREEN}homelab help${RESET}"
echo -e "   ${GREEN}generate-motd --help${RESET}"
echo ""
echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
echo ""
