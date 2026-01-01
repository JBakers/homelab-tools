# Testing Checklist - v3.6.0-dev.20

**Updated:** 2025-12-14  
**Version:** 3.6.0-dev.20  
**Status:** Ready for comprehensive testing

---

## Quick Test Summary

| Component | Status | Priority | Notes |
|-----------|--------|----------|-------|
| edit-hosts menus | ✅ Fixed | HIGH | All 3 title args added - test interactive flow |
| list-templates --view | ✅ Fixed | HIGH | choose_menu → show_arrow_menu - test preview |
| delete-template help | ✅ Fixed | HIGH | Heredoc → echo -e colors |
| deploy-motd | ✅ Works | MEDIUM | SSH error handling tested |
| undeploy-motd | ✅ Works | MEDIUM | Single + --all modes tested |
| generate-motd stdin | ✅ Works | MEDIUM | Non-interactive mode works |
| All scripts | ✅ Pass | MEDIUM | bash -n syntax validation passed |

---

## 🎯 Critical Tests (MUST PASS)

### 1. Edit-Hosts Menu System
**Why:** 3 missing title arguments were fixed - verify menu works end-to-end

- [ ] **1.1** - Open edit-hosts (no args) → shows main menu
  - Command: `edit-hosts`
  - Expected: Menu with "Add new host" / "Manage existing" / etc.
  - Verify: Can navigate with arrows, select with Enter

- [ ] **1.2** - Select "Manage existing host" → shows host list
  - Expected: List of configured hosts from ~/.ssh/config
  - Verify: Menu title shows "📋 Select Host"
  - Note: Fixed on line 796

- [ ] **1.3** - Select host → shows options
  - Expected: Menu with "View / Edit / Delete / Copy / Back"
  - Verify: Menu title shows "📋 Host Options"
  - Note: Fixed on line 555

- [ ] **1.4** - Select "Bulk operations" → submenu
  - Expected: Menu with export/backup/batch delete options
  - Verify: Menu title shows "📦 Bulk Operations"
  - Note: Fixed on line 717

- [ ] **1.5** - Exit from all menus with q=quit
  - Expected: Returns cleanly to shell prompt
  - Verify: No hanging, no errors

---

### 2. List-Templates --view Mode
**Why:** Was using non-existent choose_menu function

- [ ] **2.1** - Open list-templates --view
  - Command: `list-templates --view`
  - Expected: Shows menu to select template
  - Note: Fixed line 197, changed choose_menu → show_arrow_menu

- [ ] **2.2** - Arrow navigate templates
  - Expected: Highlight moves with ↑/↓
  - Verify: Smooth navigation

- [ ] **2.3** - Preview template content
  - Expected: Shows MOTD script content
  - Verify: Readable, no garbled text

- [ ] **2.4** - Exit with q or Escape
  - Expected: Returns cleanly
  - Verify: No crashes

---

### 3. Delete-Template Help
**Why:** Heredoc wasn't interpreting escape codes

- [ ] **3.1** - Show help
  - Command: `delete-template --help`
  - Expected: Colored box with blue/yellow text
  - Fixed: Line 18-38 changed heredoc → echo -e

- [ ] **3.2** - No raw escape codes
  - Verify: No `\033[1m` or `[0;36m` in output
  - Command: `delete-template --help 2>&1 | grep -c 033`
  - Expected: Output should be 0

---

## 📋 Feature Tests (SHOULD PASS)

### 4. Deploy/Undeploy MOTD
- [ ] **4.1** - deploy-motd: Shows help correctly
- [ ] **4.2** - deploy-motd: Handles SSH errors gracefully (non-existent host)
- [ ] **4.3** - undeploy-motd: Shows help correctly
- [ ] **4.4** - undeploy-motd: Single host mode works
- [ ] **4.5** - undeploy-motd --all: Shows --all option available
- [ ] **4.6** - Both commands integrate with menu system

---

