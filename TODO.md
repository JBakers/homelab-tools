# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.
> Workflow: Fix Critical → High Priority → Commit → Comprehensive Testing → Merge to main → Version bump

## 🔴 CRITICAL

- [x] **Fix undeploy-motd bug** - Searches for `99-homelab-*.sh` but deploy-motd creates `00-motd.sh`

## 🎯 Status - 3.6.2-dev.00 (building on 3.6.1)

**Current version:** 3.6.2-dev.00
**Branch:** develop
**Tests:** Need to run

**New features completed (this session):**
- [x] Menu restructure: SSH keys moved to Configuration submenu
- [x] Help menu's vereenvoudigd (homelab --help, homelab help)
- [x] Generate MOTD: host selection menu (select from SSH config hosts)
- [x] HLT MOTD protection markers (HLT-MOTD-START/END)
- [x] Deploy protection: detect non-HLT MOTDs, ask replace/append/cancel
- [x] Undeploy protection: only remove HLT MOTDs, preserve others
- [x] Bulk deploy: show output (was hidden with &>/dev/null causing hangs)
- [x] Bulk deploy: retry failed deployments option
- [x] Bulk deploy: show failed hosts list
- [x] Removed all debug connection prompts (auto-continue after timeout)
- [x] Removed legacy code (old MOTD format detection, ~/homelab-tools migration)
- [x] Renamed "Legacy backups" to "Home Backups" in menu
- [x] Compacter deploy output (less verbose)
- [x] Fixed backslashes in prompts (y/N) instead of \(y/N\)

**Bug fixes:**
- [x] Fixed `local` outside function error in generate-motd menu
- [x] Fixed DIM variable undefined in deploy-motd and undeploy-motd

**Cleanup:**
- [x] Removed legacy MOTD detection (only check HLT-MOTD-START now)
- [x] Removed ~/homelab-tools migration code from install.sh
- [x] Renamed legacy → home in backup menu

---
## 🚀 NEXT STEPS

**Release 3.6.0 (ready to ship)**
- ✅ All features complete
- ✅ All bugs fixed
- ✅ Tests passing (72/72)
- ✅ Documentation updated

**Release Process:**
```bash
# 1. Final version bump (remove -dev)
echo "3.6.0" > VERSION

# 2. Update CHANGELOG to stable
# Edit CHANGELOG.md: v3.6.0-dev → v3.6.0

# 3. Commit
git add VERSION CHANGELOG.md
git commit -m "chore: release v3.6.0"
git push origin develop

# 4. Merge to main
./merge-to-main.sh

# 5. Tag release
git checkout main
git tag -a v3.6.0 -m "Release v3.6.0 - Enhanced MOTD & SSH management"
git push origin v3.6.0

# 6. GitHub Release
# Create release on GitHub with CHANGELOG
```

---
## 🟠 Medium Priority (post-3.6.0)

- [ ] **Archive TESTING_GUIDE.md** → `.archive/` (outdated)
- [ ] **Consolidate features into homelab menu**
  - Check all features are accessible via menu
  - Add missing: undeploy-motd, list-templates --status/--view
- [ ] **Update README.md** - Focus on homelab command
  - Keep standalone commands for scripting
  - Promote menu-driven workflow

## 🟢 Low Priority

- [ ] Add delete-all / delete-multiple to delete-template menu
- [ ] Improve ASCII preview performance
- [ ] Add more MOTD templates
- [ ] Add i18n support (future)

---
## ✅ DONE: v3.6.0 Features

### Enhanced edit-hosts
- [x] Interactive host menu with arrow key navigation
- [x] Add new host wizard with validation
- [x] Host operations: view, edit, delete, copy
- [x] Search/filter hosts by pattern
- [x] Bulk operations: export list, backup, batch delete

### MOTD Management
- [x] undeploy-motd (single + bulk with --all)
- [x] list-templates --status (deployment tracking)
- [x] list-templates --view (interactive preview)
- [x] Deployment logging

### Banner System
- [x] Special occasion messages (New Year, Christmas, etc.)
- [x] Auto-enabled in --non-interactive mode
- [x] Complete cleanup on uninstall
- [x] Leading-zero format (dev.00-dev.09)

### Developer Experience
- [x] sync-dev.sh for rapid testing
- [x] Auto-bump patch version after dev.09
- [x] Clean /opt structure (11 essential files)
- [x] Comprehensive .gitignore for dev files

---
## 📚 ARCHIVE: Older Versions

### v3.5.0 (Released 2025-12-14)
- ShellCheck compliance
- English translation
- Test runner (72 tests, 12 sections)
- Arrow navigation in all menus
- q=cancel everywhere
- Uninstall with safety checks
- .bashrc cleanup
