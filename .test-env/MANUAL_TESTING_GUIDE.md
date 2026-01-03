# 🧪 Manual Testing Guide - Homelab Tools
## Complete 100% Test Checklist

**Version:** 3.6.0-dev.21  
**Date:** 2025-12-31  
**Purpose:** Volledige handmatige verificatie van alle functionaliteit

---

## 📋 PRE-TEST SETUP

### 1. Clean Environment Preparation

```bash
# Ga naar workspace directory
cd ~/Workspace/homelab-tools

# Check huidige status
ls /opt/homelab-tools 2>/dev/null && echo "⚠️ Oude installatie aanwezig" || echo "✓ Clean"

# Als oude installatie bestaat - uninstall
if [[ -d /opt/homelab-tools ]]; then
    cd ~
    expect -c '
        spawn /opt/homelab-tools/uninstall.sh
        expect {
            "Uninstall" { send "y\r"; exp_continue }
            "Keep" { send "n\r"; exp_continue }
            "delete" { send "y\r"; exp_continue }
            "Remove" { send "y\r"; exp_continue }
            eof { }
        }
    '
fi

# Verifieer clean state
ls /opt/homelab-tools 2>/dev/null && echo "❌ FAIL - Niet verwijderd" || echo "✓ Clean uninstall"
```

---

## 🔧 SECTION 1: INSTALLATION TESTS

### Test 1.1: Fresh Install (Interactive)

```bash
cd ~/Workspace/homelab-tools
./install.sh
```

**Verwachte prompts:**
1. "Update/Clean install/Remove" → Kies: **1** (Update)
2. "What is your homelab domain suffix?" → Bijv: **.home**
3. "Configure SSH keys now?" → Kies: **n** (voor nu)

**Validatie:**
```bash
# Check installatie
ls -la /opt/homelab-tools/
echo "Expected: bin/, lib/, config/, VERSION, install.sh, uninstall.sh"

# Check symlinks
ls -la ~/.local/bin/homelab
ls -la ~/.local/bin/generate-motd
ls -la ~/.local/bin/deploy-motd
echo "Expected: Alle symlinks naar /opt/homelab-tools/bin/*"

# Check version
cat /opt/homelab-tools/VERSION
echo "Expected: 3.6.0-dev.21"

# Reload shell
source ~/.bashrc

# Check PATH
which homelab
echo "Expected: ~/.local/bin/homelab"
```

**✅ PASS criteria:**
- [ ] /opt/homelab-tools/ bestaat met alle files
- [ ] 12 symlinks in ~/.local/bin/
- [ ] VERSION file correct
- [ ] homelab in PATH

---

### Test 1.2: Version & Help Output

```bash
# Test 1: homelab --help (should show colors correctly, no \033 codes)
homelab --help
echo "Expected: Colored header, no raw escape codes"

# Test 2: homelab --usage
homelab --usage
echo "Expected: Concise list of commands"

# Test 3: homelab help (detailed)
homelab help
echo "Expected: Detailed help with examples"

# Test 4: Individual command help
generate-motd --help
deploy-motd --help
list-templates --help
echo "Expected: Command-specific help for each"
```

**✅ PASS criteria:**
- [ ] Geen raw escape codes (geen `\033[` zichtbaar)
- [ ] Kleuren tonen correct
- [ ] Alle commands hebben --help
- [ ] Help text is leesbaar en informatief

---

## 📝 SECTION 2: MOTD GENERATION TESTS

### Test 2.1: Generate MOTD (Interactive)

```bash
# Generate template voor "test" service
generate-motd test

# Verwachte prompts:
# 1. "Customize?" → n
# 2. "Choose style [1-6]" → 1 (Clean & Functional)

# Expected output:
# ✓ Template successfully created!
# Location: ~/.local/share/homelab-tools/templates/test.sh
```

**Validatie:**
```bash
# Check template file
ls -la ~/.local/share/homelab-tools/templates/test.sh
cat ~/.local/share/homelab-tools/templates/test.sh | head -20

# Test preview
bash ~/.local/share/homelab-tools/templates/test.sh
echo "Expected: MOTD output met service info"
```

**✅ PASS criteria:**
- [ ] Template bestand bestaat
- [ ] Bestand is executable
- [ ] Template script draait zonder errors
- [ ] Output toont service info (hostname, IP, etc)

---

### Test 2.2: Generate with Different Styles