### 5. Generate MOTD
- [ ] **5.1** - Interactive mode: `printf 'n\n1\n' | generate-motd test`
- [ ] **5.2** - Non-interactive: `printf 'y\n8080\n' | generate-motd test`
- [ ] **5.3** - Templates created successfully
- [ ] **5.4** - Template syntax valid (bash -n)
- [ ] **5.5** - bulk-generate-motd works
- [ ] **5.6** - All styles selectable (1-6)

---

### 6. List Templates
- [ ] **6.1** - list-templates (default mode) shows count
- [ ] **6.2** - list-templates --status shows 🟢🟡🔴 indicators
- [ ] **6.3** - list-templates --view opens menu (FIXED)
- [ ] **6.4** - Templates display clean formatting
- [ ] **6.5** - No escape code artifacts

---

## 🔍 Integration Tests

### 7. Menu Navigation (All Commands)
- [ ] **7.1** - homelab → Arrow keys work
- [ ] **7.2** - homelab → q exits
- [ ] **7.3** - edit-hosts → All submenus navigate correctly
- [ ] **7.4** - bulk-generate-motd → Menu works
- [ ] **7.5** - delete-template → Interactive selection works
- [ ] **7.6** - All menus show proper titles

---

### 8. Installation/Uninstall Flow
- [ ] **8.1** - Fresh install completes
- [ ] **8.2** - Update install works without extra prompts
- [ ] **8.3** - .bashrc configured correctly
- [ ] **8.4** - Symlinks created in ~/.local/bin
- [ ] **8.5** - Uninstall cancels safely
- [ ] **8.6** - Reinstall after cancel works

---

## 🧪 Automated Tests (bash -n)

All scripts pass syntax validation:

```bash
✓ bin/homelab
✓ bin/edit-hosts (FIXED: 3 title args)
✓ bin/list-templates (FIXED: choose_menu)
✓ bin/delete-template (FIXED: heredoc)
✓ bin/deploy-motd
✓ bin/undeploy-motd
✓ bin/generate-motd
✓ bin/bulk-generate-motd
✓ bin/cleanup-keys
✓ bin/copykey
✓ bin/cleanup-homelab
✓ bin/edit-config
✓ All lib/*.sh files
```

---

## 📝 Test Results Template

```
Test Run: [DATE]
Tester: [NAME]
Version: 3.6.0-dev.20

Critical Tests:
  edit-hosts menus:    [ ] PASS [ ] FAIL
  list-templates --view: [ ] PASS [ ] FAIL
  delete-template help: [ ] PASS [ ] FAIL

Feature Tests:
  deploy-motd:         [ ] PASS [ ] FAIL
  undeploy-motd:       [ ] PASS [ ] FAIL
  generate-motd:       [ ] PASS [ ] FAIL
  list-templates:      [ ] PASS [ ] FAIL

Integration Tests:
  Menu navigation:     [ ] PASS [ ] FAIL
  Install/Uninstall:   [ ] PASS [ ] FAIL

Issues Found:
  [ ] None
  [ ] See details below:

Details:
_____________________________________________________________________________
```

---

## 🚀 Ready for Main Merge?

**v3.6.0-dev.20 is ready to merge to main when:**

1. ✅ All critical tests pass (edit-hosts, list-templates --view, delete-template)
2. ✅ All feature tests pass (deploy/undeploy, generate, list modes)
3. ✅ All integration tests pass (menus, install/uninstall)
4. ✅ No new bugs found during testing
5. ✅ Fresh install tested from scratch
6. ✅ Update install tested (without extra prompts)
7. ✅ Uninstall tested (cancel + full flow)

---

## 📌 Known Issues / TODO

### v3.6.0-dev.21+ (Future)
- [ ] Banner prompt skip on Update (identified in dev.18, TODO added)
  - Issue: sed removes HLT_BANNER before grep checks for it
  - Fix needed: Save HLT_BANNER before cleanup

---

## Running Test-Runner

```bash
cd ~/homelab-tools

# Start interactive test runner
./test-runner.sh

# Follow prompts to test each section
# Progress saved in ~/.homelab-test-progress
```

**Estimated Time:** 45-75 minutes for complete test run

---

**Last Updated:** 2025-12-14 by Claude (Haiku 4.5)  
**Status:** Ready for testing ✅
