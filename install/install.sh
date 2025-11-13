#!/bin/bash
# Homelab Tools Installer
# Installeert alle homelab management scripts
# by J.Bakers

# Kleuren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}      Homelab Tools Installer v1.0${NC}"
echo -e "${BLUE}              by J.Bakers${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Check of we in de juiste directory zitten
if [[ ! -d "$TOOLS_DIR/bin" ]]; then
    echo -e "${RED}Fout: Kan bin/ directory niet vinden${NC}"
    echo -e "${RED}Run dit script vanuit de homelab-tools/install/ directory${NC}"
    exit 1
fi

# Installatie type vragen
echo -e "${YELLOW}Kies installatie type:${NC}"
echo "  1) Volledige installatie (scripts + config templates)"
echo "  2) Alleen scripts (zonder MOTD templates)"
echo "  3) Update alleen scripts (behoud huidige config)"
echo ""
read -p "Keuze [1-3]: " install_type

case $install_type in
    1|"")
        INSTALL_SCRIPTS=true
        INSTALL_CONFIG=true
        ;;
    2)
        INSTALL_SCRIPTS=true
        INSTALL_CONFIG=false
        ;;
    3)
        INSTALL_SCRIPTS=true
        INSTALL_CONFIG=false
        ;;
    *)
        echo -e "${RED}Ongeldige keuze${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Installatie starten...${NC}"
echo ""

# Maak directories aan
mkdir -p ~/.local/bin
mkdir -p ~/.config

# Installeer scripts
if [[ "$INSTALL_SCRIPTS" == true ]]; then
    echo -e "${YELLOW}→ Installeren van scripts...${NC}"
    
    scripts=("homelab" "generate-motd" "deploy-motd" "copykey" "cleanup-homelab")
    
    for script in "${scripts[@]}"; do
        if [[ -f "$TOOLS_DIR/bin/$script" ]]; then
            cp "$TOOLS_DIR/bin/$script" ~/.local/bin/
            chmod +x ~/.local/bin/$script
            echo -e "${GREEN}  ✓ $script${NC}"
        else
            echo -e "${YELLOW}  ⊘ $script niet gevonden${NC}"
        fi
    done
fi

# Installeer config
if [[ "$INSTALL_CONFIG" == true ]]; then
    echo ""
    echo -e "${YELLOW}→ Installeren van configuratie...${NC}"
    
    # MOTD templates
    if [[ -d "$TOOLS_DIR/config/server-motd" ]]; then
        if [[ -d ~/.config/server-motd ]]; then
            echo -e "${YELLOW}  ⊘ server-motd directory bestaat al${NC}"
            read -p "  Overschrijven? (y/n): " overwrite
            if [[ "$overwrite" == "y" ]]; then
                cp -r "$TOOLS_DIR/config/server-motd" ~/.config/
                echo -e "${GREEN}  ✓ MOTD templates geïnstalleerd${NC}"
            fi
        else
            cp -r "$TOOLS_DIR/config/server-motd" ~/.config/
            echo -e "${GREEN}  ✓ MOTD templates geïnstalleerd${NC}"
        fi
    fi
    
    # SSH config voorbeeld
    if [[ -f "$TOOLS_DIR/config/ssh-config.example" ]]; then
        if [[ ! -f ~/.ssh/config ]]; then
            echo -e "${YELLOW}  → Geen SSH config gevonden${NC}"
            read -p "  Wil je het voorbeeld gebruiken? (y/n): " use_example
            if [[ "$use_example" == "y" ]]; then
                mkdir -p ~/.ssh
                cp "$TOOLS_DIR/config/ssh-config.example" ~/.ssh/config
                chmod 600 ~/.ssh/config
                echo -e "${GREEN}  ✓ SSH config geïnstalleerd${NC}"
                echo -e "${YELLOW}  ! Pas ~/.ssh/config aan met jouw server gegevens${NC}"
            fi
        else
            echo -e "${GREEN}  ✓ SSH config bestaat al${NC}"
        fi
    fi
fi

# Check of ~/.local/bin in PATH zit
echo ""
echo -e "${YELLOW}→ Controleren PATH...${NC}"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}  ! ~/.local/bin staat niet in je PATH${NC}"
    echo ""
    echo -e "${BLUE}  Voeg dit toe aan je ~/.bashrc of ~/.profile:${NC}"
    echo -e "${GREEN}    export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo ""
    read -p "  Automatisch toevoegen aan ~/.bashrc? (y/n): " add_path
    if [[ "$add_path" == "y" ]]; then
        echo '' >> ~/.bashrc
        echo '# Homelab tools PATH' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo -e "${GREEN}  ✓ PATH toegevoegd aan ~/.bashrc${NC}"
        echo -e "${YELLOW}  ! Run 'source ~/.bashrc' of log opnieuw in${NC}"
    fi
else
    echo -e "${GREEN}  ✓ PATH is correct geconfigureerd${NC}"
fi

# Dependencies check
echo ""
echo -e "${YELLOW}→ Controleren van dependencies...${NC}"

deps=("ssh" "figlet")
missing_deps=()

for dep in "${deps[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo -e "${GREEN}  ✓ $dep${NC}"
    else
        echo -e "${RED}  ✗ $dep (niet gevonden)${NC}"
        missing_deps+=("$dep")
    fi
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}Ontbrekende dependencies installeren:${NC}"
    echo -e "${BLUE}  sudo apt install ${missing_deps[*]}${NC}"
fi

# Installatie compleet
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}✓ Installatie compleet!${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo -e "${YELLOW}Beschikbare commando's:${NC}"
echo -e "${GREEN}  homelab${NC}          - Toon overzicht van alle commando's"
echo -e "${GREEN}  generate-motd${NC}    - Maak MOTD templates"
echo -e "${GREEN}  deploy-motd${NC}      - Deploy MOTD naar servers"
echo -e "${GREEN}  copykey${NC}          - Kopieer SSH keys"
echo -e "${GREEN}  cleanup-homelab${NC}  - Opruimen van oude templates"
echo ""
echo -e "${YELLOW}Volgende stappen:${NC}"
echo "  1. Pas ~/.ssh/config aan met je server gegevens"
echo "  2. Run 'copykey' om SSH keys te distribueren"
echo "  3. Run 'generate-motd' om MOTD templates te maken"
echo "  4. Run 'deploy-motd' om ze uit te rollen"
echo ""
