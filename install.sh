#!/bin/bash
set -euo pipefail

# Installation script for homelab tools
# Author: J.Bakers
# Version: See VERSION file

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

# Helper function for interactive read (works with curl|bash)
# When stdin is piped, read from /dev/tty instead
# In non-interactive mode, returns default value
# Usage: value=$(read_input "prompt: " "default_value")
read_input() {
    local prompt="$1"
    local default="${2:-}"
    local input
    
    # In non-interactive mode, use default
    if [[ $NON_INTERACTIVE -eq 1 ]]; then
        echo "$default"
        return 0
    fi
    
    if [[ -t 0 ]]; then
        # stdin is a terminal, read normally
        read -r -p "$prompt" input
    else
        # stdin is piped (curl|bash), read from /dev/tty
        read -r -p "$prompt" input </dev/tty || input="$default"
    fi
    echo "${input:-$default}"
}

# Kleuren
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# GitHub repo info
GITHUB_REPO="https://github.com/JBakers/homelab-tools.git"
DEFAULT_BRANCH="main"
NON_INTERACTIVE=0

# Parse command line arguments
INSTALL_BRANCH="${1:-$DEFAULT_BRANCH}"
if [[ "$INSTALL_BRANCH" == "--branch" ]] && [[ -n "${2:-}" ]]; then
    INSTALL_BRANCH="$2"
fi

# Check for non-interactive flag
if [[ "${1:-}" == "--non-interactive" ]] || [[ "${2:-}" == "--non-interactive" ]]; then
    NON_INTERACTIVE=1
fi

# Check if we're in a homelab-tools directory or need to clone
if [[ ! -f "$(pwd)/bin/homelab" ]]; then
    echo -e "${CYAN}Cloning homelab-tools from GitHub (branch: $INSTALL_BRANCH)...${RESET}"
    TEMP_DIR=$(mktemp -d)
    git clone -b "$INSTALL_BRANCH" --depth 1 "$GITHUB_REPO" "$TEMP_DIR" || {
        echo -e "${RED}✗ Error: Failed to clone repository${RESET}"
        rm -rf "$TEMP_DIR"
        exit 1
    }
    cd "$TEMP_DIR"
    echo -e "${GREEN}✓${RESET} Cloned to temporary directory"
    echo ""
    # Re-run install from cloned directory
    exec bash "$TEMP_DIR/install.sh" "--from-clone"
fi

# Get version and branch info
# Use VERSION file as primary source, fallback to bin/homelab header
if [[ -f "VERSION" ]]; then
    VERSION=$(cat VERSION)
elif [[ -f "bin/homelab" ]]; then
    VERSION=$(grep -m1 "Version: " bin/homelab | sed 's/.*Version: //')
else
    VERSION="unknown"
fi
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

INSTALL_DIR="/opt/homelab-tools"

echo -e "${BOLD}Installation directory: ${CYAN}$INSTALL_DIR${RESET}"
echo ""

# 1. Install files to /opt
echo -e "${YELLOW}[1/5]${RESET} Installing to /opt (requires sudo)..."

# Helper: remove symlinks in ~/.local/bin
remove_symlinks() {
    if [[ -d "$ACTUAL_HOME/.local/bin" ]]; then
        find "$ACTUAL_HOME/.local/bin" -maxdepth 1 -type l -lname "$INSTALL_DIR/*" -exec rm -f {} \; 2>/dev/null || true
    fi
}

