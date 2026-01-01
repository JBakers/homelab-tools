# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.
> Workflow: Fix Critical → High Priority → Commit → Comprehensive Testing → Merge to main → Version bump

## 🔴 CRITICAL

- [x] **Fix undeploy-motd bug** - Searches for `99-homelab-*.sh` but deploy-motd creates `00-motd.sh`

## 🎯 Status - 3.6.2-dev.09 (building on 3.6.1)

**Current version:** 3.6.2-dev.09
**Branch:** develop
**Tests:** ✅ **41/42 PASSED (98% success rate)** 🎉

**Test Suite Expansion (Session 2026-01-01):**
- [x] Fixed all skipped tests (list-templates now tested)
- [x] Fixed deploy-motd test (MOTD protection with auto-reply)
- [x] Fixed CLI options test suite (syntax error, removed non-existent commands)
- [x] Added 6 new test scenarios:
  - Multiple template generation (test1, test2, test3)
  - List templates with multiple templates
  - Delete template functionality
  - Deploy MOTD protection scenarios (jellyfin, docker-host)
  - Undeploy from multiple hosts
  - Enhanced CLI options coverage
- [x] Docker test environment fixes:
  - Added rsync to Dockerfile
  - Fixed expect script timeouts (5s → 10s)
  - Simplified expect scripts (menu structure changes)
  - Added `< /dev/null` and `echo 'q'` for non-interactive tests
- [x] Test coverage: 36 tests → 42 tests (+17%)
- [x] Success rate: 89% → 98% (+9%)
- [x] Zero failures (was 2 failures)

**Previous session features (v3.6.2-dev.00 - dev.08):**
- [x] Menu restructure: SSH keys moved to Configuration submenu
- [x] Help menu's vereenvoudigd (homelab --help, homelab help)
- [x] Generate MOTD: host selection menu (select from SSH config hosts)
- [x] HLT MOTD protection markers (HLT-MOTD-START/END)
- [x] Deploy protection: detect non-HLT MOTDs, ask replace/append/cancel
- [x] Undeploy protection: only remove HLT MOTDs, preserve others
- [x] Bulk deploy: show output, retry failed, failed hosts list
- [x] `deploy-motd --all` - Deploy all templates at once
- [x] Removed all debug connection prompts
- [x] Removed legacy code (old MOTD format detection, ~/homelab-tools migration)
- [x] Renamed "Legacy backups" to "Home Backups" in menu
- [x] Compacter deploy output
- [x] GUI-focused help

**Bug fixes:**
- [x] Fixed `local` outside function error in generate-motd menu
- [x] Fixed DIM variable undefined in deploy-motd and undeploy-motd
- [x] Fixed test suite hangs (timeouts, input handling)
- [x] Fixed CLI options syntax error (extra `)` in commands array)

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

### Test Suite Expansion (Complete HLT Coverage)
**Goal:** Expand .test-env to test all menus, all commands, all options, all edge cases

**Step 1: New Expect Scripts for Missing Menus**
- [ ] Create `expect/test-config-submenu.exp` - Configuration menu navigation
- [ ] Create `expect/test-backup-menu.exp` - Backup management all options
- [ ] Create `expect/test-edit-hosts-wizard.exp` - Full add host wizard flow
- [ ] Create `expect/test-edit-hosts-bulk.exp` - Bulk operations submenu
- [ ] Create `expect/test-arrow-navigation.exp` - Arrow keys (↑↓) and vim keys (j/k)

**Step 2: Expand complete-integration-test.sh**
- [ ] Add Phase 12: Service auto-detection (test 10+ presets: pihole, plex, sonarr, etc.)
- [ ] Add Phase 13: list-templates --status with deployed templates
- [ ] Add Phase 14: Backup menu operations (archive, move, delete)
- [ ] Add Phase 15: edit-config settings interactive flow
- [ ] Add Phase 16: Number handling (pihole2 → "Pi-hole 2")

**Step 3: New CLI Options Test File**
- [ ] Create `test-cli-options.sh` - Test all --help, --all, -s, -v flags
- [ ] Test exit codes and error messages
- [ ] Test input validation (invalid service names, hosts)

**Step 4: Update run-tests.sh**
- [ ] Add Section 8: CLI option tests
- [ ] Add Section 9: Service preset tests
- [ ] Add Section 10: Full menu navigation via expect
- [ ] Update test-runner.sh progress counter (72 → ~100+ tests)

**Step 5: Update Docker Environment**
- [ ] Add 2 extra mock SSH hosts to docker-compose.yml (totaal 5 for bulk tests)
- [ ] Add mock host with existing non-HLT MOTD for protection tests

**Step 6: Documentation Updates**
- [ ] Update .test-env/README.md with test matrix and coverage percentages
- [ ] Document test naming convention
- [ ] Add test execution guide

**When All Above Done:**
- [ ] Run full test suite: `cd .test-env && ./run-tests.sh`
- [ ] Fix any failing tests
- [ ] Achieve 100% menu/command coverage

### Other Medium Priority
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
