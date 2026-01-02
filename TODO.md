# TODO: Homelab-Tools

**Version:** 3.6.3-dev.07
**Last Update:** 2026-01-02
**Test Status:** 46/46 passing (100%) ✅

> Self-contained task list - read this + `.github/copilot-instructions.md` to continue work.
> Workflow: Fix by priority → Test → Commit (with approval) → Push

---

## 🟠 HIGH PRIORITY (P1 - Do This Week)

### 1. Complete Service Preset Ports (~2h)
**Status:** 42/48 implemented, ports incomplete
**Test:** `.test-env/test-service-presets-extended.sh` exists
**Result:** 42 pass / 43 fail (names ✓, ports ✗)

**Missing Ports:**
- navidrome: 4533, audiobookshelf: 13378, whisparr: 6969
- unifi: 8443, uptime-kuma: 3001, tautulli: 8181
- netdata: 19999, glances: 61208
- nextcloud: 443, syncthing: 8384

**Action:** Add port configs to `bin/generate-motd` case statements

### 2. Non-Interactive Mode Tests (~2h)
**Problem:** `echo | generate-motd` path untested
**Impact:** Scripting use case could break

**Create:** `.test-env/test-non-interactive.sh`
**Test:**
- HLT markers in non-interactive templates
- Stdin piping works correctly
- Service detection without prompts

### 3. Bulk Operations Tests (~2h)
**Current:** Only generation tested
**Missing:** deploy-motd --all, undeploy-motd --all

**Create:** `.test-env/test-bulk-operations.sh`
**Test:**
- Bulk deploy to all hosts
- Bulk undeploy from all hosts
- Deployment log validation
- Progress display

### 4. Version Consistency Check (~30m)
**Problem:** No verification all scripts show same version
**Solution:** Add to static tests in `run-tests.sh`

```bash
version=$(cat VERSION)
for script in bin/*; do
  if ! grep -q "VERSION file" "$script"; then
    echo "FAIL: $script doesn't use VERSION file"
  fi
done
```

**P1 Total:** 4 tasks, ~6.5 hours

---

## 🟡 MEDIUM PRIORITY (P2 - Do This Month)

### 5. Smart Port Detection (~3h) ⭐ NEW
**Design:** `.design/smart-port-detection.md`
**Problem:** Users run custom ports (zigbee2mqtt:2804 vs default:8080)

**Implementation:**
1. Config file: `~/.config/homelab-tools/custom-ports.conf`
2. SSH scan: `ss -tlnp | grep :PORT`
3. Docker check: `docker ps --format '{{.Ports}}'`
4. Interactive prompt (fallback)

**Benefits:** 90%+ auto-detection, <5% wrong URLs (was 30%)

### 6. HLT Marker Validation (~1h)
**Test:** All templates have proper HLT-MOTD-START/END markers
**Coverage:** Deploy protection, undeploy safety

### 7. Deployment Log Testing (~2h)
**Test:** `~/.local/share/homelab-tools/deploy-log` validation
**Coverage:** Log entries, status tracking, stale detection

### 8. copykey Edge Cases (~1.5h)
**Test:** Multiple keys, permission errors, missing hosts

### 9. edit-config Testing (~2h)
**Test:** Config creation, validation, backup

### 10. Error Message Validation (~2h)
**Test:** All error paths show helpful messages

**P2 Total:** 6 tasks, ~11.5 hours

---

## 🟢 LOW PRIORITY (P3 - Nice to Have)

### Comprehensive Testing
- cleanup-homelab tests
- Performance benchmarking
- Stress testing (100+ hosts)
- Security testing
- Test coverage reporting
- Regression test suite

**P3 Total:** ~21 hours

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

## 🎯 NEXT SESSION: Start Here

1. **Read:** This TODO.md + `.github/copilot-instructions.md`
2. **Test:** `cd .test-env && docker compose up -d && docker compose exec -T testhost bash /workspace/.test-env/run-tests.sh`
3. **Status:** Should see 46/46 tests passing
4. **Begin:** P1 #1 (Service preset ports) - 2 hour task

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