# Helper: clean user configs/templates and bashrc entries
clean_user_data() {
    rm -rf "$ACTUAL_HOME/.local/share/homelab-tools" 2>/dev/null || true
    
    # Clean .bashrc using safe awk-based removal (same as uninstall.sh)
    if [[ -f "$ACTUAL_HOME/.bashrc" ]] && grep -qi "homelab" "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
        local temp_file
        temp_file="$(mktemp)"
        
        awk '
        BEGIN { 
            in_banner = 0
            banner_depth = 0
        }
        
        # Never touch VS Code shell integration
        /locate-shell-integration-path/ { print; next }
        
        # Skip standalone tip lines (with or without header)
        /^# Homelab Tools tip$/ { 
            getline
            next 
        }
        
        # Skip tip echo line without header
        /^echo -e.*Tip:.*homelab.*commands/ { next }
        /^echo.*Tip:.*homelab/ { next }
        
        # Match banner section start
        /^# ===============================================$/ {
            line1 = $0
            getline
            line2 = $0
            if (line2 ~ /^# Homelab Tools Welcome Banner$/) {
                getline
                line3 = $0
                if (line3 ~ /^# Set HLT_BANNER=0 to disable$/) {
                    getline
                    in_banner = 1
                    banner_depth = 0
                    next
                } else {
                    print line1; print line2; print line3
                    next
                }
            } else {
                print line1; print line2
                next
            }
        }
        
        # Track nested if/fi in banner
        in_banner == 1 {
            if ($0 ~ /^[[:space:]]*if /) banner_depth++
            if ($0 ~ /^[[:space:]]*fi$/) {
                if (banner_depth == 0) {
                    in_banner = 0
                    next
                } else {
                    banner_depth--
                }
            }
            next
        }
        
        { print }
        ' "$ACTUAL_HOME/.bashrc" > "$temp_file"
        
        if bash -n "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$ACTUAL_HOME/.bashrc"
            # Restore ownership to actual user (not root)
            chown "$ACTUAL_USER:$ACTUAL_USER" "$ACTUAL_HOME/.bashrc" 2>/dev/null || true
        else
            rm -f "$temp_file"
        fi
    fi
}

# If an existing install is present, ask what to do
if [[ -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}⚠ Existing installation detected at ${CYAN}$INSTALL_DIR${RESET}"
    echo ""
    echo -e "${BOLD}Choose an action:${RESET}"
    echo -e "  ${CYAN}1${RESET}) Update (backup old, then install) ${YELLOW}(default)${RESET}"
    echo -e "  ${CYAN}2${RESET}) Clean install (remove old, wipe configs, then install) ${RED}(removes templates/configs)${RESET}"
    echo -e "  ${CYAN}3${RESET}) Remove only (keep templates/configs)"
    echo -e "  ${CYAN}4${RESET}) Complete uninstall ${RED}(removes everything including templates/configs)${RESET}"
    echo ""
    existing_choice=$(read_input "Choice (1/2/3/4): ")
    existing_choice=${existing_choice:-1}

    case "$existing_choice" in
        1)
            echo -e "${YELLOW}→${RESET} Proceeding with update (will backup old install)"
            ;;
        2)
            echo -e "${YELLOW}→${RESET} Performing clean install (removing old data)..."
            run_sudo rm -rf "$INSTALL_DIR"
            remove_symlinks
            clean_user_data
            echo -e "${GREEN}✓${RESET} Old installation and user data removed; continuing with clean install."
            ;;
        3)
            echo -e "${YELLOW}→${RESET} Removing existing installation..."
            run_sudo rm -rf "$INSTALL_DIR"
            remove_symlinks
            echo -e "${GREEN}✓${RESET} Removed. Exiting per selection."
            exit 0
            ;;
        4)
            echo -e "${RED}→${RESET} Performing complete uninstall..."
            run_sudo rm -rf "$INSTALL_DIR"
            remove_symlinks
            clean_user_data
            echo -e "${GREEN}✓${RESET} Fully uninstalled. Exiting per selection."
            exit 0
            ;;
        *)
            echo -e "${YELLOW}→${RESET} Invalid choice; defaulting to Update"
            ;;
    esac
fi

# Backup old installation
if [[ -d "$INSTALL_DIR" ]]; then
    backup_dir="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}  →${RESET} Backing up old installation to $backup_dir"
    run_sudo mv "$INSTALL_DIR" "$backup_dir"
fi

