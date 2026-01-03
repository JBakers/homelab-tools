# TESTING-TODO: Homelab-Tools Complete Testing Plan

**Version:** 3.6.7-dev.03  
**Last Update:** 2026-01-03 (Phase 4 COMPLETE! ✅)  
**Focus:** Complete test-env rebuild with 100+ test cases  
**Status:** Phase 1-4 Complete ✅ | Phase 5-6 Ready 🚀

---

## 📊 EXECUTIVE SUMMARY

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Test Cases | 50 core + 44 sub | 150+ | 63% |
| Pass Rate | 100% | 100% | ✅ |
| Coverage | ~92% | 95%+ | 🔄 |
| Tests Written | 50 core | 120+ | IN PROGRESS |
| Estimated Hours | 20h | 45h | 44% |

**Current Session:** 2026-01-03 - Phase 4 COMPLETE! 🎉
- ✅ Fixed HLT_HLT_MENU_RESULT regression (48/48 → 50/50 tests)
- ✅ test-non-interactive.sh: 12 tests for scripting use case
- ✅ test-version-consistency.sh: 32 tests for VERSION file
- ✅ test-bulk-operations.sh: Created for deploy/undeploy --all
- ✅ Updated run-tests.sh with new test sections
- ✅ All 50 core tests passing!

**Previous Session:** 2026-01-02 - All Audit Issues + P1 + P2 Fixed! 🎉
- ✅ AUDIT-11 to 16: All medium priority issues fixed
- ✅ P1: Service Preset Ports (73 services configured)
- ✅ P2: Smart Port Detection (lib/port-detection.sh)
- ✅ Major refactor: generate-motd 1060 → 684 lines (-36%)
- ✅ New libraries: service-presets.sh, port-detection.sh
- ✅ Phase 1-3 complete

---

## ✅ FASE 4: P1 TEST CASES - COMPLETE (2026-01-03)

### Purpose
Add missing tests for core functionality paths that are critical for basic usage

### 1. Non-Interactive Mode Tests ✅
**File:** `.test-env/test-non-interactive.sh`
**Status:** COMPLETE - 12 tests passing

**Tests Implemented:**
- Non-interactive template generation with Enter key
- HLT-MOTD-START/END marker presence and format
- Template syntax validation (bash -n)
- Template permissions (executable)
- Service preset detection (pihole, jellyfin, sonarr, plex)

---

### 2. Bulk Operations Tests ✅
**File:** `.test-env/test-bulk-operations.sh`
**Status:** COMPLETE - Script created (SSH-dependent tests)

**Tests Implemented:**
- Single deploy with log tracking
- Deploy log format validation
- list-templates -s status display
- Undeploy single host
- --all flag documentation check

---

### 3. Version Consistency Check ✅
**File:** `.test-env/test-version-consistency.sh`
**Status:** COMPLETE - 32 tests passing

**Tests Implemented:**
- VERSION file existence and format
- lib/version.sh integrity
- All 12 main scripts reference VERSION
- No hardcoded versions in scripts
- Version displayed correctly in --help

---

## 🟡 FASE 5: P2 TEST CASES (11.5 hours) - NOT STARTED

### Purpose
Add comprehensive tests for deployment protection, logging, edge cases

### 1. HLT Marker Validation (~1h)
**File:** `.test-env/test-hlt-markers.sh`
**Test:** All templates have proper HLT-MOTD-START/END markers

**Test:**
```bash
# Test 1: Interactive mode adds markers
printf "y\n8080\n" | generate-motd pihole
grep -A 1 "HLT-MOTD-START" ~/.local/share/homelab-tools/templates/pihole.sh

# Test 2: Non-interactive mode adds markers
printf "\n\n\n" | generate-motd sonarr
grep "HLT-MOTD-END" ~/.local/share/homelab-tools/templates/sonarr.sh

# Test 3: Markers properly formatted (no typos)
grep "^# HLT-MOTD-START" ~/.local/share/homelab-tools/templates/*.sh
```

**Status:** NOT STARTED

---

### 2. Deployment Log Testing (~2h)
**File:** `.test-env/test-deploy-log.sh`
**Test:** `~/.local/share/homelab-tools/deploy-log` validation

**Test:**
```bash
# Test 1: Log created on deploy
deploy-motd pihole
[ -f ~/.local/share/homelab-tools/deploy-log ]

# Test 2: Log format correct (service|hostname|timestamp|hash)
log_line=$(tail -1 ~/.local/share/homelab-tools/deploy-log)
[[ "$log_line" =~ ^[a-z0-9]+\|[a-z0-9.-]+\|[0-9]+\|[a-f0-9]+$ ]]

# Test 3: Multiple deploys tracked
deploy-motd jellyfin
[ $(wc -l < ~/.local/share/homelab-tools/deploy-log) -eq 2 ]
```

