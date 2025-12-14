# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.
> Workflow: Fix Critical → High Priority → Commit → Comprehensive Testing → Merge to main → Version bump

## 🎯 v3.5.0 RELEASED ✅

**All tests passed! (72/72)**
- Merged to main
- Version bumped to 3.5.0
- Production ready

### Post-release bugfixes (in develop):
- [x] Fixed install.sh banner HLT_VERSION if/else order
- [x] Fixed uninstall.sh .bashrc cleanup (awk state machine)
- [x] Fixed install.sh clean_user_data() - was using simple sed, now uses full awk
- [x] Fixed .bashrc ownership after sudo cleanup (chown to user)
- [x] Added undeploy-motd script + menu integration

---

## 🟡 Medium Priority (v3.6.0)

- [x] **SSH MOTD uninstall** - Remove deployed MOTDs from remote hosts
  - Created undeploy-motd script with single & bulk removal
  - Remove /etc/profile.d/99-homelab-*.sh files from host via SSH
  - Restore original /etc/motd if backup exists
  - Added to homelab menu (MOTD Tools → Undeploy MOTD)
  - Supports --all flag for bulk removal

- [x] **List templates with host status** - Show which hosts have MOTD templates
  - Added `-s` or `--status` flag to list-templates
  - Output format: `hostname | modified | size | status`
  - Status: 🟢 deployed, 🟡 ready, 🔴 stale
  - Tracks deployment info in ~/.local/share/homelab-tools/deploy-log
  - deploy-motd now logs each deployment

- [x] **Show MOTD preview in template list** - Interactive option to view MOTD content
  - Added `-v` or `--view` flag to list-templates for interactive preview
  - Arrow key navigation through template list
  - Executes template to show actual MOTD output
  - Press Enter to return to menu, q to quit

- [x] **Verify Jellyfin auto-detection is not too aggressive**
  - Removed Jellyfin as default example throughout codebase
  - Replaced with Pi-hole (more universal homelab service)
  - Updated all help texts, examples, and README
  - Service auto-detection still works for all 60+ services

## 🟢 Low Priority

- [ ] Improve ASCII preview performance
- [ ] Add more MOTD templates
- [ ] Add i18n support (future)

## 📋 Planned: Enhanced edit-hosts (v3.6.0)

- [ ] **Interactive host menu** - Show list of all SSH config hosts
  - View host details
  - Edit host entry
  - Delete host
  - Copy host (with numeric suffix like host-copy1)
  - Search/filter hosts by name pattern
- [ ] **Add Host guided wizard** - Interactive prompts for:
  - Hostname, HostName/IP, User, Port, SSH key path
  - Input validation
  - Append to config without nano
- [ ] **Bulk operations**
  - Disable/enable multiple hosts
  - Export host list
  - Backup SSH config
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