# Copy files to /opt (requires sudo)
echo -e "${YELLOW}  →${RESET} Copying files to $INSTALL_DIR..."
run_sudo mkdir -p "$INSTALL_DIR"

# Copy all files except development and GitHub-only files
# Users get: bin/, lib/, config/, install.sh, uninstall.sh, README.md, LICENSE
# Users don't get: tests, dev scripts, design docs, changelogs
run_sudo rsync -a --exclude='.git' \
    --exclude='.test-env' \
    --exclude='.design' \
    --exclude='.archive' \
    --exclude='.github' \
    --exclude='test-runner.sh' \
    --exclude='sync-dev.sh' \
    --exclude='bump-dev.sh' \
    --exclude='merge-to-main.sh' \
    --exclude='release.sh' \
    --exclude='export.sh' \
    --exclude='TESTING-TODO.md' \
    --exclude='TESTING_CHECKLIST.md' \
    --exclude='TEST_SUMMARY.txt' \
    --exclude='CLAUDE-AUDIT.md' \
    --exclude='CHANGELOG.md' \
    --exclude='CONTRIBUTING.md' \
    --exclude='SECURITY.md' \
    --exclude='QUICKSTART.md' \
    --exclude='TODO.md' \
    --exclude='*.backup' \
    --exclude='*.backup.*' \
    --exclude='.dev-workspace' \
    --exclude='claude.md' \
    --exclude='notes*.md' \
    --exclude='conversation*.md' \
    "$(pwd)/" "$INSTALL_DIR/"

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

# Clean up old homelab-tools references in .bashrc (but not .ssh!)
if [[ -f "$ACTUAL_HOME/.bashrc" ]]; then
    echo -e "${YELLOW}  →${RESET} Checking .bashrc for old/duplicate HLT references..."
    
    # Count duplicate HLT tip lines
    tip_count=$(grep -c "Tip: Type.*homelab" "$ACTUAL_HOME/.bashrc" 2>/dev/null || echo "0")
    # Remove any whitespace/newlines
    tip_count=$(echo "$tip_count" | tr -d '[:space:]')
    
    # Check for old PATH exports or duplicates
    needs_cleanup=false
    
    if grep -E "homelab-tools|PATH.*homelab" "$ACTUAL_HOME/.bashrc" 2>/dev/null | grep -v "Tip: Type.*homelab" | grep -qv "^#"; then
        needs_cleanup=true
    fi
    
    if [[ "$tip_count" -gt 1 ]]; then
        needs_cleanup=true
        echo -e "${YELLOW}  ⚠${RESET} Found $tip_count duplicate HLT tip lines"
    fi
    
    if [[ "$needs_cleanup" == "true" ]]; then
        echo -e "${YELLOW}  ⚠${RESET} Cleaning up old/duplicate HLT references..."
        
        # Create backup
        cp "$ACTUAL_HOME/.bashrc" "$ACTUAL_HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Remove old homelab-tools PATH lines (but keep .ssh lines)
        sed -i '/export PATH.*homelab-tools/d' "$ACTUAL_HOME/.bashrc"
        sed -i '/PATH=.*homelab-tools/d' "$ACTUAL_HOME/.bashrc"
        sed -i '/alias.*homelab-tools/d' "$ACTUAL_HOME/.bashrc"

        # Remove any old Homelab banner/tip blocks
        sed -i '/^# Homelab Tools Welcome Banner$/,/^fi$/d' "$ACTUAL_HOME/.bashrc"
        sed -i '/HLT_BANNER/d' "$ACTUAL_HOME/.bashrc"
        sed -i '/Tip:.*homelab/d' "$ACTUAL_HOME/.bashrc"
        
        # Remove duplicate HLT tip lines (keep only lines inside the banner block)
        # First remove standalone tip lines (not inside the banner block)
        sed -i '/^# Homelab Tools tip$/,/^echo.*homelab.*commands"$/d' "$ACTUAL_HOME/.bashrc"
        
        # Remove empty lines that may have accumulated
        sed -i '/^$/N;/^\n$/d' "$ACTUAL_HOME/.bashrc"
        
        echo -e "${GREEN}  ✓${RESET} Cleanup complete (backup created)"
    else
        echo -e "${GREEN}  ✓${RESET} No cleanup needed"
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
        echo "# Homelab Management Tools - PATH" >> "$ACTUAL_HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ACTUAL_HOME/.bashrc"
        echo -e "${GREEN}  ✓${RESET} PATH added to ~/.bashrc"
    fi