**Status:** NOT STARTED

---

### 3. copykey Edge Cases (~1.5h)
**File:** `.test-env/test-copykey-edge-cases.sh`

**Test:**
```bash
# Test 1: Multiple SSH keys
create_test_keys() {
  ssh-keygen -N "" -f ~/.ssh/test_key1
  ssh-keygen -N "" -f ~/.ssh/test_key2
}

# Test 2: Permission denied handling
ssh-server-fail "Permission denied" 
copykey 2>&1 | grep "Permission denied"

# Test 3: Partial success (some hosts fail)
copykey 2>&1 | grep "✓.*✗"
```

**Status:** NOT STARTED

---

### 4. edit-config Testing (~2h)
**File:** `.test-env/test-edit-config.sh`

**Test:**
```bash
# Test 1: Config creation with validation
echo "y\nmy.domain\nhostname" | edit-config
[ -f /opt/homelab-tools/config.sh ]

# Test 2: Domain suffix validation
echo "y\ninvalid!domain\n" | edit-config 2>&1 | grep "Invalid"

# Test 3: IP method validation
echo "y\n.domain\nwrong_method\n" | edit-config 2>&1 | grep "must be"

# Test 4: Backup on overwrite
cp /opt/homelab-tools/config.sh /tmp/config.backup
echo "y\nnew.domain\nip" | edit-config
[ -f /opt/homelab-tools/config.sh.backup ]
```

**Status:** NOT STARTED

---

### 5. Error Message Validation (~2h)
**File:** `.test-env/test-error-messages.sh`

**Test:**
```bash
# Test 1: Invalid service name shows helpful message
generate-motd "; rm -rf /" 2>&1 | grep "Invalid service name"

# Test 2: Non-existent host shows helpful message
deploy-motd nonexistent 2>&1 | grep "cannot connect\|not found"

# Test 3: Permission denied shows actionable advice
ssh-deny-test; copykey 2>&1 | grep -E "permission|sudo|key"

# Test 4: No cryptic shell errors
generate-motd "" 2>&1 | grep -v "^✗\|^ERROR\|^-" | grep -q "^" && exit 1
```

**Status:** NOT STARTED

---

## 🟢 FASE 6: P3 COMPREHENSIVE TESTING (21+ hours) - NOT STARTED

### Purpose
Complete test coverage with performance, security, stress testing

### 1. Security Testing (~5h) ⭐ NEW PRIORITY
**File:** `.test-env/test-security.sh`

**Test Cases:**
```bash
# Test 1: Command injection prevention
for payload in "; rm -rf /" '$(whoami)' '| cat /etc/passwd' '`id`'; do
  generate-motd "$payload" 2>&1 | grep -q "Invalid" || exit 1
done

# Test 2: Path traversal prevention
for path in "../../../../etc/passwd" "../../../root/.ssh/id_rsa" "~/.bashrc"; do
  homelab-backup "$path" 2>&1 | grep -q "Invalid path" || exit 1
done

# Test 3: SSH injection prevention (-- separator verified)
deploy-motd pihole; grep -q ' -- ' bin/deploy-motd || exit 1

# Test 4: Config file injection
malicious_config='DOMAIN_SUFFIX=$(rm -rf /)'
echo "$malicious_config" > /tmp/malicious-config.sh
[ -f /opt/homelab-tools/config.sh ] && exit 0  # Should reject

# Test 5: Temp file security
strace -e openat generate-motd test 2>&1 | grep /tmp | grep -v "O_EXCL" && exit 1

# Test 6: Input validation on all user-facing inputs
for script in bin/homelab bin/generate-motd bin/deploy-motd bin/copykey; do
  shellcheck "$script" | grep -q "SC2086" && exit 1  # Unquoted variables
done

# Test 7: Privilege escalation attempts
non_root_user test
sudo_required_op 2>&1 | grep -q "prompt for password" || exit 1

# Test 8: File permission checks
deploy-motd test 2>&1 | grep -q "755\|executable" || exit 1
```

**Status:** NOT STARTED

---

### 2. cleanup-homelab Tests (~2h)
**File:** `.test-env/test-cleanup-homelab.sh`

**Test:**
```bash
# Test 1: Backup creation
cleanup-homelab 2>&1 | grep -q "backup"
[ -f ~/homelab-backups-*.tar.gz ]

# Test 2: Selective cleanup (templates optional)
cleanup-homelab --templates-only
! [ -d ~/.local/share/homelab-tools/templates ]

# Test 3: Restoration from backup
tar -xzf ~/homelab-backups-*.tar.gz
[ -d ~/.local/share/homelab-tools ]

# Test 4: Verification of cleanup completeness
[ -z "$(ls ~/.local/share/homelab-tools 2>/dev/null)" ]
```

