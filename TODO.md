# TODO: Homelab-Tools

**Version:** 3.6.7-dev.02
**Last Update:** 2026-01-03
**Test Status:** 46/48 passing (96%) ✅ | Security: 20/20 Audit Issues + P1 + P2 COMPLETE

> 📋 **IMPORTANT:** Testing work moved to **[TESTING-TODO.md](TESTING-TODO.md)**
> - Phase 1-3 complete: 48 core tests, 93+ total tests
> - This file: Features, bugs, remaining audit items, product roadmap
> - All CRITICAL + HIGH + MEDIUM priority security issues FIXED ✅
> - AUDIT-11 t/m 16 FIXED ✅ + P1 + P2 COMPLETE ✅
>
> Workflow: Fix by priority → Test → Bump version → Commit (with approval) → Push

---

## 🔄 CURRENT SESSION: 2026-01-03

**Focus:** Testing Phase 4-6 + CI/CD Pipeline

**Plan:**
- [ ] Fase 4: P1 Test Cases (non-interactive, bulk ops, version check)
- [ ] Fase 5: P2 Test Cases (HLT markers, deploy log, edge cases)
- [ ] AUDIT-3: CI/CD Pipeline (careful implementation)

---

## 🎉 PREVIOUS SESSION: 2026-01-02 - ALL AUDIT ISSUES + P1 + P2 FIXED!

**CRITICAL (2/3) ✅:** SSH injection, temp files | **1 ⏳ DEFERRED:** CI/CD pipeline  
**HIGH (7/7) ✅:** eval, error handling, duplicates, config, hostname, path validation  
**MEDIUM (11/11) ✅:** pre-commit, exit codes, docs, locking, race conditions, namespace, sourcing, magic numbers, menus, function docs, **REFACTOR**  
**P1 FEATURE ✅:** Service Preset Ports - 73 services configured (56 with Web UI, 17 without)
**P2 FEATURE ✅:** Smart Port Detection - lib/port-detection.sh with config/docker/listening/default priority

**Completed (2026-01-02):**
- ✅ AUDIT-11: Global Variable Namespace (HLT_MENU_KEY, HLT_MENU_RESULT prefixes)
- ✅ AUDIT-12: Library Sourcing Standardized (verified all use symlink resolution)
- ✅ AUDIT-13: Magic Numbers Centralized (SSH_CONNECT_TIMEOUT, constants.sh)
- ✅ AUDIT-14: Menu Systems Standardized (choose_menu() wrapper everywhere)
- ✅ AUDIT-15: Function Documentation (JSDoc-style headers added)
- ✅ AUDIT-16: Refactor generate-motd (1060 → 684 lines, -36%) - lib/service-presets.sh extracted
- ✅ P1: Service Preset Ports Complete (73 services, all ports configured)
- ✅ P2: Smart Port Detection (config overrides, docker, listening ports, defaults)

**Stats:** ~12 hours, 11 commits  

---

## ⏳ REMAINING CRITICAL (from CLAUDE-AUDIT.md)

### AUDIT-3: Geen CI/CD Pipeline - TASK (requires proper implementation)
**Severity:** CRITICAL | **Fix Time:** 4-6h | **Status:** ⏳ TODO

**Problem:** No automated tests on push/PR - all testing is manual

**Recommendation:** Create `.github/workflows/test.yml` with:
- Static analysis (syntax check, ShellCheck)
- Docker integration tests (48+ tests)
- Version consistency check  
- Runs on push/PR to develop and main

**Why Deferred:** Initial implementation was too premature (removed in commit c65f8db). CI/CD pipelines require careful testing before deployment to prevent merge conflicts and broken workflows.

**Implementation Notes:**
- Pre-test in develop branch first
- Don't auto-run on all branches initially
- Test with small changes before enabling
- Document any GitHub Actions secrets needed

---

### ✅ AUDIT-16: Refactor generate-motd - FIXED
**Severity:** MEDIUM | **Fix Time:** 2h | **Status:** ✅ FIXED (commit ed4a326)