Test alle ASCII art styles:

```bash
# Style 2: Rainbow Future
generate-motd rainbow-test
# Bij "Choose style": Kies 2

# Style 3: Rainbow Standard  
generate-motd classic-test
# Bij "Choose style": Kies 3

# Style 4: Mono Future
generate-motd mono-test
# Bij "Choose style": Kies 4

# Preview alle templates
list-templates --preview
```

**✅ PASS criteria:**
- [ ] Alle styles genereren zonder error
- [ ] Preview toont verschillende ASCII art
- [ ] Kleuren verschillen per style

---

### Test 2.3: Generate with Auto-detection

Test service auto-detection:

```bash
# Docker service (should auto-detect)
generate-motd docker
echo "Expected: Auto-detected: Docker - Container Platform"

# Pi-hole service
generate-motd pihole
echo "Expected: Auto-detected: Pi-hole - Network-wide Ad Blocking"

# Proxmox service
generate-motd proxmox
echo "Expected: Auto-detected: Proxmox - Virtualization Platform"

# Portainer service
generate-motd portainer
echo "Expected: Auto-detected: Portainer - Docker Management"
```

**✅ PASS criteria:**
- [ ] Services worden auto-detected
- [ ] Web UI URL's worden correct ingevuld
- [ ] Service descriptions kloppen

---

## 📋 SECTION 3: TEMPLATE MANAGEMENT TESTS

### Test 3.1: List Templates

```bash
# Basic list
list-templates
echo "Expected: Tabel met alle gegenereerde templates"

# With status
list-templates --status
echo "Expected: Deployment status per template"

# With preview
list-templates --preview
echo "Expected: Preview van elke template"
```

**✅ PASS criteria:**
- [ ] Alle templates worden getoond
- [ ] Status kolom toont "Not deployed" / "Deployed"
- [ ] Preview toont eerste regels van MOTD

---

### Test 3.2: Delete Templates

```bash
# Delete interactive (via menu)
delete-template

# Expected: Interactive menu toont alle templates
# Selecteer één template en delete
# Bevestig met 'y'

# Verify deletion
list-templates
echo "Expected: Template niet meer in lijst"
```

**✅ PASS criteria:**
- [ ] Delete menu toont alle templates
- [ ] Confirmatie vraag verschijnt
- [ ] Template wordt verwijderd na bevestiging
- [ ] Template blijft bestaan bij 'n'

---

## 🚀 SECTION 4: DEPLOYMENT TESTS (SSH Required)

**⚠️ Vereist:** Werkende SSH configuratie naar test hosts

### Test 4.1: Deploy MOTD to Host

```bash
# Check SSH config first
cat ~/.ssh/config | grep "Host "

# Deploy naar een host (bijv. pihole)
deploy-motd pihole

# Expected prompts:
# → Test SSH connection...
# ✓ Connected to pihole
# → Deploying MOTD...
# ✓ MOTD deployed successfully

# Verify deployment
ssh pihole
# Expected: Bij login zie je de nieuwe MOTD
# Exit met: exit
```

**Validatie:**
```bash
# Check deployment status
list-templates --status
echo "Expected: pihole template toont 'Deployed'"

# SSH en check MOTD files
ssh pihole "ls -la /etc/update-motd.d/"
# Expected: 10-hostname, 20-uname scripts aanwezig
```

**✅ PASS criteria:**
- [ ] Deploy succeeds zonder errors
- [ ] SSH login toont nieuwe MOTD
- [ ] Status toont "Deployed"
- [ ] MOTD scripts aanwezig op host

---

### Test 4.2: Undeploy MOTD

```bash
# Undeploy van host
undeploy-motd pihole

# Expected output:
# → Removing MOTD from pihole...
# ✓ MOTD removed

# Verify
ssh pihole
# Expected: Terug naar oude/default MOTD

# Check status
list-templates --status
echo "Expected: pihole template toont 'Not deployed'"
```

**✅ PASS criteria:**
- [ ] Undeploy succeeds
- [ ] MOTD scripts verwijderd van host
- [ ] Status update naar "Not deployed"

---

### Test 4.3: Bulk Generate MOTDs

```bash
# Generate voor alle hosts in SSH config
bulk-generate-motd

# Expected: Scant ~/.ssh/config
# Genereert templates voor elke host
# Toont progress per host

# Verify
list-templates
echo "Expected: Templates voor alle SSH hosts"
```