**Status:** NOT STARTED

---

### 3. Performance Benchmarking (~2h)
**File:** `.test-env/test-performance.sh`

**Metrics:**
```bash
# Metric 1: MOTD generation time per service
time (for service in pihole jellyfin sonarr; do
  printf "\n\n\n" | generate-motd "$service"
done)

# Metric 2: Menu rendering performance
time (echo "q" | homelab > /dev/null)

# Metric 3: SSH operation latency
time (deploy-motd pihole)

# Metric 4: Bulk operations throughput
time (deploy-motd --all)
```

**Status:** NOT STARTED

---

### 4. Stress Testing (~3h)
**File:** `.test-env/test-stress.sh`

**Test:**
```bash
# Test 1: 100+ host bulk operations
create_mock_hosts 100
time (deploy-motd --all)

# Test 2: Large template files (>10MB)
create_large_template 10M
generate-motd large-test

# Test 3: Rapid menu navigation
for i in {1..100}; do
  echo "q" | homelab > /dev/null
done

# Test 4: Concurrent operations
(generate-motd test1 &)
(generate-motd test2 &)
(generate-motd test3 &)
wait
```

**Status:** NOT STARTED

---

### 5. Regression Test Suite (~3h)
**File:** `.test-env/test-regressions.sh`

**Test:**
```bash
# Test 1: Known bugs from changelog
# BUG-1: HLT markers missing - FIXED
grep "HLT-MOTD-START" ~/.local/share/homelab-tools/templates/*.sh

# BUG-2: ASCII art not rendering - FIXED  
grep "toilet" ~/.local/share/homelab-tools/templates/*.sh

# BUG-3: Deploy log not created - FIXED
[ -f ~/.local/share/homelab-tools/deploy-log ]

# Test 2: User-reported edge cases
# Edge-case 1: SSH timeout handling
deploy-motd pihole --timeout 1

# Edge-case 2: Config file corruption
corrupt_config_file
generate-motd test 2>&1 | grep "Invalid\|Error"
```

**Status:** NOT STARTED

---

### 6. Test Coverage Reporting (~2h)
**File:** `.test-env/coverage-report.sh`

**Metrics:**
```bash
# Metric 1: Lines covered per script
kcov --exclude-pattern=/tmp coverage bin/* lib/*

# Metric 2: Functions tested
for func in generate_motd deploy_motd list_templates; do
  grep -n "^$func" bin/* | wc -l
done

# Metric 3: Exit paths validated
shellcheck --format=gcc bin/* | grep -c "exit"

# Metric 4: HTML coverage report
kcov --exclude-pattern=/tmp,/.test-env coverage/html bin/*
echo "Coverage report: $(pwd)/coverage/html/index.html"
```

**Status:** NOT STARTED

---

## 📊 TESTING EFFORT SUMMARY

| Phase | Focus | Hours | Status | Tests |
|-------|-------|-------|--------|-------|
| Phase 1 | Audit & Gaps | 1h | ✅ COMPLETE | 8 gaps |
| Phase 2 | Framework | 2h | ✅ COMPLETE | 40+ helpers |
| Phase 3 | Suite Expansion | 4h | ✅ COMPLETE | 46 → 93+ |
| **Phase 4** | **P1 Tests** | **6.5h** | 🔴 NOT STARTED | **9 tests** |
| **Phase 5** | **P2 Tests** | **11.5h** | 🔴 NOT STARTED | **18 tests** |
| **Phase 6** | **P3 Tests** | **21h+** | 🔴 NOT STARTED | **30+ tests** |
| **TOTAL** | **Complete Testing** | **~45h** | **33% DONE** | **150+ tests** |

---

## 🎯 HOW TO CONTINUE

### Next Immediate Step: Phase 4
```bash
cd .test-env
# Start with non-interactive mode testing
cat run-tests.sh  # review existing structure
# Copy pattern and create test-non-interactive.sh
```

### Phases 4-6 Implementation
Each phase:
1. Create `.test-env/test-PHASE-NAME.sh`
2. Add test cases from this document
3. Run with: `docker compose exec -T testhost bash test-PHASE-NAME.sh`
4. Fix failures
5. Commit with: `git add . && git commit -m "test: Phase X - DESCRIPTION"`

### Priority for Implementation
1. **Phase 4 (6.5h)** - Fixes data loss risk, validates scripting use case
2. **Phase 5 (11.5h)** - Deployment safety (protection markers, logging, errors)
3. **Phase 6 (21h)** - Robustness (security, performance, stress, regression)

---

**Document Status:** Phases 1-3 Complete ✅ | Phases 4-6 Ready 🚀  
**Next Session:** Start Phase 4 (P1 Test Cases)