**Fix Applied:** Major refactoring of generate-motd:
- Created `lib/service-presets.sh` with 65+ service presets
- Extracted 380+ lines from generate-motd (1060 → 684 lines, -36%)
- New `detect_service_preset()` function with HLT_ prefixed globals
- `get_all_service_presets()` helper for autocomplete
- Service categories: Media, *arr stack, Network, Monitoring, Virtualization, etc.

---

### ✅ P1: Service Preset Ports - COMPLETE
**Priority:** P1 | **Status:** ✅ COMPLETE (via AUDIT-16 refactor)

**Result:** All 73 services now have complete configurations:
- 56 services with Web UI and ports configured
- 17 services without Web UI (databases, VPNs, backup tools)
- All ports verified and documented in lib/service-presets.sh

---

### ✅ P2: Smart Port Detection - COMPLETE
**Priority:** P2 | **Status:** ✅ COMPLETE (commit 76dbca5)

**Implementation:** Created `lib/port-detection.sh` with multi-source port detection:

**Detection Priority Order:**
1. User config (`~/.config/homelab-tools/custom-ports.conf`)
2. Docker container inspection (`docker ps`)
3. Active listening ports (`ss/netstat`)
4. Fallback to service-presets.sh defaults

**Functions:**
- `init_port_detection()` - Initialize config directory
- `detect_port(service, host)` - Smart detection with priority
- `get_port_from_config()` - Check user overrides
- `get_port_from_docker()` - Docker container inspection
- `get_port_from_listening()` - ss/netstat port scanning
- `set_custom_port()` / `remove_custom_port()` - Config management

**Config file format:**
```
pihole=8080/admin
jellyfin=8097
```

---

## 🟢 COMPLETED MEDIUM PRIORITY (2026-01-02)

### ✅ AUDIT-11: Global Variable Namespace - FIXED
**Severity:** MEDIUM | **Fix Time:** 1.5h | **Status:** ✅ FIXED (commit 15093f2)