**✅ PASS criteria:**
- [ ] Scant SSH config correct
- [ ] Template per host gegenereerd
- [ ] Geen duplicates
- [ ] Progress wordt getoond

---

## ⚙️ SECTION 5: CONFIGURATION TESTS

### Test 5.1: Edit Hosts (SSH Config)

```bash
# Open edit-hosts menu
edit-hosts

# Test menu navigatie:
# 1. Main menu toont aantal configured hosts
# 2. Navigeer met pijltjestoetsen
# 3. Test 'Add new host' optie
# 4. Test 'Edit existing host' optie
# 5. Test 'View all hosts' optie
# 6. Quit met 'q'
```

**✅ PASS criteria:**
- [ ] Menu laadt zonder errors
- [ ] Configured hosts count klopt
- [ ] Navigatie werkt smooth
- [ ] Add/Edit opties werken
- [ ] Q quit werkt direct

---

### Test 5.2: Edit Config

```bash
# Open config editor
edit-config

# Expected: Opens /opt/homelab-tools/config.sh in $EDITOR
# 
# Check settings:
# - HLT_DOMAIN_SUFFIX=".home"
# - Template directory path
# - SSH config path
```

**✅ PASS criteria:**
- [ ] Config file opent in editor
- [ ] Alle settings zichtbaar en editeerbaar
- [ ] Domain suffix klopt
- [ ] Paths zijn correct

---

## 🔑 SECTION 6: SSH MANAGEMENT TESTS

### Test 6.1: Copykey (Distribute SSH Keys)

```bash
# Distribute SSH key to hosts
copykey

# Expected prompts:
# → Select hosts to distribute key to
# → Shows all hosts from SSH config
# → Confirms before distribution

# Test met één host
# Expected: ssh-copy-id naar host
```

**✅ PASS criteria:**
- [ ] Host selection menu werkt
- [ ] Key distribution succeeds
- [ ] Can SSH without password na copykey

---

### Test 6.2: Cleanup Keys

```bash
# Remove old SSH keys for specific host/IP
cleanup-keys 192.168.178.30

# Expected output:
# → Scanning ~/.ssh/known_hosts...
# → Found X entries for 192.168.178.30
# → Removed X entries
```

**✅ PASS criteria:**
- [ ] Keys worden gevonden
- [ ] Keys worden verwijderd
- [ ] known_hosts blijft valid

---

## 🎯 SECTION 7: MAIN MENU TESTS

### Test 7.1: Homelab Menu Navigation

```bash
# Start main menu
homelab

# Test alle menu items:
# 1. Press '1' → MOTD Tools submenu
# 2. Press '2' → Configuration submenu  
# 3. Press '3' → SSH Management submenu
# 4. Press 'h' → Help
# 5. Press 'q' → Quit

# Test MOTD submenu:
homelab
# Press 1 → MOTD Tools
# Test: generate, deploy, list, delete opties
```

**✅ PASS criteria:**
- [ ] Main menu laadt mooi
- [ ] Alle menu items bereikbaar
- [ ] Submenus laden correct
- [ ] Navigation smooth (arrows/numbers)
- [ ] Quit werkt overal met 'q'

---

## 🚨 SECTION 8: ERROR HANDLING TESTS

### Test 8.1: Invalid Input Handling

```bash
# Test 1: Invalid service name in generate-motd
generate-motd '; rm -rf /'
# Expected: Error message, geen command execution

# Test 2: Deploy naar non-existent host
deploy-motd nonexistent-host-12345
# Expected: "Cannot connect" error

# Test 3: Invalid template in delete
# Run: delete-template
# Try to delete non-existent template
# Expected: Error or "Template not found"
```

**✅ PASS criteria:**
- [ ] Geen command injection mogelijk
- [ ] Clear error messages
- [ ] Scripts blijven stable na error
- [ ] Geen crash/hang

---

### Test 8.2: Edge Cases

```bash
# Test 1: Generate MOTD met lege service naam
generate-motd ""
# Expected: Error "Service name required"

# Test 2: Deploy zonder template
deploy-motd test-nonexistent
# Expected: "Template not found"

# Test 3: Undeploy van non-deployed host
undeploy-motd test
# Expected: "Not deployed" of success

# Test 4: List templates in empty directory
rm -rf ~/.local/share/homelab-tools/templates/*
list-templates
# Expected: "No templates found" message
```

