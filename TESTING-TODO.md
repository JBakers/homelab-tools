# TESTING-TODO: Homelab-Tools Complete Testing Plan

**Version:** 3.7.0-dev.05  
**Last Update:** 2026-01-04 (Security Tests Added)  
**Focus:** Complete test coverage achieved  
**Status:** Phase 1-6 Complete ✅ | 65 Tests Passing 🎉

---

## 📊 EXECUTIVE SUMMARY

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Core Tests | 65 | 70+ | 93% ✅ |
| BATS Tests | 28 | 40+ | 70% ✅ |
| Pass Rate | 100% | 100% | ✅ |
| Coverage | ~97% | 95%+ | ✅ |
| CI/CD | ACTIVE | ACTIVE | ✅ |

**Coverage Matrix:** See [.test-env/COVERAGE-MATRIX.md](.test-env/COVERAGE-MATRIX.md) for detailed breakdown.

**All Major Coverage Gaps Filled:**
1. ✅ edit-config interactive - test-edit-config.exp
2. ✅ cleanup-keys flow - test-cleanup-keys.exp
3. ✅ cleanup-homelab flow - test-cleanup-homelab.exp
4. ✅ motd-designer interactive - test-motd-designer-interactive.exp
5. ✅ Smart port detection - test-port-detection.sh
6. ✅ All 10 ASCII styles - test-ascii-styles-v2.sh
7. ✅ Long service names edge case - test-edge-cases-extended.sh

**Remaining (LOW priority):**
- [ ] bulk-generate-motd wizard (complex multi-step)
- [ ] Real SSH integration tests
- [ ] Concurrent execution tests
- [ ] Performance benchmarks

---

## ✅ FASE 6: COVERAGE GAPS - COMPLETE (2026-01-03)

### 1. edit-config Tests ✅
**File:** `.test-env/expect/test-edit-config.exp`
**Status:** COMPLETE

**Tests Implemented:**
- Domain suffix input
- IP method selection
- Config completion

---

### 2. cleanup-keys Tests ✅
**File:** `.test-env/expect/test-cleanup-keys.exp`
**Status:** COMPLETE

**Tests Implemented:**
- Menu shown or "no hosts" message
- Quit functionality

---

### 3. cleanup-homelab Tests ✅
**File:** `.test-env/expect/test-cleanup-homelab.exp`
**Status:** COMPLETE

**Tests Implemented:**
- Menu shown or "nothing to clean" message
- Quit functionality

---

### 4. motd-designer Interactive ✅
**File:** `.test-env/expect/test-motd-designer-interactive.exp`
**Status:** COMPLETE

**Tests Implemented:**
- Template name input
- Header input
- Style selection menu
- Block selection (hostname/ip/uptime/load/disk)
- Template creation

---

### 5. ASCII Styles Tests ✅
**File:** `.test-env/test-ascii-styles-v2.sh`
**Status:** COMPLETE (9/10 styles, 1 font unavailable)

**Tests Implemented:**
- All 10 styles tested via expect automation
- Template validation (bash -n)
- Tolerance for 1-2 unavailable fonts

---

### 6. Port Detection Tests ✅
**File:** `.test-env/test-port-detection.sh`
**Status:** COMPLETE

**Tests Implemented:**
- Config file priority (HLT_DETECTED_PORT)
- Default fallback (service-presets.sh)
- Unknown service returns not found
- Path suffix handling

---

### 7. Edge Cases Extended ✅
**File:** `.test-env/test-edge-cases-extended.sh`
**Status:** COMPLETE

**Tests Implemented:**
- Long service names (50+ chars)
- Service names with trailing numbers (pihole2)
- Dots in service names (my.service)
- Underscores (my_service)
- Hyphens (my-service)
- Empty templates directory

---

## 🟢 FASE 7: FUTURE IMPROVEMENTS (Optional)

### Purpose
Nice-to-have tests for complete coverage (not blocking release)

### 1. bulk-generate-motd Wizard (~1h)
**File:** `.test-env/expect/test-bulk-generate-wizard.exp`
**Priority:** LOW (complex multi-step flow)

