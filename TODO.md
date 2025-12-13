# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.
> Workflow: Fix Critical → High Priority → Commit → Comprehensive Testing → Merge to main → Version bump

## 🔴 Critical (Done ✅)

- [x] Fix all ShellCheck warnings
- [x] Fix VERSION file mismatch (bump to dev.25)
- [x] Translate all Dutch text to English

## 🟠 High Priority (Test & Fix)

- [ ] Test all menu paths and q=cancel
- [ ] Test bulk-generate-motd modes (interactive, smart-detect, yes-to-all)
- [ ] Test uninstall.sh thoroughly
- [ ] Review cleanup-homelab script

**After High Priority:** Commit all fixes, then move to Testing phase

## 🧪 Comprehensive Testing (Before main merge)

### Core Functionality Tests
- [ ] **install.sh** - Fresh install on clean system
- [ ] **install.sh** - Upgrade existing installation (test backups)
- [ ] **install.sh** - Migration from ~/homelab-tools to /opt
- [ ] **install.sh** - Test .bashrc cleanup (no duplicates)
- [ ] **uninstall.sh** - Complete removal, no orphaned files
- [ ] **uninstall.sh** - Test backup/keep options

### Menu & Navigation Tests
- [ ] Arrow key navigation (↑↓) in all menus
- [ ] q=cancel works on all prompts
- [ ] All menu options lead to correct scripts
- [ ] HELP option works everywhere
- [ ] Back/Quit options work correctly

### Feature Tests
- [ ] **homelab** main menu all paths
- [ ] **bulk-generate-motd** - Interactive mode
- [ ] **bulk-generate-motd** - Smart-detect mode
- [ ] **bulk-generate-motd** - Yes-to-all mode
- [ ] **generate-motd** - All ASCII art styles (1-6)
- [ ] **generate-motd** - Preview mode (-p flag)
- [ ] **deploy-motd** - SSH deployment to host
- [ ] **cleanup-keys** - Single & bulk cleanup
- [ ] **cleanup-homelab** - Orphan detection & removal
- [ ] **copykey** - Key distribution to hosts
- [ ] **edit-config** - Config editing
- [ ] **edit-hosts** - SSH config editing
- [ ] **list-templates** - Template listing

### Error Handling Tests
- [ ] Invalid input handling
- [ ] Missing files/configs
- [ ] Unreachable hosts
- [ ] Permission errors
- [ ] No MOTD templates scenario

### Translation Verification
- [ ] No Dutch text in user output
- [ ] All error messages in English
- [ ] Help text fully English

**After Testing:** If all pass → merge to main and bump version to 3.5.0

## 🟡 Medium Priority

- [ ] Add .editorconfig
- [ ] Update QUICKSTART.md
- [ ] Test release.sh workflow

## 🟢 Low Priority

- [ ] Improve ASCII preview performance
- [ ] Add more MOTD templates
- [ ] Add i18n support (future)

---

## ✅ v3.5.0-dev.25 Done
- All ShellCheck warnings fixed
- Complete English translation of all scripts
- Version sync: VERSION file 3.5.0-dev.25
- Fixed install.sh tip_count syntax error

## ✅ v3.5.0-dev.24 Done
- Arrow nav fixed • q=cancel everywhere • Uninstall menu • .bashrc cleanup