**✅ PASS criteria:**
- [ ] Alle edge cases handled gracefully
- [ ] Geen crashes
- [ ] Helpful error messages
- [ ] Scripts recover na errors

---

## 🗑️ SECTION 9: UNINSTALL TESTS

### Test 9.1: Uninstall Cancel

```bash
cd ~
/opt/homelab-tools/uninstall.sh

# Bij prompt "Uninstall?" → Kies: n

# Verify everything still intact
ls /opt/homelab-tools/
which homelab
```

**✅ PASS criteria:**
- [ ] Cancel werkt correct
- [ ] Installation blijft intact
- [ ] Geen files verwijderd

---

### Test 9.2: Partial Uninstall (Keep Templates)

```bash
cd ~
/opt/homelab-tools/uninstall.sh

# Bij prompt "Uninstall?" → Kies: y
# Bij "Keep templates?" → Kies: y

# Verify
ls /opt/homelab-tools/ 2>/dev/null && echo "❌ Not removed" || echo "✓ Removed"
ls ~/.local/share/homelab-tools/templates/
echo "Expected: Templates still exist"
```

**✅ PASS criteria:**
- [ ] /opt/homelab-tools/ removed
- [ ] Symlinks removed
- [ ] Templates kept
- [ ] Bashrc cleaned

---

### Test 9.3: Complete Uninstall

```bash
# Fresh install eerst
cd ~/Workspace/homelab-tools
./install.sh --non-interactive

# Generate test template
generate-motd test-final <<EOF
n
1
EOF

# Complete uninstall
cd ~
expect -c '
    spawn /opt/homelab-tools/uninstall.sh
    expect {
        "Uninstall" { send "y\r"; exp_continue }
        "Keep" { send "n\r"; exp_continue }
        "delete" { send "y\r"; exp_continue }
        "Remove" { send "y\r"; exp_continue }
        eof { }
    }
'

# Verify EVERYTHING removed
ls /opt/homelab-tools/ 2>/dev/null && echo "❌ FAIL" || echo "✓ Removed"
ls ~/.local/bin/homelab 2>/dev/null && echo "❌ FAIL" || echo "✓ Symlinks removed"
ls ~/.local/share/homelab-tools/templates/ 2>/dev/null && echo "❌ FAIL" || echo "✓ Templates removed"
grep "homelab" ~/.bashrc && echo "❌ FAIL" || echo "✓ Bashrc cleaned"
```

**✅ PASS criteria:**
- [ ] /opt/homelab-tools/ verwijderd
- [ ] Alle symlinks verwijderd
- [ ] Templates verwijderd
- [ ] Bashrc entries verwijderd
- [ ] Backup gemaakt

---

## 🎨 SECTION 10: VISUAL/UX TESTS

### Test 10.1: Colors & Formatting

Open homelab menu en check:

```bash
homelab
```

**Visual checklist:**
- [ ] Header box tekent correct (╔══╗ characters)
- [ ] Kleuren tonen goed (cyan, green, yellow)
- [ ] Emoji's tonen correct (🏠 📝 ⚙️ 🔑)
- [ ] Alignment is netjes
- [ ] Geen overlapping/glitches
- [ ] Readable in dark/light theme

---

### Test 10.2: Interactive Response

Test responsiveness:

```bash
# Start menu
homelab

# Test:
# - Pijltjestoetsen navigatie
# - Enter selecteert
# - 'q' quit direct
# - Nummers werken als shortcut
# - Geen lag/delay
```

**✅ PASS criteria:**
- [ ] Smooth navigation
- [ ] Direct response op input
- [ ] Geen flickering
- [ ] Menu blijft stable

---

## 📊 FINAL VALIDATION CHECKLIST

### Complete Feature Matrix