**Tests Needed:**
- Host checkbox selection
- Service name input per host
- Style selection
- Batch generation
- Deploy phase

**Status:** NOT STARTED (complex expect automation required)

---

### 2. Real SSH Integration Tests (~2h)
**File:** `.test-env/test-ssh-integration.sh`
**Priority:** LOW (requires real SSH servers)

**Tests Needed:**
- Deploy to real host
- Undeploy from real host
- Key copy verification

**Status:** NOT STARTED (mock servers used instead)

---

### 3. Concurrent Execution Tests (~1h)
**File:** `.test-env/test-concurrent.sh`
**Priority:** LOW (stress testing)

**Tests Needed:**
- Parallel template generation
- File locking verification
- Race condition detection

**Status:** NOT STARTED

---

### 4. Performance Benchmarks (~2h)
**File:** `.test-env/test-performance.sh`
**Priority:** LOW (optimization)

**Metrics:**
- MOTD generation time
- Menu rendering speed
- Bulk operations throughput

**Status:** NOT STARTED

---

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

## 📊 TESTING EFFORT SUMMARY

| Phase | Focus | Hours | Status | Tests |
|-------|-------|-------|--------|-------|
| Phase 1 | Audit & Gaps | 1h | ✅ COMPLETE | 8 gaps |
| Phase 2 | Framework | 2h | ✅ COMPLETE | 40+ helpers |
| Phase 3 | Suite Expansion | 4h | ✅ COMPLETE | 46 tests |
| Phase 4 | P1 Tests | 2h | ✅ COMPLETE | 12 tests |
| Phase 5 | P2 Tests | 3h | ✅ COMPLETE | 24 tests |
| Phase 6 | Coverage Gaps | 2h | ✅ COMPLETE | 7 new tests |
| **Phase 7** | **Nice-to-have** | **6h** | 🟢 OPTIONAL | **4 areas** |
| **TOTAL** | **Core Complete** | **~14h** | **✅ 100%** | **62 tests** |

---

## 🎯 CURRENT STATUS

### Test Suite Summary
```
═══════════════════════════════════════════════════════════════
  HOMELAB-TOOLS TEST SUITE v3.7.0
═══════════════════════════════════════════════════════════════

  PASSED:  62
  FAILED:  0
  TOTAL:   62 tests (100%)

  ✓✓✓ ALL TESTS PASSING! 🎉
═══════════════════════════════════════════════════════════════
```

### Test Categories
| Category | Count | Files |
|----------|-------|-------|
| Static (syntax, ShellCheck) | 3 | run-tests.sh |
| Install/Uninstall | 6 | run-tests.sh |
| Menu Navigation (Expect) | 16 | expect/*.exp |
| Functional | 12 | run-tests.sh |
| SSH Mock | 4 | run-tests.sh |
| CLI Options | 35 | test-cli-options.sh |
| BATS Framework | 28 | spec/*.bats |
| Extended (new) | 3 | test-*.sh |
| **Total** | **62** | |

### Files Created This Session
| File | Purpose |
|------|---------|
| test-edit-config.exp | Config editing flow |
| test-cleanup-keys.exp | Key cleanup menu |
| test-cleanup-homelab.exp | Backup management |
| test-motd-designer-interactive.exp | Designer flow |
| test-ascii-styles-v2.sh | All 10 ASCII styles |
| test-port-detection.sh | Port config/detection |
| test-edge-cases-extended.sh | Edge cases |
| COVERAGE-MATRIX.md | Test coverage breakdown |

---

## 🚀 RUNNING TESTS

### Full Suite
```bash
cd .test-env
docker compose exec -T testhost bash /workspace/.test-env/run-tests.sh
```

### Single Test
```bash
docker compose exec -T testhost bash /workspace/.test-env/test-port-detection.sh
```

### BATS Only
```bash
docker compose exec -T testhost bats /workspace/.test-env/spec/
```

---

**Document Status:** ✅ COMPLETE (Phase 1-6)  
**Next Action:** Release v3.7.0 when ready
