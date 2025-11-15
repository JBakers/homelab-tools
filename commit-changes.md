diff --git a/CHANGELOG.md b/CHANGELOG.md
index 672ec27..70d4a09 100644
--- a/CHANGELOG.md
+++ b/CHANGELOG.md
@@ -1,4 +1,46 @@
 # Changelog - Homelab Tools
+## v3.4.0 (16 november 2025)
+
+### Changes
+
+- TBD: Add your changes here
+
+---
+
+
+## v3.3.0 (15 November 2025)
+
+### 🏗️ Installation Structure Improvements
+
+#### Clean Directory Structure
+
+- **Program Location** - Moved from `~/homelab-tools/` to `/opt/homelab-tools/`
+  - Follows Linux Filesystem Hierarchy Standard (FHS)
+  - Keeps home directory clean and organized
+  - System-wide installation for all users
+- **Symlinks** - Changed from `/usr/local/bin/` to `~/.local/bin/`
+  - Standard user bin directory
+  - No sudo needed for symlinks
+  - Automatically in PATH for most systems
+- **User Data** - Templates remain in `~/.local/share/homelab-tools/templates/`
+  - Follows XDG Base Directory specification
+  - User data separate from program files
+
+### 🐛 Bug Fixes
+
+#### Uninstall Script
+
+- **Fixed** - `$INSTALL_DIR` unbound variable error
+- **Improved** - Backward compatibility with old installation paths
+- **Enhanced** - Proper cleanup of all components
+
+### 📝 Documentation
+
+- Updated all script versions to 3.3.0
+- Added clear sudo requirements in README
+- Updated installation instructions
+
+---
 
 ## v3.2.0 (15 November 2025)
 
@@ -55,7 +97,7 @@
 
 ### 📝 Documentation
 
-- Updated all script versions to 3.2.0
+- Updated all script versions to 3.3.0
 - Security audit completed - no critical issues remaining
 - All 13 scripts hardened and validated
 
diff --git a/README.md b/README.md
index 70b7241..50ed6e5 100644
--- a/README.md
+++ b/README.md
@@ -1,6 +1,6 @@
-# 🏠 Homelab Management Tools v3.2.0 
+# 🏠 Homelab Management Tools v3.4.0 
 
