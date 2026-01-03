# TESTING-TODO: Homelab-Tools Complete Testing Plan

**Version:** 3.7.0-dev.02  
**Last Update:** 2026-01-03 (Coverage Audit Complete)  
**Focus:** Complete test-env with 100% coverage  
**Status:** Phase 1-5 Complete ✅ | Phase 6 IN PROGRESS 🚀

---

## 📊 EXECUTIVE SUMMARY

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Core Tests | 55 | 70+ | 79% |
| BATS Tests | 28 | 40+ | 70% |
| Pass Rate | 100% | 100% | ✅ |
| Coverage | ~85% | 95%+ | 🔄 |
| CI/CD | ACTIVE | ACTIVE | ✅ |

**Coverage Matrix:** See [COVERAGE-MATRIX.md](COVERAGE-MATRIX.md) for detailed breakdown.

**Missing Coverage (10 items):**
1. edit-config interactive
2. cleanup-keys flow
3. cleanup-homelab flow
4. bulk-generate-motd wizard
5. generate-motd preview/customize
6. motd-designer interactive
7. Smart port detection
8. New ASCII styles (4 of 10 untested)
9. Long service names edge case
10. Concurrent execution

---

## 🔴 FASE 6: COVERAGE GAPS (Current Priority)

### 1. edit-config Tests (~30m)
**File:** `.test-env/expect/test-edit-config.exp`
**Priority:** HIGH (no tests exist)

**Tests Needed:**
- Domain suffix input validation
- IP method selection (hostname/ip)
- Config file creation
- Config file update (overwrites)

---

### 2. cleanup-keys Tests (~30m)
**File:** `.test-env/expect/test-cleanup-keys.exp`
**Priority:** HIGH (no tests exist)

**Tests Needed:**
- Host selection menu
- Confirmation dialog
- Key removal verification

---

### 3. cleanup-homelab Tests (~30m)
**File:** `.test-env/expect/test-cleanup-homelab.exp`
**Priority:** HIGH (no tests exist)

**Tests Needed:**
- Backup listing
- Backup deletion
- Orphan detection

---

### 4. bulk-generate-motd Wizard (~1h)
**File:** `.test-env/expect/test-bulk-generate-wizard.exp`
**Priority:** MEDIUM (complex flow)

**Tests Needed:**
- Host checkbox selection
- Service name input per host
- Style selection
- Batch generation
- Deploy phase

---

### 5. generate-motd Preview/Customize (~30m)
**File:** `.test-env/expect/test-generate-preview.exp`
**Priority:** MEDIUM

**Tests Needed:**
- Preview all styles option
- Customize flow (service name, description, port)
- Cancel mid-flow

---

### 6. motd-designer Interactive (~30m)
**File:** `.test-env/expect/test-motd-designer-interactive.exp`
**Priority:** MEDIUM (CLI tested, interactive not)

**Tests Needed:**
- Template name input
- Header input
- Style selection menu
- Block selection (hostname/ip/uptime/load/disk)

---

### 7. New ASCII Styles Tests (~30m)
**File:** `.test-env/test-ascii-styles-v2.sh`
**Priority:** LOW (existing tests cover 6/10)

**Tests Needed:**
- emboss style rendering
- pagga style rendering
- trek style rendering
- term style rendering

---

### 8. Smart Port Detection (~1h)
**File:** `.test-env/test-port-detection.sh`
**Priority:** LOW (lib not yet integrated in commands)

**Tests Needed:**
- Config file priority
- Docker detection mock
- Listening port detection mock
- Fallback to defaults

---

### 9. Edge Cases (~30m)
**File:** `.test-env/test-edge-cases-extended.sh`
**Priority:** LOW

**Tests Needed:**
- Very long service names (50+ chars)
- Service names with numbers (pihole2, arr3)
- Unicode in descriptions
- Empty template directory

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
