# File Audit Report - Homelab Tools
**Date:** 2026-01-02
**Branches Audited:** main (31 files) vs develop (40 files)

---

## 📊 SUMMARY

**Obsolete Files:** 2 (in main only)
**Develop Status:** ✓ Clean (no obsolete files)
**New Features:** 3 (awaiting release)

---

## 🔴 OBSOLETE FILES (Main Branch Only)

### 1. `bump-version.sh`
**Location:** main branch only
**Status:** ❌ Obsolete
**Replaced by:** `bump-dev.sh` (in develop)
**Reason:** Centralized version system (VERSION file + lib/version.sh)

### 2. `update-version.sh`
**Location:** main branch only
**Status:** ❌ Obsolete
**Replaced by:** VERSION file + lib/version.sh
**Reason:** Single source of truth for version management

**Develop branch:** ✓ Already clean (obsolete files removed during development)

---

## ✅ DEV-ONLY FILES (Correct - 6 files)

Intentionally excluded from main per `.github/copilot-instructions.md`:

1. `.github/copilot-instructions.md` - AI workflow
2. `.design/smart-port-detection.md` - P2 feature design
3. `TODO.md` + `TODO_SESSION_SUMMARY.md` - Task tracking
4. `TESTING_CHECKLIST.md` + `TEST_SUMMARY.txt` - Test docs
5. `bump-dev.sh`, `sync-dev.sh`, `merge-to-main.sh` - Dev tools

---

## ⚠️ NEW FEATURES (Awaiting Release - 3 files)

Files in develop that will be merged to main in next release:

1. **`bin/undeploy-motd`** - Remove MOTDs from hosts (v3.6.1)
2. **`lib/constants.sh`** - Shared constants (v3.6.0-dev.14)
3. **`lib/version.sh`** - Centralized version management (v3.6.0-dev.9)

---

## 🎯 RECOMMENDATIONS

### Develop Branch (Current)
✅ **No action needed** - Already clean

### Main Branch (Next Release)
- Remove: `bump-version.sh`, `update-version.sh`
- Add: `undeploy-motd`, `constants.sh`, `version.sh`
- Test: Full install/uninstall on clean system
- Tag: v3.7.0 or v4.0.0

---

## 📋 FULL FILE COMPARISON

### Main Only (2 obsolete)
```
bump-version.sh      ❌ OBSOLETE
update-version.sh    ❌ OBSOLETE
```

### Develop Only (9 files)
```
.design/smart-port-detection.md    ✅ Dev-only
.github/copilot-instructions.md    ✅ Dev-only
TESTING_CHECKLIST.md               ✅ Dev-only
TEST_SUMMARY.txt                   ✅ Dev-only
TODO.md                            ✅ Dev-only
TODO_SESSION_SUMMARY.md            ✅ Dev-only
bin/undeploy-motd                  ⚠️ NEW (v3.6.1)
bump-dev.sh                        ✅ Dev-only
lib/constants.sh                   ⚠️ NEW (v3.6.0-dev.14)
lib/version.sh                     ⚠️ NEW (v3.6.0-dev.9)
merge-to-main.sh                   ✅ Dev-only
sync-dev.sh                        ✅ Dev-only
```

### Both Branches (29 files)
All production code + documentation present in both

---

**Audit Result:** Develop branch is clean ✅ | Main needs cleanup at next release