| Feature | Tested | Working | Notes |
|---------|--------|---------|-------|
| **Installation** |  |  |  |
| Fresh install | ☐ | ☐ |  |
| Update install | ☐ | ☐ |  |
| Non-interactive | ☐ | ☐ |  |
| **MOTD Generation** |  |  |  |
| Basic generate | ☐ | ☐ |  |
| All 6 styles | ☐ | ☐ |  |
| Auto-detection | ☐ | ☐ |  |
| Custom settings | ☐ | ☐ |  |
| **Template Management** |  |  |  |
| List templates | ☐ | ☐ |  |
| List --status | ☐ | ☐ |  |
| List --preview | ☐ | ☐ |  |
| Delete template | ☐ | ☐ |  |
| **Deployment** |  |  |  |
| Deploy MOTD | ☐ | ☐ |  |
| Undeploy MOTD | ☐ | ☐ |  |
| Bulk generate | ☐ | ☐ |  |
| **Configuration** |  |  |  |
| Edit hosts | ☐ | ☐ |  |
| Edit config | ☐ | ☐ |  |
| **SSH Tools** |  |  |  |
| Copykey | ☐ | ☐ |  |
| Cleanup keys | ☐ | ☐ |  |
| **Menus** |  |  |  |
| Main menu | ☐ | ☐ |  |
| MOTD submenu | ☐ | ☐ |  |
| Config submenu | ☐ | ☐ |  |
| SSH submenu | ☐ | ☐ |  |
| **Help & Docs** |  |  |  |
| homelab --help | ☐ | ☐ |  |
| homelab help | ☐ | ☐ |  |
| homelab --usage | ☐ | ☐ |  |
| Command --help | ☐ | ☐ |  |
| **Error Handling** |  |  |  |
| Invalid input | ☐ | ☐ |  |
| Non-existent host | ☐ | ☐ |  |
| Missing template | ☐ | ☐ |  |
| SSH failures | ☐ | ☐ |  |
| **Uninstall** |  |  |  |
| Cancel uninstall | ☐ | ☐ |  |
| Partial uninstall | ☐ | ☐ |  |
| Complete uninstall | ☐ | ☐ |  |

---

## 🚀 QUICK TEST SCRIPT

Voor snelle verificatie:

```bash
#!/bin/bash
# Quick smoke test - test alle main flows

echo "=== QUICK SMOKE TEST ==="

# 1. Installation check
echo "1. Checking installation..."
[[ -d /opt/homelab-tools ]] && echo "✓ Installed" || echo "❌ Not installed"

# 2. Commands in PATH
echo "2. Checking commands..."
which homelab && echo "✓ homelab" || echo "❌ homelab"
which generate-motd && echo "✓ generate-motd" || echo "❌ generate-motd"

# 3. Help output
echo "3. Testing help output..."
homelab --help | grep -q "Homelab Management" && echo "✓ Help works" || echo "❌ Help broken"

# 4. Generate template
echo "4. Testing generate-motd..."
echo -e "n\n1\n" | generate-motd quicktest > /dev/null 2>&1
[[ -f ~/.local/share/homelab-tools/templates/quicktest.sh ]] && echo "✓ Generate works" || echo "❌ Generate failed"

# 5. List templates
echo "5. Testing list-templates..."
list-templates | grep -q "quicktest" && echo "✓ List works" || echo "❌ List failed"

# 6. Menu loads
echo "6. Testing menu..."
echo "q" | timeout 3 homelab > /dev/null 2>&1 && echo "✓ Menu works" || echo "❌ Menu failed"

echo ""
echo "=== SMOKE TEST COMPLETE ==="
```

---

## 📝 TEST REPORT TEMPLATE

Kopieer dit na het testen:

```markdown
# Test Report - Homelab Tools

**Datum:** 2025-12-31
**Versie:** 3.6.0-dev.21
**Tester:** jochem
**Environment:** Debian 13

## Test Results

### Summary
- Total Tests: X
- Passed: X
- Failed: X
- Skipped: X

### Failed Tests
1. [Test naam]
   - Error: [beschrijving]
   - Steps to reproduce: [stappen]
   
### Known Issues
- [Issue 1]
- [Issue 2]

### Notes
[Aanvullende opmerkingen]

### Conclusion
☐ Ready for production
☐ Needs fixes
☐ Blocker issues

**Sign-off:** ____________
```

---

## 🎯 SUCCESS CRITERIA

Project is **release ready** als:

- [ ] **100% van core features werken** (install, generate, deploy, list, uninstall)
- [ ] **Alle menus navigable** zonder crashes
- [ ] **Help output correct** (geen escape codes)
- [ ] **Error handling graceful** (geen crashes bij invalid input)
- [ ] **Clean install/uninstall** werkt foutloos
- [ ] **SSH deployment** werkt op test hosts
- [ ] **No security issues** (input validation, command injection)

---

**Klaar om te testen!** 🚀

Start met Section 1 (Installation) en werk alle secties af.
Bij problemen: noteer in test report en ga door.
