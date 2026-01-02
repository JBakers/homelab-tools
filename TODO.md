# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.
> Workflow: Fix Critical → High Priority → Commit → Comprehensive Testing → Merge to main → Version bump

## 🔴 CRITICAL

- [x] **Auto-bump VERSION** - Git hook voor automatisch versie increment
  - ✅ RESOLVED: prepare-commit-msg hook in .husky/_/
  - ✅ Auto-bump works: 03 → 04 (tested and working!)
  - ✅ Commit format: [3.6.3-dev.04] commit message
  - ✅ Only on develop branch
  - ✅ Skips merge/squash/amend commits
  - ✅ Auto-bump .09 → patch version bump
  - ✅ Committed: 62ceedb (v3.6.3-dev.04)

- [x] **Fix bump-dev.sh** - Remove Version prefix from commit messages
  - ✅ RESOLVED: bump-dev.sh now uses clean conventional commits
  - ✅ Tested git hooks (pre-commit/post-commit) → Not reliable for file updates
  - ✅ **Decision: Keep bump-dev.sh as manual workflow (best practice)**
  - ✅ Usage: `./bump-dev.sh "feat: description"` OR manual `git commit`
  - ✅ Committed: 2fb1f7e (bump-dev.sh fix)

- [x] **Phase 2 Changes LOST** - Arrow navigation changes from 1b4875d not in current HEAD
  - ✅ RESOLVED: Reapplied all conversions + tested in .test-env
  - ✅ Result: 40/44 tests passing (91% success rate)
  - ✅ All menus now use choose_menu with arrow navigation
  - ✅ Committed: 12fc46e (v3.6.3-dev.02)

- [x] **Fix undeploy-motd bug** - Searches for `99-homelab-*.sh` but deploy-motd creates `00-motd.sh`

## 🎯 Status - 3.6.3-dev.02 (Arrow Navigation COMPLETE ✅)

**Current version:** 3.6.3-dev.02
**Branch:** develop
**Status:** ✅ Phase 2 COMPLETE - All 15 menus converted to arrow navigation

**Phase 2 Results (v3.6.3-dev.02):**
- [x] bulk-generate-motd (5 menus) → arrow navigation ✅
- [x] deploy-motd (1 menu) → arrow navigation ✅
- [x] generate-motd (1 menu) → arrow navigation ✅
- [x] homelab (4 menus) → already had arrow navigation ✅
- [x] list-templates (no menus - uses flags) → N/A
- [x] delete-template (1 menu) → arrow navigation ✅
- [x] cleanup-keys (1 menu) → arrow navigation ✅
- [x] Added choose_menu wrapper to lib/menu-helpers.sh ✅
- [x] Fixed sourcing in all scripts ✅
- [x] Tested in .test-env: 40/44 tests passing (91%) ✅
- [x] All syntax checks pass ✅
- [x] All ShellCheck passes ✅
- [x] VERSION bumped (dev.01 → dev.02) ✅
- [x] Committed: 12fc46e ✅

**Phase 2.5 Results (v3.6.3-dev.01):**
- [x] Commitlint + Husky installed
- [x] Conventional commits enforced (type: message)
- [x] .gitignore updated (node_modules, .husky/)
- [x] copilot-instructions.md updated with COMMIT APPROVAL WORKFLOW
- [x] All commits validated automatically
- [x] Copilot restricted to develop branch only
- [x] Merge to main restricted to user only

---
## 🚀 NEXT STEPS

### Phase 3: Per-Menu Testing & Validation (IN PROGRESS)
**Goal:** Test all 15 menus for functionality, navigation, edge cases

**Step 1: Manual Testing (Quick Validation)**
- [ ] bulk-generate-motd: 5 menus (MOTD style, ASCII selection, generation mode, deploy, actions)
- [ ] deploy-motd: 1 menu (MOTD protection - Replace/Append/Cancel)
- [ ] generate-motd: 3 menus (Customize, Web UI, ASCII style)
- [ ] homelab: 4 menus (Generation mode, Deploy choice, Undeploy choice, Uninstall)
- [ ] list-templates: 1 menu (View vs Status)
- [ ] delete-template: 1 menu (Template selection + Delete ALL)
- [ ] cleanup-keys: 1 menu (Host selection + All hosts)

**Step 2: Automated Expect Tests**
- [ ] Create `expect/test-menu-navigation.exp` - Arrow keys (↑↓) and vim (j/k)
- [ ] Create `expect/test-bulk-generate.exp` - Full workflow testing
- [ ] Create `expect/test-deploy-protection.exp` - MOTD protection scenarios
- [ ] Integrate into test-runner.sh

**Step 3: Integration Testing**
- [ ] Test full workflow: generate → deploy → list → undeploy
- [ ] Test bulk operations (--all flag)
- [ ] Test edge cases (empty templates, invalid input, etc.)

**Acceptance Criteria:**
- [ ] All 15 menus navigable (↑↓, j/k, Enter, q/ESC)
- [ ] All prompts functional
- [ ] No crashes or hangs
- [ ] Consistent UX across all scripts
- [ ] 100% menu coverage in tests

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
