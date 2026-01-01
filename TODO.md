# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.
> Workflow: Fix Critical → High Priority → Commit → Comprehensive Testing → Merge to main → Version bump

## 🔴 CRITICAL

- [x] **Fix undeploy-motd bug** - Searches for `99-homelab-*.sh` but deploy-motd creates `00-motd.sh`

## 🎯 v3.6.0 STATUS - READY FOR RELEASE! 🎉 (dev.35)

**New features completed:**
- [x] undeploy-motd - Remove MOTDs from hosts
- [x] list-templates --status - Deployment tracking
- [x] list-templates --view - Interactive preview
- [x] Removed Jellyfin examples, replaced with Pi-hole
- [x] Enhanced edit-hosts - Full interactive SSH config manager
- [x] Centralized version management (VERSION file + lib/version.sh)
- [x] Special occasion messages in banner (New Year, Christmas, etc.)
- [x] sync-dev.sh - Quick sync workspace to /opt for rapid testing
- [x] Auto-bump patch version after dev.09 (3.6.0-dev.09 → 3.6.1-dev.00)
- [x] Exclude dev-only files from /opt (bump-dev.sh, TODO.md, etc.)
- [x] Exclude GitHub-only docs from /opt (CHANGELOG, CONTRIBUTING, etc.)

**Bug fixes (v3.6.0-dev.21-35):**
- [x] edit-hosts: Fixed 3 missing title arguments in show_arrow_menu calls
- [x] list-templates --view: Fixed wrong function name (choose_menu → show_arrow_menu)
- [x] delete-template: Fixed escape codes in help (heredoc → echo -e)
- [x] README: Updated to v3.6.0, removed dev warning
- [x] Banner: Fixed complete uninstall not removing banner (increased line limit 50→60)
- [x] Banner: Fixed cleanup not removing standalone tip line
- [x] Banner: Now enabled by default in --non-interactive mode
- [x] Banner: Fixed special occasions auto-reload
- [x] edit-hosts: Fixed menu not showing due to clear() conflict
- [x] uninstall.sh: Increased bashrc cleanup limit from 50 to 60 lines

**Repository cleanup:**
- [x] Archive `bump-version.sh` → `.archive/`
- [x] Archive `update-version.sh` → `.archive/`
- [x] Translate all Dutch text to English
- [x] Installed expect tool for automated menu testing
- [x] Updated test-runner.sh: 16 MANUAL tests → 0 MANUAL tests
- [x] All 72 tests PASSED (100%) ✅
- [x] sync-dev.sh in .gitignore
- [x] Exclude dev-only files from /opt (15→11 items)
- [x] Clean /opt structure - only production files

---
## 🚀 NEXT STEPS

**v3.6.0 READY FOR RELEASE!**
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
## �� Medium Priority (post-3.6.0)

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