**Fix Applied:** Renamed global variables with HLT_ prefix:
- `MENU_KEY` → `HLT_MENU_KEY`
- `MENU_RESULT` → `HLT_MENU_RESULT`
- Updated all 11 bin/* scripts to use new names
- Prevents namespace pollution and conflicts

---

### ✅ AUDIT-12: Library Sourcing Patterns - VERIFIED
**Severity:** MEDIUM | **Fix Time:** 1h | **Status:** ✅ VERIFIED (already standardized)

**Status:** All bin/* scripts already use symlink resolution pattern (correct implementation). No changes needed.

---

### ✅ AUDIT-13: Magic Numbers Centralized - FIXED
**Severity:** MEDIUM | **Fix Time:** 1h | **Status:** ✅ FIXED (commit bdd9b23)

**Fix Applied:** Created constants in lib/constants.sh:
- `SSH_CONNECT_TIMEOUT=5`
- `SSH_BATCH_MODE=yes`
- `SSH_CONNECT_OPTS` array
- `TEST_TIMEOUT_*` constants
- Updated deploy-motd and undeploy-motd to use constants

---

### ✅ AUDIT-14: Menu Systems Standardized - FIXED
**Severity:** MEDIUM | **Fix Time:** 1h | **Status:** ✅ FIXED (commit d3e341b)

**Fix Applied:** Replaced direct `show_arrow_menu()` calls with `choose_menu()` wrapper:
- bin/list-templates: 1 call updated
- bin/edit-hosts: 4 calls updated
- Consistent menu interface with automatic TTY fallback

---

### ✅ AUDIT-15: Function Documentation - COMPLETED
**Severity:** MEDIUM | **Fix Time:** 2h | **Status:** ✅ FIXED (commit ed71bdc)

**Fix Applied:** Added JSDoc-style documentation headers:
- bin/deploy-motd: deploy_all()
- bin/undeploy-motd: undeploy_single(), undeploy_all()
- bin/edit-hosts: confirm_action(), init_ssh_config()
- bin/homelab: wait_for_continue(), show_usage_short()
- Note: menu-helpers.sh and validators.sh already had complete docs

---

## 🔴 REMAINING LOW PRIORITY (from CLAUDE-AUDIT.md)

### AUDIT-16: Refactor generate-motd (>1000 lines)
**Severity:** LOW | **Fix Time:** 8-12h
**Status:** NOT STARTED

**Problem:** generate-motd.sh is 1043 lines - too monolithic

**Recommendation:** Split into modules:
- `lib/service-presets.sh` - Service case statement
- `lib/motd-generator.sh` - Template generation logic
- `lib/motd-deploy.sh` - Deployment logic

---

### AUDIT-17: Add Real SSH Integration Tests
**Severity:** LOW | **Fix Time:** 2h
**Status:** NOT STARTED

**Problem:** Current tests use Docker mock servers only

**Recommendation:** Add optional tests against real SSH servers

---

### AUDIT-18: Improve Performance
**Severity:** LOW | **Fix Time:** 2h
**Status:** NOT STARTED

**Issues:**
- Excessive subshells in loops
- Repeated syscalls (can cache)
- Inefficient sed/awk patterns

---

### AUDIT-19: Port Validation Improvement
**Severity:** LOW | **Fix Time:** 30m
**Status:** NOT STARTED

**Problem:** `validate_port()` allows port 0 (invalid)

**Fix:** Change range to 1-65535 (already done!)

---

### AUDIT-20: Remove Commented-Out Code
**Severity:** LOW | **Fix Time:** 1h
**Status:** NOT STARTED

**Problem:** Several scripts have old code commented out

**Fix:** Clean up (e.g., `bin/generate-motd.backup` exists)

---

## 🟢 LONG-TERM IMPROVEMENTS (from CLAUDE-AUDIT.md)

### Future Enhancements
1. **Consider Python/Go port** - Better error handling, type safety
2. **Add telemetry** - Error tracking, usage analytics
3. **Create web UI** - For non-technical users
4. **Implement backup/rollback** - For MOTD deployments
5. **Add automated releases** - GitHub Actions workflow

---

**Fix Applied:** Added `validate_path()` in homelab for backup operations

---

## ✅ BUGS & UX ISSUES (Session Complete!)

### User Experience Issues
1. **generate-motd: No arrow menu**
   - Problem: Still uses old prompt-based input
   - Expected: Arrow menu for customization (y/n), Web UI (y/n), port selection
   - Impact: Inconsistent UX across tools

2. **Navigation help missing on some pages**
   - Problem: Not all menus show "Use ↑/↓ to navigate, Enter to select, q to quit"
   - Expected: Consistent footer on ALL interactive menus
   - Impact: Users don't know navigation keys

3. **Help text missing on some commands**
   - Problem: Some pages lack --help or in-menu help
   - Expected: Every command/menu should have help option
   - Impact: Reduced discoverability

4. **Arrow key enhancements**
   - Feature: → (right arrow) = Enter (select)
   - Feature: ← (left arrow) = Back/Cancel
   - Impact: Better navigation, matches user expectations

### Feature Gaps
5. **Limited ASCII art variants**
   - Current: 6 styles (clean, rainbow future, rainbow standard, mono future, big mono, small)
   - Requested: More variety (different fonts, colors, sizes)
   - Impact: More personalization options

6. **No custom MOTD designer**
   - Problem: Users can't design MOTD from scratch
   - Requested: Interactive MOTD builder (choose colors, layout, info blocks)
   - Impact: Full customization for advanced users

8. **No backup listing**
   - Problem: Can't see what backups exist before restore
   - Expected: List available backups with dates/sizes
   - Impact: Blind restore process

### Bugs (High Priority)
7. **BUG: bulk-generate-motd doesn't show existing MOTDs** ⚠️
   - Problem: Deploy phase doesn't display MOTD protection options
   - Expected: Show Replace/Append/Cancel when MOTD exists
   - Impact: Users overwrite MOTDs without knowing
   - Priority: HIGH (data loss risk)

9. **delete-template: Missing ALL function** ⚠️
   - Problem: Can't delete all templates at once anymore
   - Expected: "Delete ALL" option in menu (like before)
   - Impact: Tedious to clean up multiple templates
   - Priority: MEDIUM (regression)

### Fixed This Session (2026-01-02)

1. ✅ **generate-motd: Arrow menu converted**
   - Converted "Customize?" and "Deploy now?" prompts to arrow menus
   - Web UI selection now uses arrow menu
   - Consistent UX across all tools

2. ✅ **Navigation help updated**
   - Menu footer now shows: `↑/↓ or j/k │ Enter or → │ ← or q`
   - Users can use arrow keys OR vim keys OR q to navigate

3. ✅ **Arrow key enhancements implemented**
   - Added: → (right arrow) = Enter (select)
   - Added: ← (left arrow) = Back/Cancel
   - Better navigation, matches user expectations

4. ✅ **delete-template: ALL function verified**
   - Already present! (line 72-73 in delete-template)
   - "Delete ALL|Remove all templates" option in menu

5. ✅ **bulk-generate-motd: MOTD protection verified**
   - Already working! deploy-motd output is visible
   - Deploy phase calls `deploy-motd "$hostname"` without suppression
   - MOTD protection dialog shows Replace/Append/Cancel

### Remaining Feature Requests (P2)
- Limited ASCII art variants (nice-to-have, 6 styles exist)
- Custom MOTD designer (future feature)
- Backup listing (cleanup-homelab already handles backups)

### New: UX Test Suite Added
- Created `.test-env/ux/` with 17 UX test scripts
- Tests: arrow navigation, help flags, quit keys, colors, boxes, emojis
- Run with: `./run-ux-tests.sh`

---

## 🟠 HIGH PRIORITY (P1 - Features)

### 1. Complete Service Preset Ports (~2h)
**Status:** 42/48 implemented, ports incomplete
**Test:** `.test-env/test-service-presets-extended.sh` exists

**Missing Ports:**
- navidrome: 4533, audiobookshelf: 13378, whisparr: 6969
- unifi: 8443, uptime-kuma: 3001, tautulli: 8181
- netdata: 19999, glances: 61208
- nextcloud: 443, syncthing: 8384

**Action:** Add port configs to `bin/generate-motd` case statements

---

## 🟡 MEDIUM PRIORITY (P2 - Features)

### 2. Smart Port Detection (~3h) ⭐ OPPORTUNITY
**Design:** `.design/smart-port-detection.md`
**Problem:** Users run custom ports (zigbee2mqtt:2804 vs default:8080)

**Implementation:**
1. Config file: `~/.config/homelab-tools/custom-ports.conf`
2. SSH scan: `ss -tlnp | grep :PORT`
3. Docker check: `docker ps --format '{{.Ports}}'`
4. Interactive prompt (fallback)

**Benefits:** 90%+ auto-detection, <5% wrong URLs (was 30%)

---

---

## 📊 CURRENT STATUS

### Test Coverage
- **Total Tests:** 46/46 (100%) ✅
- **Menu Navigation:** 100%
- **Static Tests:** 100% (syntax, ShellCheck, help)
- **Functional Tests:** 100% (generate, deploy, list, delete)
- **Service Detection:** 87.5% (42/48 services)
- **Port Configuration:** 52% (22/42 services)

### Service Presets (42 implemented)
**Media:** jellyfin, plex, emby ✓
**\*arr:** sonarr, radarr, prowlarr, lidarr, readarr, bazarr ✓
**Download:** sabnzbd, nzbget, transmission, qbittorrent, deluge ✓
**Network:** pihole, adguard, unbound, nginx, traefik ✓
**Containers:** portainer, proxmox, pbs, yacht ✓
**Automation:** nodered, zigbee2mqtt, mosquitto, esphome, frigate ✓
**Monitoring:** grafana, prometheus, influxdb, tautulli, netdata, glances ✓
**Request:** overseerr, ombi ✓
**VPN:** wireguard, openvpn ✓
**File Sync:** nextcloud, syncthing ✓

**Missing ports:** ~10 services need port config

### Recent Changes (v3.6.3-dev.07)
- ✅ 100% test pass rate achieved
- ✅ P0 complete (4/4 items)
- ✅ ASCII art tests fixed
- ✅ ESC/q key coverage added
- ✅ Smart port detection designed

---

## ✅ COMPLETED (Archive - Chronological)

### 2026-01-02: P0 Complete - 100% Test Pass Rate
**Commits:** 186ae73, c8c29ee

1. **ASCII Art Tests Fixed**
   - Rewrote test-ascii-styles.sh with expect automation
   - Created generate-with-style.exp helper
   - Fixed validation (rendering code vs heredoc markers)
   - Result: 0/6 → 6/6 tests passing

2. **delete-template Integration**
   - Discovered direct argument support
   - Simplified test: `echo "Y" | delete-template test3`
   - Result: Test now passes

3. **MOTD Protection Tests**
   - Verified existing implementation
   - Tests in run-tests.sh lines 595-615
   - Result: Already working correctly

4. **ESC/q Key Coverage**
   - Created test-esc-quit.exp
   - Tests 3 menus (homelab, list-templates, delete-template)
   - Result: Quit functionality validated

5. **Test Infrastructure**
   - Skip helper scripts in auto-test loop
   - Test count: 42 → 46 tests
   - All expect scripts properly integrated

6. **Documentation**
   - AUDIT_REPORT.md (400+ lines)
   - Smart port detection design
   - Session summary
   - Priority matrix (P0-P3)

### 2025-12: Arrow Navigation Phase (v3.6.3-dev.02)
**Commit:** 12fc46e

- Converted all 15 menus to arrow navigation
- Added choose_menu wrapper to lib/menu-helpers.sh
- bulk-generate-motd: 5 menus converted
- deploy-motd, generate-motd, delete-template, cleanup-keys: all converted
- Tests: 40/44 passing (91%)

### 2025-12: Git Workflow Improvements
**Commits:** 62ceedb, 2fb1f7e

- Auto-bump VERSION via git hook
- prepare-commit-msg in .husky/_/
- Conventional commits without auto-commit
- CRITICAL RULE: Always ask permission before commit

### 2025-11: MOTD Protection System (v3.6.2)
- HLT markers in templates
- Deploy protection: Replace/Append/Cancel
- Undeploy protection: Only remove HLT MOTDs
- Backup before replacing non-HLT MOTDs

### 2025-11: Bulk Operations (v3.6.1)
- undeploy-motd --all
- list-templates --status (deployment tracking)
- list-templates --view (interactive preview)
- Deployment logging system

### 2025-11: Developer Tools (v3.6.1)
- sync-dev.sh (quick workspace sync)
- Auto-bump patch after dev.09
- Enhanced edit-hosts (interactive wizard)
- Welcome banner with special occasions

---

## 🎯 NEXT SESSION: Testing-TODO Implementation

1. **Read:** [TESTING-TODO.md](TESTING-TODO.md) (Complete testing rebuild plan)
2. **Current Phase:** Fase 1 - Testing Audit (1 hour)
3. **Phases 2-6:** Framework setup → Test cases → Fixes → CI/CD (15 hours total)
4. **After TESTING-TODO:** Resume P1/P2 feature work

**Quick Start:**
```bash
cd .test-env && docker compose up -d
# See: TESTING-TODO.md for Phase 1 audit instructions
```

**Commands:**
```bash
# Start test environment
cd .test-env && docker compose up -d

# Run tests
docker compose exec -T testhost bash /workspace/.test-env/run-tests.sh

# Run service preset test
docker compose exec -T testhost bash /workspace/.test-env/test-service-presets-extended.sh

# Edit generate-motd
vim bin/generate-motd
```

**Files to Edit:**
- `bin/generate-motd` (add missing ports to case statements)
- Test with service-presets-extended.sh until 48/48 pass

---

## 📖 Key Documentation

- **README.md** - User guide, 60+ service presets
- **QUICKSTART.md** - 60-second setup
- **CHANGELOG.md** - Version history
- **.github/copilot-instructions.md** - Development workflow
- **TODO_SESSION_SUMMARY.md** - Detailed session notes
- **.design/smart-port-detection.md** - P2 feature design

---

**Repository:** github.com/JBakers/homelab-tools
**Branch:** develop
**Clean State:** ✓ All changes committed
**Ready:** P1 work can begin immediately