else
    echo -e "${YELLOW}  ⚠${RESET} No .bashrc found, creating new one"
    echo '# Homelab Management Tools - PATH' > "$ACTUAL_HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ACTUAL_HOME/.bashrc"
    echo -e "${GREEN}  ✓${RESET} .bashrc created with PATH"
fi

# Add optional welcome banner (only if not already present)
if grep -q "HLT_BANNER" "$ACTUAL_HOME/.bashrc" 2>/dev/null; then
    echo -e "${GREEN}  ✓${RESET} Welcome banner already configured"
else
    echo ""
    add_banner=$(read_input "Add a welcome banner to your shell? (Y/n): " "y")
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
        cat << "ASCIIART"

  _   _                      _       _       _____           _     
 | | | | ___  _ __ ___   ___| | __ _| |__   |_   _|__   ___ | |___ 
 | |_| |/ _ \| '_ ` _ \ / _ \ |/ _` | '_ \    | |/ _ \ / _ \| / __|
 |  _  | (_) | | | | | |  __/ | (_| | |_) |   | | (_) | (_) | \__ \
 |_| |_|\___/|_| |_| |_|\___|_|\__,_|_.__/    |_|\___/ \___/|_|___/

ASCIIART
        echo -e "\033[0;36m------------------------------------------------------------\033[0m"
        echo -e "\033[0;32mWelcome back, $USER!\033[0m"
        echo "Hostname: $HOSTNAME"
        echo "$(date +'%A %d %B %Y, %H:%M')"
        
        # Special occasion messages
        TODAY_MD=$(date +%m-%d)
        case "$TODAY_MD" in
            01-01) echo -e "\033[1;33m🎆 Happy New Year! 🎆\033[0m" ;;
            12-25) echo -e "\033[1;31m🎄 Merry Christmas! 🎄\033[0m" ;;
            12-26) echo -e "\033[0;36m✡️  Happy Hanukkah! ✡️\033[0m" ;;
            10-31) echo -e "\033[1;35m🎃 Happy Halloween! 🎃\033[0m" ;;
            07-04) echo -e "\033[1;34m🎆 Happy Independence Day! 🎆\033[0m" ;;
        esac
        
        # Easter is complex (varies by year), checking approximate range
        MONTH=$(date +%m)
        DAY=$(date +%d)
        if [[ "$MONTH" == "03" || "$MONTH" == "04" ]] && [[ "$DAY" -ge 20 ]] && [[ "$DAY" -le 25 ]]; then
            echo -e "\033[1;33m🐰 Happy Easter! 🐰\033[0m"
        fi
        
        # Show version if available
        if [[ -f /opt/homelab-tools/VERSION ]]; then
            HLT_VERSION=$(cat /opt/homelab-tools/VERSION)
        else
            HLT_VERSION="unknown"
        fi
        echo -e "Homelab Tools: \033[0;36mv${HLT_VERSION}\033[0m"

        echo -e "\033[0;36m------------------------------------------------------------\033[0m"
        echo -e "\033[0;36mTip:\033[0m Type \033[1mhomelab\033[0m for available commands"
        echo ""
    fi