-[![Version](https://img.shields.io/badge/version-3.2.0-blue.svg)](https://github.com/JBakers/homelab-tools/releases)
+[![Version](https://img.shields.io/badge/version-3.4.0-blue.svg)](https://github.com/JBakers/homelab-tools/releases)
 [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
 [![Shell](https://img.shields.io/badge/shell-bash-lightgrey.svg)](https://www.gnu.org/software/bash/)
 
@@ -18,7 +18,8 @@ Streamline your homelab management with auto-detecting MOTD generators, bulk ope
 
 ### 🎨 Beautiful Interface
 
-- **Rainbow ASCII Art** - Eye-catching banners with `toilet -F gay`
+- **Clean & Functional MOTDs** - Professional login screens with system info (default)
+- **Optional ASCII Art** - 5 colorful styles including rainbow banners with `toilet -F gay`
 - **Color-Coded Output** - Clear visual feedback with ANSI colors
 - **Interactive Menus** - Intuitive TUI for all operations
 
@@ -49,9 +50,9 @@ Streamline your homelab management with auto-detecting MOTD generators, bulk ope
 cd ~
 git clone https://github.com/JBakers/homelab-tools.git
 
-# Run the installer
+# Run the installer (requires sudo for /opt installation)
 cd homelab-tools
-./install.sh
+sudo ./install.sh
 
 # Reload your shell
 source ~/.bashrc
@@ -121,6 +122,65 @@ ssh jellyfin
 
 **That's it!** The tool auto-detected the service, created a template, and deployed it.
 
+## 🎨 MOTD Styles
+
+The tool offers clean, functional MOTDs by default, with optional ASCII art for a more colorful look.
+
+### Clean & Functional (Default)
+
+**Professional, informative, and always readable:**
+
+```
+==========================================
+  Jellyfin
+  Media Server
+  by J.Bakers
+==========================================
+
+📊 System Information:
+
+  🖥️  Hostname:    jellyfin
+  🌐 IP Address:  192.168.1.10
+  ⏱️  Uptime:      3 days, 12 hours
+  🐋 Docker:      24.0.7
+  🔗 Web UI:      http://jellyfin:8096
+
+==========================================
+```
+
+### Optional ASCII Art Styles
+
+<details>
+<summary><strong>Click to view ASCII art examples</strong></summary>
+
+**1. Rainbow Future** (Colorful, modern)
+**2. Rainbow Standard** (Colorful, classic)
+**3. Mono Future** (Black & white, modern)
+**4. Big Mono** (Large, bold)
+**5. Small/Smblock** (Compact)
+
+Choose during generation with `generate-motd <service>`, or press 'p' for a live preview.
+
+**Example Rainbow Future:**
+
+```
+     ███████╗███████╗██╗     ██╗  ██╗   ██╗███████╗██╗███╗   ██╗
+     ██╔════╝██╔════╝██║     ██║  ╚██╗ ██╔╝██╔════╝██║████╗  ██║
+     █████╗  █████╗  ██║     ██║   ╚████╔╝ █████╗  ██║██╔██╗ ██║
+     ██╔══╝  ██╔══╝  ██║     ██║    ╚██╔╝  ██╔══╝  ██║██║╚██╗██║
+     ███████╗███████╗███████╗███████╗██║   ██║   ██║██║ ╚████║
+     ╚══════╝╚══════╝╚══════╝╚══════╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝
+                                                    (in rainbow colors!)
+        Media Server
+           by J.Bakers
+
+==========================================
+   📊 System Information:
+...
+```
+
+</details>
+
 ## 🎮 Usage
 
 ### 📋 Interactive Menu
@@ -136,7 +196,7 @@ homelab
 
 ```
 ╔════════════════════════════════════════════════════════════╗
-║           🏠 HOMELAB MANAGEMENT TOOLS v3.2.0               ║
+║           🏠 HOMELAB MANAGEMENT TOOLS v3.4.0               ║
 ║                    by J.Bakers                             ║
 ╚════════════════════════════════════════════════════════════╝
 
@@ -236,10 +296,12 @@ copykey
 - **ssh** - OpenSSH client
 - **coreutils** - Standard GNU utilities (grep, sed, awk, etc.)
 
-### Optional (but recommended)
+### Optional
+
+- **toilet** - For ASCII art in MOTDs (5 colorful styles available)
+- **toilet-fonts** - Additional ASCII art fonts
 
-- **toilet** - For rainbow ASCII art in MOTDs
-- **toilet-fonts** - Additional fonts for ASCII art
+**Note:** The tool works perfectly without `toilet` - it will use clean, functional MOTDs by default.
 
 ### Installation
 
@@ -438,21 +500,25 @@ ssh yourhost  # Try again
 </details>
 
 <details>
-<summary><strong>No ASCII art in MOTD</strong></summary>
-
-**Problem:** ASCII art doesn't render.
+<summary><strong>Want ASCII art in your MOTD?</strong></summary>
 
-**Solution:**
+**By default, MOTDs use a clean, functional style.** To use ASCII art:
 
 ```bash
-# Install toilet (optional but recommended)
+# Install toilet (optional)
 sudo apt install toilet toilet-fonts
 
-# Regenerate MOTD
+# Generate MOTD and choose ASCII style (2-6)
 generate-motd yourservice
+# When prompted, select option 2-6 for ASCII art
+# Or press 'p' to preview all styles
+
+# Deploy
 deploy-motd yourservice
 ```
 
+**Available ASCII styles:** Rainbow Future, Rainbow Standard, Mono Future, Big Mono, Small/Smblock
+
 </details>
 
 ### 💬 Still having issues?
diff --git a/bin/bulk-generate-motd b/bin/bulk-generate-motd
index c3e2729..d015a01 100755
--- a/bin/bulk-generate-motd
+++ b/bin/bulk-generate-motd
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Bulk generate MOTD templates for all hosts
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
@@ -105,8 +105,9 @@ for hostname in $hosts; do
             echo -e "  ${YELLOW}⚠${RESET} Template exists, overwriting..."
         fi
         
-        # Generate with auto-detection
-        echo -e "n\ny\n" | generate-motd "$hostname" &>/dev/null
+        # Generate with auto-detection (clean MOTD = style 1)
+        # Answers: style=1 (clean), customize=n, deploy=y
+        echo -e "1\nn\ny\n" | generate-motd "$hostname" &>/dev/null
         
         if [[ -f "$template_file" ]]; then
             echo -e "  ${GREEN}✓${RESET} Generated successfully"
@@ -140,20 +141,28 @@ for hostname in $hosts; do
     
     # Vraag hoe te genereren
     echo -e "  Generate MOTD for ${CYAN}$hostname${RESET}?"
-    echo -e "    ${GREEN}y${RESET}) Yes, use auto-detection"
-    echo -e "    ${GREEN}i${RESET}) Interactive (ask for details)"
+    echo -e "    ${GREEN}y${RESET}) Yes, use auto-detection (clean MOTD)"
+    echo -e "    ${GREEN}i${RESET}) Interactive (choose style, details)"
+    echo -e "    ${GREEN}a${RESET}) Yes to all remaining (clean MOTDs)"
     echo -e "    ${GREEN}n${RESET}) Skip"
-    read -p "  Choice (Y/i/n): " choice
+    read -p "  Choice (Y/i/a/n): " choice
     choice=${choice:-y}
+
+    # Handle "yes to all" - switch to AUTO_ALL mode
+    if [[ "$choice" =~ ^[Aa]$ ]]; then
+        AUTO_ALL=true
+        echo -e "  ${GREEN}✓${RESET} Switching to auto-mode for remaining hosts"
+        choice="y"
+    fi
     
     case "$choice" in
         y|Y)
             # Gebruik auto-detection en defaults
-            echo -e "  ${YELLOW}→${RESET} Generating with auto-detection..."
-            
-            # Call generate-motd met alleen hostname - laat auto-detection werken
-            # Feed alleen de customize en deploy prompts met defaults
-            echo -e "n\ny\n" | generate-motd "$hostname" &>/dev/null
+            echo -e "  ${YELLOW}→${RESET} Generating with auto-detection (clean MOTD)..."
+
+            # Call generate-motd met auto-detection
+            # Answers: style=1 (clean), customize=n, deploy=y
+            echo -e "1\nn\ny\n" | generate-motd "$hostname" &>/dev/null
             
             if [[ -f "$template_file" ]]; then
                 echo -e "  ${GREEN}✓${RESET} Generated successfully"
diff --git a/bin/cleanup-homelab b/bin/cleanup-homelab
index 2fdf1cb..b938848 100755
--- a/bin/cleanup-homelab
+++ b/bin/cleanup-homelab
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Cleanup orphaned MOTD templates
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 CONFIG_FILE="$HOME/.ssh/config"
 MOTD_DIR="$HOME/.local/share/homelab-tools/templates"
diff --git a/bin/cleanup-keys b/bin/cleanup-keys
index 6c961b0..5034d3f 100755
--- a/bin/cleanup-keys
+++ b/bin/cleanup-keys
@@ -7,7 +7,7 @@ set -euo pipefail
 
 # Cleanup old SSH host keys
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
diff --git a/bin/copykey b/bin/copykey
index cad5fd8..19bdb45 100755
--- a/bin/copykey
+++ b/bin/copykey
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Copy SSH key to remote hosts
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
diff --git a/bin/deploy-motd b/bin/deploy-motd
index 3c450d9..76e2609 100755
--- a/bin/deploy-motd
+++ b/bin/deploy-motd
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Deploy MOTD to remote host
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
diff --git a/bin/edit-config b/bin/edit-config
index 14e9b59..8bf0a94 100755
--- a/bin/edit-config
+++ b/bin/edit-config
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Edit homelab tools configuration
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
@@ -67,7 +67,7 @@ fi
 cat > "$CONFIG_FILE" << EOF
 # Homelab Tools Configuration
 # Author: J.Bakers
-# Version: 3.1.0
+# Version: 3.4.0
 
 # Domain suffix voor je homelab
 # Wordt gebruikt voor Web UI URLs
diff --git a/bin/edit-hosts b/bin/edit-hosts
index 0f9bcc7..905d80e 100755
--- a/bin/edit-hosts
+++ b/bin/edit-hosts
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Edit SSH host configuration
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
diff --git a/bin/generate-motd b/bin/generate-motd
index f5283f6..8792fa5 100755
--- a/bin/generate-motd
+++ b/bin/generate-motd
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Generate MOTD template for homelab services
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
@@ -512,97 +512,109 @@ show_ascii_preview() {
 }
 
 # Toon beschikbare stijlen
-echo -e "${BOLD}Beschikbare ASCII art stijlen:${RESET}"
+echo -e "${BOLD}Beschikbare MOTD stijlen:${RESET}"
+echo ""
+
+echo -e "${CYAN}1)${RESET} Clean & Functional ${YELLOW}(Geen ASCII - Netjes & Informatief)${RESET} ${GREEN}[Default]${RESET}"
 echo ""
 
 if command -v toilet &> /dev/null; then
-    echo -e "${CYAN}1)${RESET} Rainbow Future   ${YELLOW}(Kleurrijk, modern)${RESET}"
-    echo -e "${CYAN}2)${RESET} Rainbow Standard ${YELLOW}(Kleurrijk, klassiek)${RESET}"
-    echo -e "${CYAN}3)${RESET} Mono Future      ${YELLOW}(Zwart-wit, modern)${RESET}"
-    echo -e "${CYAN}4)${RESET} Big Mono         ${YELLOW}(Groot, vet)${RESET}"
-    echo -e "${CYAN}5)${RESET} Small/Smblock    ${YELLOW}(Klein, compact)${RESET}"
-    echo -e "${CYAN}p)${RESET} Preview all styles"
+    echo -e "${BOLD}Optionele ASCII art stijlen:${RESET}"
+    echo -e "${CYAN}2)${RESET} Rainbow Future   ${YELLOW}(Kleurrijk, modern)${RESET}"
+    echo -e "${CYAN}3)${RESET} Rainbow Standard ${YELLOW}(Kleurrijk, klassiek)${RESET}"
+    echo -e "${CYAN}4)${RESET} Mono Future      ${YELLOW}(Zwart-wit, modern)${RESET}"
+    echo -e "${CYAN}5)${RESET} Big Mono         ${YELLOW}(Groot, vet)${RESET}"
+    echo -e "${CYAN}6)${RESET} Small/Smblock    ${YELLOW}(Klein, compact)${RESET}"
+    echo -e "${CYAN}p)${RESET} Preview ASCII styles"
 else
-    echo -e "${YELLOW}⚠ Toilet niet geïnstalleerd - alleen basis stijl beschikbaar${RESET}"
-    echo -e "  Installeer: ${GREEN}sudo apt install toilet toilet-fonts${RESET}"
-    echo ""
-    ascii_style="basic"
+    echo -e "${YELLOW}⚠ Toilet niet geïnstalleerd - ASCII art niet beschikbaar${RESET}"
+    echo -e "  Voor ASCII art: ${GREEN}sudo apt install toilet toilet-fonts${RESET}"
 fi
 
-if command -v toilet &> /dev/null; then
-    echo ""
-    read -p "$(echo -e ${GREEN}Kies stijl [1-5, p voor preview]:${RESET} )" style_choice
-    
-    # Preview mode
-    if [[ "$style_choice" == "p" ]] || [[ "$style_choice" == "P" ]]; then
+echo ""
+read -p "$(echo -e ${GREEN}Kies stijl [1-6, p voor preview]:${RESET} )" style_choice
+
+# Preview mode
+if [[ "$style_choice" == "p" ]] || [[ "$style_choice" == "P" ]]; then
+    if command -v toilet &> /dev/null; then
         clear
         echo -e "${BOLD}${CYAN}ASCII Art Preview - \"$service_name\"${RESET}"
         echo ""
-        
-        echo -e "${CYAN}1) Rainbow Future:${RESET}"
+
+        echo -e "${CYAN}2) Rainbow Future:${RESET}"
         show_ascii_preview "$service_name" "future" "gay"
         echo ""
-        
-        echo -e "${CYAN}2) Rainbow Standard:${RESET}"
+
+        echo -e "${CYAN}3) Rainbow Standard:${RESET}"
         show_ascii_preview "$service_name" "standard" "gay"
         echo ""
-        
-        echo -e "${CYAN}3) Mono Future:${RESET}"
+
+        echo -e "${CYAN}4) Mono Future:${RESET}"
         show_ascii_preview "$service_name" "future" ""
         echo ""
-        
-        echo -e "${CYAN}4) Big Mono:${RESET}"
+
+        echo -e "${CYAN}5) Big Mono:${RESET}"
         show_ascii_preview "$service_name" "bigmono9" ""
         echo ""
-        
-        echo -e "${CYAN}5) Small/Smblock:${RESET}"
+
+        echo -e "${CYAN}6) Small/Smblock:${RESET}"
         show_ascii_preview "$service_name" "smblock" ""
         echo ""
-        
-        read -p "$(echo -e ${GREEN}Kies stijl [1-5]:${RESET} )" style_choice
+
+        read -p "$(echo -e ${GREEN}Kies stijl [1-6]:${RESET} )" style_choice
+    else
+        echo -e "${YELLOW}⚠${RESET} Preview niet beschikbaar (toilet niet geïnstalleerd)"
+        style_choice="1"
     fi
-    
-    # Bepaal font en filter op basis van keuze
-    case "$style_choice" in
-        1|"")
-            ascii_font="future"
-            ascii_filter="gay"
-            echo -e "${GREEN}✓${RESET} Gekozen: Rainbow Future"
-            ;;
-        2)
-            ascii_font="standard"
-            ascii_filter="gay"
-            echo -e "${GREEN}✓${RESET} Gekozen: Rainbow Standard"
-            ;;
-        3)
-            ascii_font="future"
-            ascii_filter=""
-            echo -e "${GREEN}✓${RESET} Gekozen: Mono Future"
-            ;;
-        4)
-            ascii_font="bigmono9"
-            ascii_filter=""
-            echo -e "${GREEN}✓${RESET} Gekozen: Big Mono"
-            ;;
-        5)
-            ascii_font="smblock"
-            ascii_filter=""
-            echo -e "${GREEN}✓${RESET} Gekozen: Small/Smblock"
-            ;;
-        *)
-            ascii_font="future"
-            ascii_filter="gay"
-            echo -e "${YELLOW}⚠${RESET} Ongeldige keuze, gebruik Rainbow Future"
-            ;;
-    esac
-else
-    ascii_font="basic"
-    ascii_filter=""
 fi
 
+# Bepaal font en filter op basis van keuze
+case "$style_choice" in
+    1|"")
+        # Clean & Functional - geen ASCII art
+        ascii_font="none"
+        ascii_filter=""
+        echo -e "${GREEN}✓${RESET} Gekozen: Clean & Functional (geen ASCII)"
+        ;;
+    2)
+        ascii_font="future"
+        ascii_filter="gay"
+        echo -e "${GREEN}✓${RESET} Gekozen: Rainbow Future"
+        ;;
+    3)
+        ascii_font="standard"
+        ascii_filter="gay"
+        echo -e "${GREEN}✓${RESET} Gekozen: Rainbow Standard"
+        ;;
+    4)
+        ascii_font="future"
+        ascii_filter=""
+        echo -e "${GREEN}✓${RESET} Gekozen: Mono Future"
+        ;;
+    5)
+        ascii_font="bigmono9"
+        ascii_filter=""
+        echo -e "${GREEN}✓${RESET} Gekozen: Big Mono"
+        ;;
+    6)
+        ascii_font="smblock"
+        ascii_filter=""
+        echo -e "${GREEN}✓${RESET} Gekozen: Small/Smblock"
+        ;;
+    *)
+        # Default to clean functional
+        ascii_font="none"
+        ascii_filter=""
+        echo -e "${YELLOW}⚠${RESET} Ongeldige keuze, gebruik Clean & Functional"
+        ;;
+esac
+
 # Genereer ASCII art LOKAAL
 rainbow_art=""
-if [[ "$ascii_font" == "basic" ]]; then
+if [[ "$ascii_font" == "none" ]]; then
+    # Clean & Functional - geen ASCII art, alleen service naam
+    rainbow_art=""
+elif [[ "$ascii_font" == "basic" ]]; then
     # Fallback: figlet of plain text
     if command -v figlet &> /dev/null; then
         rainbow_art=$(figlet -c "$service_name" 2>/dev/null)
@@ -616,7 +628,7 @@ else
     else
         rainbow_art=$(toilet -f "$ascii_font" "$service_name" 2>/dev/null)
     fi
-    
+
     # Fallback als font niet werkt
     if [[ -z "$rainbow_art" ]]; then
         rainbow_art=$(toilet -f standard -F gay "$service_name" 2>/dev/null)
@@ -668,19 +680,42 @@ fi
 UPTIME=$(uptime -p | sed 's/up //')
 
 VERSION_CHECK_PLACEHOLDER
+TEMPLATE_START
+
+# Voeg ASCII art toe of clean header - afhankelijk van de keuze
+if [[ "$ascii_font" == "none" ]]; then
+    # Clean & Functional - geen ASCII art
+    cat >> "$TEMPLATES_DIR/$SERVICE.sh" << 'TEMPLATE_CLEAN'
+
+echo ""
+echo -e "${BLUE}==========================================${NC}"
+echo -e "  ${CYAN}${BOLD}SERVICE_NAME_PLACEHOLDER${NC}"
+echo -e "  ${MAGENTA}DESCRIPTION_PLACEHOLDER${NC}"
+echo -e "  ${MAGENTA}by J.Bakers${NC}"
+echo -e "${BLUE}==========================================${NC}"
+echo ""
+echo -e "${GREEN}${BOLD}📊 System Information:${NC}"
+echo ""
+echo -e "  ${YELLOW}🖥️  Hostname:${NC}    $HOSTNAME"
+echo -e "  ${YELLOW}🌐 IP Address:${NC}  $IP_ADDRESS"
+echo -e "  ${YELLOW}⏱️  Uptime:${NC}      $UPTIME"
+TEMPLATE_CLEAN
+else
+    # ASCII art versie
+    cat >> "$TEMPLATES_DIR/$SERVICE.sh" << 'TEMPLATE_ASCII_START'
 
-# Rainbow ASCII Art (met lichte indent)
+# ASCII Art (met lichte indent)
 echo ""
 while IFS= read -r line; do
     printf "     %s\n" "$line"
 done << 'ASCII_ART'
-TEMPLATE_START
+TEMPLATE_ASCII_START
 
-# Voeg de ASCII art toe als een heredoc blok (behoudt alle ANSI codes)
-echo "$rainbow_art" >> "$TEMPLATES_DIR/$SERVICE.sh"
+    # Voeg de ASCII art toe als een heredoc blok (behoudt alle ANSI codes)
+    echo "$rainbow_art" >> "$TEMPLATES_DIR/$SERVICE.sh"
 
-# Sluit de ASCII art heredoc af en ga verder met de template
-cat >> "$TEMPLATES_DIR/$SERVICE.sh" << 'TEMPLATE_MIDDLE'
+    # Sluit de ASCII art heredoc af en ga verder met de template
+    cat >> "$TEMPLATES_DIR/$SERVICE.sh" << 'TEMPLATE_ASCII_MIDDLE'
 ASCII_ART
 echo ""
 echo -e "        ${CYAN}DESCRIPTION_PLACEHOLDER${NC}"
@@ -693,7 +728,8 @@ echo ""
 echo -e "  ${YELLOW}🖥️  Hostname:${NC}    $HOSTNAME"
 echo -e "  ${YELLOW}🌐 IP Address:${NC}  $IP_ADDRESS"
 echo -e "  ${YELLOW}⏱️  Uptime:${NC}      $UPTIME"
-TEMPLATE_MIDDLE
+TEMPLATE_ASCII_MIDDLE
+fi
 
 # Voeg versie checks toe indien van toepassing
 if [[ -n "$version_check" ]]; then
@@ -719,9 +755,11 @@ if [[ -n "$HASS_VERSION" ]]; then
 fi
 VERSION_DISPLAY
 
-# Vervang description placeholder (escape special characters for sed)
+# Vervang description en service name placeholders (escape special characters for sed)
 description_escaped=$(echo "$description" | sed 's/[\/&]/\\&/g')
+service_name_escaped=$(echo "$service_name" | sed 's/[\/&]/\\&/g')
 sed -i "s/DESCRIPTION_PLACEHOLDER/$description_escaped/g" "$TEMPLATES_DIR/$SERVICE.sh"
+sed -i "s/SERVICE_NAME_PLACEHOLDER/$service_name_escaped/g" "$TEMPLATES_DIR/$SERVICE.sh"
 
 # Web UI toevoegen als nodig
 if [[ -n "$webui_port" ]]; then
diff --git a/bin/homelab b/bin/homelab
index 6969039..cffb5f4 100755
--- a/bin/homelab
+++ b/bin/homelab
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Homelab Management Menu
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren (zelfde stijl als MOTD)
 CYAN='\033[0;36m'
@@ -18,20 +18,20 @@ RESET='\033[0m'
 # Help functie (kort overzicht)
 show_help() {
     echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
-    echo -e "║         🏠 HOMELAB MANAGEMENT TOOLS v3.2.0              ║"
+    echo -e "║         🏠 Homelab Management Tools v3.3.0              ║"
     echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
     echo ""
-    echo -e "${BOLD}${BLUE}AVAILABLE COMMANDS:${RESET}"
+    echo -e "${BOLD}${BLUE}Available commands:${RESET}"
     echo ""
     echo -e "  ${YELLOW}generate-motd${RESET}         Generate MOTD for a service"
     echo -e "  ${YELLOW}bulk-generate-motd${RESET}    Generate MOTDs for all hosts"
     echo -e "  ${YELLOW}deploy-motd${RESET}           Deploy MOTD to container"
     echo -e "  ${YELLOW}cleanup-keys${RESET}          Remove old SSH keys"
     echo -e "  ${YELLOW}list-templates${RESET}        Show all MOTD templates"
-    echo -e "  ${YELLOW}edit-ssh${RESET}              Edit SSH configuration"
+    echo -e "  ${YELLOW}edit-hosts${RESET}            Edit SSH configuration"
     echo -e "  ${YELLOW}copykey${RESET}               Distribute SSH keys"
     echo ""
-    echo -e "${BOLD}${BLUE}USAGE:${RESET}"
+    echo -e "${BOLD}${BLUE}Usage:${RESET}"
     echo -e "  ${GREEN}homelab${RESET}               Show interactive menu"
     echo -e "  ${GREEN}homelab help${RESET}          Show detailed help"
     echo -e "  ${GREEN}<command> --help${RESET}     Show help for specific command"
@@ -42,10 +42,10 @@ show_help() {
 # Gedetailleerde help
 show_detailed_help() {
     echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗"
-    echo -e "║        🏠 HOMELAB TOOLS - DETAILED HELP                 ║"
+    echo -e "║        🏠 Homelab Tools - Detailed Help                 ║"
     echo -e "╚════════════════════════════════════════════════════════════╝${RESET}"
     echo ""
-    echo -e "${BOLD}${BLUE}MOTD (Message of the Day) SYSTEM:${RESET}"
+    echo -e "${BOLD}${BLUE}MOTD (Message of the Day) system:${RESET}"
     echo -e "────────────────────────────────────────"
     echo -e "Creates beautiful, dynamic login screens for your servers with:"
     echo -e "  • Rainbow ASCII art (using toilet)"
@@ -61,7 +61,7 @@ show_detailed_help() {
     echo -e "The MOTD is generated dynamically at each login,"
     echo -e "so information like uptime is always current."
     echo ""
-    echo -e "${BOLD}${BLUE}HOST MANAGEMENT:${RESET}"
+    echo -e "${BOLD}${BLUE}Host management:${RESET}"
     echo -e "────────────────────────────────────────"
     echo -e "Your hosts are configured in ~/.ssh/config"
     echo -e "All homelab tools use this for host access."
@@ -69,12 +69,12 @@ show_detailed_help() {
     echo -e "  ${GREEN}edit-hosts${RESET}     Edit your host configuration"
     echo -e "  ${GREEN}copykey${RESET}        Distribute SSH keys to all hosts"
     echo ""
-    echo -e "${BOLD}${BLUE}REQUIREMENTS:${RESET}"
+    echo -e "${BOLD}${BLUE}Requirements:${RESET}"
     echo -e "────────────────────────────────────────"
     echo -e "  • toilet (for ASCII art): ${GREEN}sudo apt install toilet toilet-fonts${RESET}"
     echo -e "  • figlet (fallback): ${GREEN}sudo apt install figlet${RESET}"
     echo ""
-    echo -e "${BOLD}${BLUE}EXAMPLES:${RESET}"
+    echo -e "${BOLD}${BLUE}Examples:${RESET}"
     echo -e "────────────────────────────────────────"
     echo -e "  ${GREEN}bulk-generate-motd${RESET}"
     echo -e "    → Scan host list and generate MOTDs for all hosts"
@@ -88,7 +88,7 @@ show_detailed_help() {
     echo -e "  ${GREEN}cleanup-keys 192.168.178.30${RESET}"
     echo -e "    → Remove old SSH keys for this IP"
     echo ""
-    echo -e "${BOLD}${BLUE}MORE INFO:${RESET}"
+    echo -e "${BOLD}${BLUE}More info:${RESET}"
     echo -e "────────────────────────────────────────"
     echo -e "  GitHub: https://github.com/JBakers/homelab-tools"
     echo -e "  Each command: ${GREEN}<command> --help${RESET}"
@@ -100,19 +100,15 @@ show_detailed_help() {
 show_menu() {
     clear
     echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
-    echo -e "║         🏠 HOMELAB MANAGEMENT TOOLS v3.2.0            ║"
+    echo -e "║         🏠 Homelab Management Tools v3.3.0            ║"
     echo -e "║                  by J.Bakers                           ║"
     echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
     echo ""
-    echo -e "${BOLD}${BLUE}What would you like to do?${RESET}"
-    echo ""
-    echo -e "  ${YELLOW}1${RESET}) ${GREEN}MOTD Management${RESET}     - Create and deploy login screens"
-    echo -e "  ${YELLOW}2${RESET}) ${GREEN}Configuration${RESET}       - Edit hosts and settings"
-    echo -e "  ${YELLOW}3${RESET}) ${GREEN}SSH Tools${RESET}           - Manage keys and access"
-    echo ""
-    echo -e "  ${YELLOW}h${RESET}) ${MAGENTA}Help${RESET}                - Show detailed help"
-    echo -e "  ${YELLOW}q${RESET}) ${RED}Quit${RESET}                - Exit"
+    echo -e "  ${YELLOW}1${RESET}) ${GREEN}📝 MOTD Tools${RESET}        - Generate/deploy/list MOTDs"
+    echo -e "  ${YELLOW}2${RESET}) ${GREEN}⚙️  Configuration${RESET}     - Edit hosts & settings"
+    echo -e "  ${YELLOW}3${RESET}) ${GREEN}🔑 SSH Management${RESET}    - Keys & cleanup"
     echo ""
+    echo -e "  ${YELLOW}h${RESET}) ${MAGENTA}Help${RESET}    ${YELLOW}q${RESET}) ${RED}Quit${RESET}"
     echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
 }
 
@@ -120,7 +116,7 @@ show_menu() {
 show_motd_menu() {
     clear
     echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
-    echo -e "║         📋 MOTD MANAGEMENT                             ║"
+    echo -e "║         📝 MOTD Tools                                  ║"
     echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
     echo ""
     echo -e "  ${YELLOW}1${RESET}) ${GREEN}Generate MOTD${RESET}           - Create template for one host"
@@ -128,8 +124,7 @@ show_motd_menu() {
     echo -e "  ${YELLOW}3${RESET}) ${GREEN}Deploy MOTD${RESET}             - Upload to host"
     echo -e "  ${YELLOW}4${RESET}) ${GREEN}List Templates${RESET}          - View all templates"
     echo ""
-    echo -e "  ${YELLOW}b${RESET}) ${MAGENTA}Back${RESET}                    - Return to main menu"
-    echo ""
+    echo -e "  ${YELLOW}b${RESET}) ${MAGENTA}Back${RESET}"
     echo -e "${BOLD}${CYAN}════════════════════════════════════════════════════════════${RESET}"
 }
 
@@ -137,7 +132,7 @@ show_motd_menu() {
 show_config_menu() {
     clear
     echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
-    echo -e "║         ⚙️  CONFIGURATION                               ║"
+    echo -e "║         ⚙️  Configuration                               ║"
     echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
     echo ""
     echo -e "  ${YELLOW}1${RESET}) ${GREEN}Edit Hosts${RESET}              - Manage host list (~/.ssh/config)"
@@ -152,7 +147,7 @@ show_config_menu() {
 show_ssh_menu() {
     clear
     echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
-    echo -e "║         🔑 SSH TOOLS                                    ║"
+    echo -e "║         🔑 SSH Tools                                    ║"
     echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
     echo ""
     echo -e "  ${YELLOW}1${RESET}) ${GREEN}Copy SSH Key${RESET}            - Distribute key to hosts"
@@ -176,7 +171,8 @@ fi
 while true; do
     show_menu
     echo -ne "${BOLD}${GREEN}Choice:${RESET} "
-    read -r choice
+    read -n1 -s choice
+    echo ""  # Newline na input
     
     case $choice in
         1)
@@ -184,19 +180,24 @@ while true; do
             while true; do
                 show_motd_menu
                 echo -ne "${BOLD}${GREEN}Choice:${RESET} "
-                read -r submenu
+                read -n1 -s submenu
+                echo ""  # Newline na input
                 
                 case $submenu in
                     1)
                         echo ""
-                        read -p "$(echo -e ${CYAN}Service name:${RESET} )" service
-                        if [[ -n "$service" ]]; then
+                        read -p "$(echo -e ${CYAN}Service name \(or 'b' for back\):${RESET} )" service
+                        if [[ "$service" == "b" ]] || [[ "$service" == "B" ]]; then
+                            continue
+                        elif [[ -n "$service" ]]; then
                             generate-motd "$service"
+                            echo ""
+                            read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         else
                             echo -e "${RED}✗ No service name provided${RESET}"
+                            echo ""
+                            read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         fi
-                        echo ""
-                        read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         ;;
                     2)
                         echo ""
@@ -206,14 +207,18 @@ while true; do
                         ;;
                     3)
                         echo ""
-                        read -p "$(echo -e ${CYAN}Service name:${RESET} )" service
-                        if [[ -n "$service" ]]; then
+                        read -p "$(echo -e ${CYAN}Service name \(or 'b' for back\):${RESET} )" service
+                        if [[ "$service" == "b" ]] || [[ "$service" == "B" ]]; then
+                            continue
+                        elif [[ -n "$service" ]]; then
                             deploy-motd "$service"
+                            echo ""
+                            read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         else
                             echo -e "${RED}✗ No service name provided${RESET}"
+                            echo ""
+                            read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         fi
-                        echo ""
-                        read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         ;;
                     4)
                         echo ""
@@ -236,7 +241,8 @@ while true; do
             while true; do
                 show_config_menu
                 echo -ne "${BOLD}${GREEN}Choice:${RESET} "
-                read -r submenu
+                read -n1 -s submenu
+                echo ""  # Newline na input
                 
                 case $submenu in
                     1)
@@ -266,7 +272,8 @@ while true; do
             while true; do
                 show_ssh_menu
                 echo -ne "${BOLD}${GREEN}Choice:${RESET} "
-                read -r submenu
+                read -n1 -s submenu
+                echo ""  # Newline na input
                 
                 case $submenu in
                     1)
@@ -277,14 +284,18 @@ while true; do
                         ;;
                     2)
                         echo ""
-                        read -p "$(echo -e ${CYAN}IP address or hostname:${RESET} )" host
-                        if [[ -n "$host" ]]; then
+                        read -p "$(echo -e ${CYAN}IP address or hostname \(or 'b' for back\):${RESET} )" host
+                        if [[ "$host" == "b" ]] || [[ "$host" == "B" ]]; then
+                            continue
+                        elif [[ -n "$host" ]]; then
                             cleanup-keys "$host"
+                            echo ""
+                            read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         else
                             echo -e "${RED}✗ No host provided${RESET}"
+                            echo ""
+                            read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         fi
-                        echo ""
-                        read -p "$(echo -e ${YELLOW}Press Enter to continue...${RESET})"
                         ;;
                     b|B|back)
                         break
diff --git a/bin/list-templates b/bin/list-templates
index c16f531..15f5300 100755
--- a/bin/list-templates
+++ b/bin/list-templates
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # List all MOTD templates
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
diff --git a/install.sh b/install.sh
index 13dac30..1907910 100755
--- a/install.sh
+++ b/install.sh
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Installatie script voor Homelab Management Tools
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
@@ -25,80 +25,79 @@ if [[ ! -f "$(pwd)/bin/homelab" ]]; then
     exit 1
 fi
 
-INSTALL_DIR="$HOME/homelab-tools"
+INSTALL_DIR="/opt/homelab-tools"
 
 echo -e "${BOLD}Installatie directory: ${CYAN}$INSTALL_DIR${RESET}"
 echo ""
 
 # 1. Installeer bestanden naar /opt
-echo -e "${YELLOW}[1/5]${RESET} Installeer naar /opt..."
+echo -e "${YELLOW}[1/5]${RESET} Installeer naar /opt (vereist sudo)..."
 
 # Backup oude installatie
 if [[ -d "$INSTALL_DIR" ]]; then
     backup_dir="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
     echo -e "${YELLOW}  →${RESET} Backup oude installatie naar $backup_dir"
-    mv "$INSTALL_DIR" "$backup_dir"
+    sudo mv "$INSTALL_DIR" "$backup_dir"
 fi
 
-# Maak /opt directory en kopieer bestanden
+# Kopieer bestanden naar /opt (vereist sudo)
 echo -e "${YELLOW}  →${RESET} Kopieer bestanden naar $INSTALL_DIR..."
-mkdir -p "$INSTALL_DIR"
-cp -r "$(pwd)"/* "$INSTALL_DIR/"
-cp -r "$(pwd)"/.gitignore "$INSTALL_DIR/" 2>/dev/null || true
+sudo mkdir -p "$INSTALL_DIR"
+sudo cp -r "$(pwd)"/* "$INSTALL_DIR/"
+sudo cp -r "$(pwd)"/.gitignore "$INSTALL_DIR/" 2>/dev/null || true
 echo -e "${GREEN}  ✓${RESET} Bestanden geïnstalleerd in /opt"
 echo ""
 
 # 2. Maak alle scripts executable
 echo -e "${YELLOW}[2/5]${RESET} Configureer permissions..."
-chmod +x "$INSTALL_DIR"/bin/* 2>/dev/null
-chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null
+sudo chmod +x "$INSTALL_DIR"/bin/* 2>/dev/null
+sudo chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null
 echo -e "${GREEN}  ✓${RESET} Scripts zijn executable"
 echo ""
 
-# 3. Voeg toe aan system-wide PATH
-echo -e "${YELLOW}[3/5]${RESET} Configureer system PATH..."
+# 3. Configureer PATH
+echo -e "${YELLOW}[3/5]${RESET} Configureer PATH..."
 
-# Creëer symlinks in /usr/local/bin (standaard in PATH)
-echo -e "${YELLOW}  →${RESET} Maak symlinks in /usr/local/bin..."
+# Maak ~/.local/bin directory
+BIN_DIR="$HOME/.local/bin"
+mkdir -p "$BIN_DIR"
+
+# Creëer symlinks in ~/.local/bin (geen sudo nodig)
+echo -e "${YELLOW}  →${RESET} Maak symlinks in ~/.local/bin..."
 for cmd in "$INSTALL_DIR"/bin/*; do
     cmd_name=$(basename "$cmd")
-    ln -sf "$INSTALL_DIR/bin/$cmd_name" "/usr/local/bin/$cmd_name"
+    ln -sf "$INSTALL_DIR/bin/$cmd_name" "$BIN_DIR/$cmd_name"
 done
-echo -e "${GREEN}  ✓${RESET} Commando's beschikbaar system-wide"
+echo -e "${GREEN}  ✓${RESET} Commando's beschikbaar in ~/.local/bin"
 echo ""
 
-# Optional: ook toevoegen aan bashrc voor expliciete PATH
-echo -e "${YELLOW}[3.5/5]${RESET} Configureer user PATH (optioneel)..."
-
-# Voeg toe aan bashrc van huidige user (optioneel, want /usr/local/bin is al in PATH)
-CURRENT_USER=${SUDO_USER:-$USER}
-USER_HOME=$(eval echo ~$CURRENT_USER)
+# Voeg ~/.local/bin toe aan PATH in bashrc
+echo -e "${YELLOW}  →${RESET} Configureer PATH in ~/.bashrc..."
 
-if [[ -f "$USER_HOME/.bashrc" ]]; then
-    if grep -q "/opt/homelab-tools/bin" "$USER_HOME/.bashrc" 2>/dev/null; then
-        echo -e "${GREEN}  ✓${RESET} PATH al in ~/.bashrc"
+if [[ -f "$HOME/.bashrc" ]]; then
+    # Check of ~/.local/bin al in PATH staat
+    if grep -q 'PATH.*\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
+        echo -e "${GREEN}  ✓${RESET} ~/.local/bin al in PATH"
     else
-        echo "" >> "$USER_HOME/.bashrc"
-        echo "# Homelab Management Tools" >> "$USER_HOME/.bashrc"
-        echo "export PATH=\"/opt/homelab-tools/bin:\$PATH\"" >> "$USER_HOME/.bashrc"
-        chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.bashrc"
+        echo "" >> "$HOME/.bashrc"
+        echo "# Homelab Management Tools" >> "$HOME/.bashrc"
+        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
         echo -e "${GREEN}  ✓${RESET} PATH toegevoegd aan ~/.bashrc"
     fi
 else
-    echo -e "${YELLOW}  →${RESET} Geen .bashrc gevonden, skip"
+    echo -e "${YELLOW}  ⚠${RESET} Geen .bashrc gevonden, maak nieuwe aan"
+    echo '# Homelab Management Tools' > "$HOME/.bashrc"
+    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
+    echo -e "${GREEN}  ✓${RESET} .bashrc aangemaakt met PATH"
 fi
 echo ""
 
 # 4. Maak templates directory
 echo -e "${YELLOW}[4/5]${RESET} Initialiseer templates..."
 
-# Templates in user home directory (niet in /opt)
-CURRENT_USER=${SUDO_USER:-$USER}
-USER_HOME=$(eval echo ~$CURRENT_USER)
-
-mkdir -p "$USER_HOME/.local/share/homelab-tools/templates"
-chown -R "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.local/share/homelab-tools"
-echo -e "${GREEN}  ✓${RESET} Templates directory: $USER_HOME/.local/share/homelab-tools/templates"
+# Templates in user home directory
+mkdir -p "$HOME/.local/share/homelab-tools/templates"
+echo -e "${GREEN}  ✓${RESET} Templates directory: $HOME/.local/share/homelab-tools/templates"
 echo ""
 
 # 5. Configuratie
@@ -136,7 +135,7 @@ if [[ ! -f "$CONFIG_FILE" ]]; then
 # Homelab Tools Installer
 # Installs to /opt/homelab-tools with system-wide access
 # Author: J.Bakers
-# Version: 3.1.0
+# Version: 3.4.0
 
 # Domain suffix voor je homelab
 # Wordt gebruikt voor Web UI URLs
@@ -266,8 +265,8 @@ echo -e "${BOLD}${YELLOW}Volgende stappen:${RESET}"
 echo ""
 echo -e "${BOLD}Installatie locaties:${RESET}"
 echo -e "  • Programma:  ${CYAN}/opt/homelab-tools/${RESET}"
-echo -e "  • Commando's: ${CYAN}/usr/local/bin/${RESET}"
-echo -e "  • Templates:  ${CYAN}$USER_HOME/.local/share/homelab-tools/templates/${RESET}"
+echo -e "  • Commando's: ${CYAN}~/.local/bin/${RESET}"
+echo -e "  • Templates:  ${CYAN}~/.local/share/homelab-tools/templates/${RESET}"
 echo -e "  • Config:     ${CYAN}/opt/homelab-tools/config.sh${RESET}"
 echo ""
 echo -e "${BOLD}${YELLOW}Volgende stappen:${RESET}"
diff --git a/migrate-to-opt.sh b/migrate-to-opt.sh
index 1aebc0f..9d65297 100755
--- a/migrate-to-opt.sh
+++ b/migrate-to-opt.sh
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Migrate homelab-tools from ~/homelab-tools to /opt/homelab-tools
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
diff --git a/uninstall.sh b/uninstall.sh
index 19947cc..77e7347 100755
--- a/uninstall.sh
+++ b/uninstall.sh
@@ -3,7 +3,7 @@ set -euo pipefail
 
 # Homelab Tools Uninstaller
 # Author: J.Bakers
-# Version: 3.2.0
+# Version: 3.4.0
 
 # Kleuren
 CYAN='\033[0;36m'
@@ -41,7 +41,7 @@ echo -e "${YELLOW}⚠  WARNING:${RESET} This will remove Homelab Tools from your
 echo ""
 echo -e "${BOLD}What will be removed:${RESET}"
 echo -e "  • All scripts from ~/.local/bin/"
-echo -e "  • ~/homelab-tools/ directory"
+echo -e "  • /opt/homelab-tools/ directory"
 echo -e "  • PATH entry from ~/.bashrc"
 echo ""
 echo -e "${BOLD}${GREEN}What will be KEPT (your data is safe):${RESET}"
@@ -60,9 +60,10 @@ if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
 fi
 
 echo ""
-echo -e "${YELLOW}[1/4]${RESET} Verwijder symlinks uit /usr/local/bin/..."
+echo -e "${YELLOW}[1/4]${RESET} Verwijder symlinks uit ~/.local/bin/..."
 
-# Remove symlinks
+# Remove symlinks from ~/.local/bin
+BIN_DIR="$HOME/.local/bin"
 scripts=(
     "homelab"
     "generate-motd"
@@ -78,8 +79,8 @@ scripts=(
 
 removed=0
 for script in "${scripts[@]}"; do
-    if [[ -L "/usr/local/bin/$script" ]]; then
-        rm "/usr/local/bin/$script"
+    if [[ -L "$BIN_DIR/$script" ]] || [[ -f "$BIN_DIR/$script" ]]; then
+        rm -f "$BIN_DIR/$script"
         removed=$((removed + 1))
     fi
 done
@@ -88,23 +89,21 @@ echo -e "${GREEN}  ✓${RESET} Verwijderd $removed symlink(s)"
 echo ""
 
 # Backup templates
-CURRENT_USER=${SUDO_USER:-$USER}
-USER_HOME=$(eval echo ~$CURRENT_USER)
+TEMPLATES_DIR="$HOME/.local/share/homelab-tools/templates"
 
 echo -e "${YELLOW}[2/4]${RESET} Check MOTD templates..."
-if [[ -d "$USER_HOME/.local/share/homelab-tools/templates" ]]; then
-    template_count=$(find "$USER_HOME/.local/share/homelab-tools/templates" -name "*.sh" 2>/dev/null | wc -l)
-    
+if [[ -d "$TEMPLATES_DIR" ]]; then
+    template_count=$(find "$TEMPLATES_DIR" -name "*.sh" 2>/dev/null | wc -l)
+
     if [[ $template_count -gt 0 ]]; then
-        backup_dir="$USER_HOME/homelab-tools-backup-$(date +%Y%m%d_%H%M%S)"
+        backup_dir="$HOME/homelab-tools-backup-$(date +%Y%m%d_%H%M%S)"
         echo -e "${YELLOW}  →${RESET} Gevonden $template_count template(s)"
         read -p "  Backup maken? (Y/n): " backup
         backup=${backup:-y}
-        
+
         if [[ "$backup" =~ ^[Yy]$ ]]; then
             mkdir -p "$backup_dir"
-            cp -r "$USER_HOME/.local/share/homelab-tools/templates" "$backup_dir/"
-            chown -R "$CURRENT_USER:$CURRENT_USER" "$backup_dir"
+            cp -r "$TEMPLATES_DIR" "$backup_dir/"
             echo -e "${GREEN}  ✓${RESET} Backup: ${CYAN}$backup_dir${RESET}"
         else
             echo -e "${YELLOW}  →${RESET} Skip backup"
@@ -117,10 +116,11 @@ else
 fi
 echo ""
 
-# Remove /opt directory
-echo -e "${YELLOW}[3/4]${RESET} Verwijder /opt/homelab-tools/..."
+# Remove /opt/homelab-tools directory
+INSTALL_DIR="/opt/homelab-tools"
+echo -e "${YELLOW}[3/4]${RESET} Verwijder /opt/homelab-tools/ (vereist sudo)..."
 if [[ -d "$INSTALL_DIR" ]]; then
-    rm -rf "$INSTALL_DIR"
+    sudo rm -rf "$INSTALL_DIR"
     echo -e "${GREEN}  ✓${RESET} Directory verwijderd"
 else
     echo -e "${YELLOW}  →${RESET} Directory niet gevonden"
@@ -129,15 +129,15 @@ echo ""
 
 # Remove from bashrc
 echo -e "${YELLOW}[4/4]${RESET} Cleanup ~/.bashrc..."
-if [[ -f "$USER_HOME/.bashrc" ]] && grep -q "/opt/homelab-tools" "$USER_HOME/.bashrc" 2>/dev/null; then
+if [[ -f "$HOME/.bashrc" ]] && grep -q "Homelab Management Tools" "$HOME/.bashrc" 2>/dev/null; then
     # Create backup
-    cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
-    
-    # Remove homelab-tools lines
-    sed -i '/# Homelab Management Tools/d' "$USER_HOME/.bashrc"
-    sed -i '\|/opt/homelab-tools|d' "$USER_HOME/.bashrc"
-    
-    chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.bashrc"*
+    cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
+
+    # Remove homelab-tools lines (works for both old /opt and new ~/.local/bin)
+    sed -i '/# Homelab Management Tools/d' "$HOME/.bashrc"
+    sed -i '\|/opt/homelab-tools|d' "$HOME/.bashrc"
+    sed -i '\|\.local/bin.*homelab|d' "$HOME/.bashrc"
+
     echo -e "${GREEN}  ✓${RESET} PATH entry verwijderd"
     echo -e "${YELLOW}  →${RESET} Backup: ${CYAN}~/.bashrc.backup.*${RESET}"
 else
@@ -155,10 +155,10 @@ echo ""
 echo -e "${BOLD}${GREEN}Je data is veilig:${RESET}"
 echo -e "  • SSH keys:       ${CYAN}~/.ssh/${RESET}"
 echo -e "  • SSH config:     ${CYAN}~/.ssh/config${RESET}"
-echo -e "  • Templates:      ${CYAN}$USER_HOME/.local/share/homelab-tools/${RESET}"
+echo -e "  • Templates:      ${CYAN}$HOME/.local/share/homelab-tools/${RESET}"
 echo -e "  • Remote MOTDs:   ${CYAN}Nog steeds deployed${RESET}"
 
-if [[ -n "${backup_dir:-}" ]] && [[ -d "$backup_dir" ]]; then
+if [[ -n "${backup_dir:-}" ]] && [[ -d "${backup_dir}" ]]; then
     echo -e "  • Backup:         ${CYAN}$backup_dir${RESET}"
 fi
 
