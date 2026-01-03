# Quick Start Guide - Test Suite

## 🚀 Start Testing (3 Commands)

```bash
# 1. Navigate to test directory
cd /home/jochem/Workspace/homelab-tools/.test-env

# 2. Start Docker environment
docker compose up -d

# 3. Run tests
docker compose exec -T testhost bash /workspace/.test-env/run-tests.sh
```

**Expected Result**: `✓✓✓ ALL TESTS PASSED! 🎉` (41/42 passing)

---

## 📊 View Results

```bash
# Summary only (last 30 lines)
docker compose exec -T testhost bash /workspace/.test-env/run-tests.sh 2>&1 | tail -30

# Find failures
docker compose exec -T testhost bash /workspace/.test-env/run-tests.sh 2>&1 | grep "\[FAIL\]"

# Count passed tests
docker compose exec -T testhost bash /workspace/.test-env/run-tests.sh 2>&1 | grep "PASSED:"
```

---

## 🔍 Debug Failures

```bash
# View specific test log
cat results/logs/deploy-motd.log
cat results/logs/cli-options.log
cat results/logs/list-templates.log

# Interactive container shell
docker compose exec testhost bash

# Manual test run
docker compose exec testhost /opt/homelab-tools/bin/generate-motd test
```

---

## 🔄 Rebuild Environment

```bash
# Stop and remove containers
docker compose down

# Rebuild with latest changes
docker compose up -d --build

# Verify
docker compose ps
```

---

## 📝 Current Status (v3.6.2-dev.09)

- **Total Tests**: 42
- **Passing**: 41 (98%)
- **Failing**: 0
- **Skipped**: 1 (expected)

### Test Categories
✅ Static Tests (4/4)
✅ Install (4/4)
✅ Menu Navigation (10/10)
✅ Functional (5/5)
✅ SSH/Deploy (3/3)
✅ Edge Cases (2/2)
✅ Uninstall (2/2)
✅ CLI Options (33/33)
⚠️  Additional Functional (6/7) - 1 expected skip
✅ Service Presets (1/1)
✅ Full Menu (4/4)

---

## 🐛 Known Issues

**None! All tests passing.**

Previous issues (all fixed):
- ~~deploy-motd hanging~~ → Fixed with `echo "1"` for MOTD protection
- ~~list-templates hanging~~ → Fixed with `echo "q"` for menu exit
- ~~CLI options syntax error~~ → Fixed extra `)` in commands array

---

## 📋 Test Checklist

Before committing changes, verify:
- [ ] All tests pass (`41/42 PASSED`)
- [ ] No new failures introduced
- [ ] Docker environment builds cleanly
- [ ] Expect scripts don't timeout
- [ ] Log files show expected output

---

## 🎯 Next Actions

1. **If tests fail**: Debug using logs in `results/logs/`
2. **If tests pass**: Commit with `./bump-dev.sh "message"`
3. **Before release**: Run full test suite one final time

---

**Last Updated**: 2026-01-01
**Test Suite Version**: 3.6.2-dev.09
**Status**: ✅ Production Ready