fi
BANNER_EOF
        echo -e "${GREEN}  ✓${RESET} Welcome banner added to ~/.bashrc"
        echo -e "${YELLOW}  →${RESET} Set HLT_BANNER=0 in ~/.bashrc to disable"
    else
        # No banner, but add tip standalone
        echo "" >> "$ACTUAL_HOME/.bashrc"
        echo "# Homelab Tools tip" >> "$ACTUAL_HOME/.bashrc"
        echo -e 'echo -e "\033[0;36mTip:\033[0m Type \033[1mhomelab\033[0m for available commands"' >> "$ACTUAL_HOME/.bashrc"
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
    echo -e "    .home  → http://pihole.home/admin"
    echo -e "    .local → http://pihole.local/admin"
    echo -e "    (empty) → http://pihole/admin"
    echo ""
    
    while true; do
        domain_suffix=$(read_input "  Domain suffix (e.g. .home): ")
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
# Version: See VERSION file

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
    # shellcheck source=/dev/null
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
    setup_ssh=$(read_input "Create SSH setup? (Y/n): ")
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
    gen_key=$(read_input "Generate SSH key? (Y/n): ")
    gen_key=${gen_key:-y}
    
    if [[ "$gen_key" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Generating SSH key (ed25519)..."
        ssh_email=$(read_input "Email for SSH key: ")
        
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
    create_config=$(read_input "Create SSH config? (Y/n): ")
    create_config=${create_config:-y}
    
    if [[ "$create_config" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${YELLOW}→${RESET} Creating ~/.ssh/config..."
        
        cat > "$SSH_CONFIG" << 'EOF'
# SSH Configuration for Homelab
# Manage with: edit-hosts

# Example host configuration:
# Host pihole
#     HostName 192.168.1.100
#     User youruser
#     Port 22
#     IdentityFile ~/.ssh/id_ed25519

EOF
        chmod 600 "$SSH_CONFIG"
        echo -e "${GREEN}✓${RESET} SSH config created"
        echo ""
        echo -e "${BOLD}Add hosts now?${RESET}"
        edit_config=$(read_input "Edit SSH config? (Y/n): ")
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
    echo -e "  For ASCII art MOTDs, toilet is recommended"
    echo ""
    
    if [[ $NON_INTERACTIVE -eq 1 ]]; then
        # Non-interactive: skip prompt
        echo -e "  Install manually: ${CYAN}sudo apt install toilet toilet-fonts${RESET}"
        echo ""
    else
        install_toilet="$(read_input "Install toilet now? (Y/n): " "y")"
        if [[ "$install_toilet" =~ ^[Yy]$ ]] || [[ -z "$install_toilet" ]]; then
            echo -e "${YELLOW}→${RESET} Installing toilet..."
            if run_sudo apt-get update -qq && run_sudo apt-get install -y toilet toilet-fonts; then
                echo -e "${GREEN}✓${RESET} Toilet installed successfully"
            else
                echo -e "${YELLOW}⚠${RESET} Failed to install toilet"
                echo -e "  Install manually: ${CYAN}sudo apt install toilet toilet-fonts${RESET}"
            fi
        else
            echo -e "${YELLOW}→${RESET} Skipped toilet installation"
            echo -e "  Install later: ${CYAN}sudo apt install toilet toilet-fonts${RESET}"
        fi
        echo ""
    fi
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
echo -e "1. ${CYAN}Reload shell configuration:${RESET}"
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

# Auto-reload bashrc if possible (only works if install was not run with sudo)
if [[ -n "$ACTUAL_USER" ]] && [[ "$ACTUAL_USER" != "root" ]] && [[ $EUID -ne 0 ]]; then
    echo -e "${CYAN}→ Reloading shell configuration...${RESET}"
    # Export function to source .bashrc in current shell
    if [[ -f "$ACTUAL_HOME/.bashrc" ]]; then
        # This only works if the script is sourced, not executed
        # So we'll just remind the user instead
        echo -e "${YELLOW}  Please run: ${GREEN}source ~/.bashrc${RESET}"
    fi
fi

# Cleanup temp directory if we cloned from GitHub
if [[ "${1:-}" == "--from-clone" ]] && [[ "$(pwd)" == /tmp/* ]]; then
    cd /
    rm -rf "$(dirname "$0")" 2>/dev/null || true
fi
