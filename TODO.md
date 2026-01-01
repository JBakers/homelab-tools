# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.
> Workflow: Fix Critical → High Priority → Commit → Comprehensive Testing → Merge to main → Version bump

## 🔴 CRITICAL

- [x] **Fix undeploy-motd bug** - Searches for `99-homelab-*.sh` but deploy-motd creates `00-motd.sh`

## 🎯 v3.6.0 IN PROGRESS 🚧 (dev.35)

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

**Repository cleanup (audit 2025-12-14):**
- [x] Archive `bump-version.sh` → `.archive/` (duplicate of smarter release.sh)
- [x] Archive `update-version.sh` → `.archive/` (redundant)
- [x] Translate all Dutch text to English (scripts and comments)
- [x] Installed expect tool for automated menu testing
- [x] Updated test-runner.sh: 16 MANUAL tests → 0 MANUAL tests (fully automated, 5-10 min runtime)
- [ ] **RUN COMPREHENSIVE TESTS** - Execute test-runner.sh to validate v3.6.0-dev.20
  - [x] Pre-flight checks (git, version, clean state)
  - [x] Fresh install flow
  - [x] Menu systems (homelab, edit-hosts, list-templates)
  - [x] MOTD generation & deployment
  - [x] Install/update/uninstall flows
  - [x] All 72 tests PASSED (100%) ✅

---
## 🚀 NEXT STEPS

1. **RUN TESTS FIRST** (before any commit/merge decision)
   ```bash
   cd ~/homelab-tools
   ./test-runner.sh
   ```
   - Run all 80 tests (automated, ~5-10 minutes)
   - Verify all tests PASS
   - Progress saves in `~/.homelab-test-progress`

2. **Post-Test Actions** (only if tests PASS)
   - Bump version: `./bump-dev.sh`
   - Update CHANGELOG.md
   - Commit: `git add -A && git commit -m "..."`
   - Push: `git push origin develop`
   - Request merge to main (via pull request)

3. **Testing Rule** (NEW - per claude.md)
   - **Major changes/new features MUST be tested before commit**
   - No untested/broken/non-working commits
   - Test checklist: syntax, help text, functionality, menus, integration
   - This ensures code quality and team productivity

---
## � Medium Priority
- [x] **Skip banner prompt on Update** - Fixed by defaulting to 'y' in non-interactive mode
- [ ] **Promote homelab command only** in README
  - [x] README updated with all current features and commands
  - [ ] Consider hiding individual command docs
  - [ ] Keep standalone commands for power users/scripting, but don't promote
- [ ] **Archive TESTING_GUIDE.md** → `.archive/` (outdated, manual testing via menu is simpler)
  - [ ] Skip banner prompt if already configured
  - Root cause: Sed removes banner block (L341), then grep for HLT_BANNER fails (L408)- [ ] **Consolidate all features into `homelab` menu** - Users only need to remember one command
  - [ ] Check all features are accessible via menu
  - [ ] Add missing features to menu if needed (undeploy-motd, list-templates --status/--view)
  - [ ] Keep standalone commands for power users/scripting, but don't promote
- [ ] **Archive TESTING_GUIDE.md** → `.archive/` (outdated, manual testing via menu is simpler)
- [ ] **Update README.md** - Promote only `homelab` command, hide individual commands

## �🟢 Low Priority

- [ ] Add delete-all / delete-multiple to delete-template menu
- [ ] Create `lib/constants.sh` for shared `UNSUPPORTED_SYSTEMS` array
- [ ] Improve ASCII preview performance
- [ ] Add more MOTD templates
- [ ] Add i18n support (future)

## ✅ DONE: Enhanced edit-hosts (v3.6.0)

- [x] **Interactive host menu** - Show list of all SSH config hosts
  - View host details
  - Edit host entry
  - Delete host
  - Copy host (with numeric suffix like host-copy1)
  - Search/filter hosts by name pattern
- [x] **Add Host guided wizard** - Interactive prompts for:
  - Hostname, HostName/IP, User, Port, SSH key path
  - Input validation (IP octet check, port range, hostname chars)
  - Append to config without nano
- [x] **Bulk operations**
  - Export host list to file
  - Backup SSH config (timestamped)
  - Batch delete hosts

## 📋 Planned: MOTD Customization (v3.7.0)

- [ ] **Custom MOTD support** - Allow users to add personal/custom content to generated MOTDs
  - Post-generation hook to edit/append custom sections
  - Optional "custom footer" field in MOTD config
  - Template variables for personalization (e.g., hostname, IP, owner)
- [ ] **Advanced MOTD options**
  - Custom color schemes per host
  - Include/exclude system stats sections
  - Custom ASCII art per host (not just styles 1-6)

---

## 📚 ARCHIVE: Completed Work

### ✅ v3.6.0 (In Development)

**Medium Priority - All Complete:**
- [x] undeploy-motd script (single + bulk removal)
- [x] list-templates --status (deployment tracking with 🟢🟡🔴 indicators)
- [x] list-templates --view (interactive MOTD preview)
- [x] Removed Jellyfin bias (replaced with Pi-hole examples)

**Post-v3.5.0 Bugfixes:**
- [x] install.sh banner HLT_VERSION if/else order
- [x] uninstall.sh .bashrc cleanup (awk state machine)
- [x] install.sh clean_user_data() full awk implementation
- [x] .bashrc ownership restoration after sudo operations

### ✅ v3.5.0 (Released 2025-12-14)

**Critical:**
- [x] Fix all ShellCheck warnings
- [x] Fix VERSION file mismatch (bump to dev.31)
- [x] Translate all Dutch text to English
- [x] Create test runner tools (test-runner.sh with 72 tests, 12 sections)

**High Priority:**
- [x] Test all menu paths and q=cancel
- [x] Test bulk-generate-motd modes (interactive, smart-detect, yes-to-all)
- [x] Test uninstall.sh thoroughly
- [x] Review cleanup-homelab script
- [x] Add install-time prompt to run uninstall if existing install is detected
- [x] Install menu: when existing HLT detected, prompt for update / remove / full uninstall / remove+clean install
- [x] Install option 1 (Update): preserve existing config - No re-prompts for known data
- [x] Audit all menus - arrow navigation (↑↓) + Enter everywhere

**Comprehensive Testing (72/72 passed):**
- [x] install.sh - Fresh install, upgrade, migration, .bashrc cleanup
- [x] uninstall.sh - Complete removal, backup/keep options
- [x] All menu navigation (arrow keys, q=cancel, all paths)
- [x] All features (homelab, bulk-generate, generate-motd, deploy, cleanup, etc.)
- [x] Error handling (invalid input, missing files, unreachable hosts, permissions)
- [x] Translation verification (no Dutch text, all English)

### ✅ v3.5.0-dev.24
- [x] Arrow nav fixed in all menus
- [x] q=cancel everywhere
- [x] Uninstall menu with safety checks
- [x] .bashrc cleanup (prevent duplicates)

### ✅ Earlier Versions
- [x] Menu navigation and q=cancel functionality
- [x] ShellCheck compliance
- [x] English translation
- [x] Installation and uninstall workflows
