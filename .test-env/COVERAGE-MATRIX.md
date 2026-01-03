# HLT Test Coverage Matrix

**Generated:** 2026-01-03
**Version:** 3.7.0-dev.02

## 📋 Commands & CLI Options

| Command | Option | Tested | Test File | Notes |
|---------|--------|--------|-----------|-------|
| **homelab** | (main menu) | ✅ | test-homelab-menu.exp | Arrow nav |
| | --help | ✅ | test-cli-options.sh | |
| | --usage | ✅ | test-cli-options.sh | |
| | q quit | ✅ | test-esc-quit.exp | |
| **generate-motd** | SERVICE | ✅ | motd-generation.bats | |
| | (non-interactive) | ✅ | test-non-interactive.sh | |
| | 10 ASCII styles | ⚠️ | test-ascii-styles.sh | Only 6 tested |
| | preview | ❌ | - | Not tested |
| | customize flow | ❌ | - | Not tested |
| **motd-designer** | --name | ✅ | motd-designer.bats | |
| | --style | ✅ | motd-designer.bats | |
| | --header | ✅ | motd-designer.bats | |
| | --blocks | ✅ | motd-designer.bats | |
| | invalid style | ✅ | motd-designer.bats | |
| | interactive | ❌ | - | Not tested |
| **deploy-motd** | HOST | ✅ | run-tests.sh | |
| | --all | ⚠️ | test-bulk-operations.sh | SSH-dependent |
| | protection | ✅ | test-motd-protection.sh | |
| **undeploy-motd** | HOST | ✅ | run-tests.sh | |
| | --all | ⚠️ | test-bulk-operations.sh | SSH-dependent |
| **list-templates** | (default) | ✅ | run-tests.sh | |
| | -s/--status | ✅ | run-tests.sh | |
| | -v/--view | ✅ | test-list-templates-view.exp | |
| | --help | ✅ | test-cli-options.sh | |
| **delete-template** | SERVICE | ✅ | run-tests.sh | |
| | ALL | ✅ | test-delete-template.exp | |
| | --help | ✅ | test-cli-options.sh | |
| **bulk-generate-motd** | (wizard) | ⚠️ | - | Complex menu |
| | host selection | ❌ | - | Not tested |
| | style selection | ❌ | - | Not tested |
| **edit-hosts** | (default) | ✅ | test-edit-hosts.exp | |
| | --edit | ✅ | test-edit-hosts.exp | |
| | wizard | ✅ | test-edit-hosts-wizard.exp | |
| | bulk | ✅ | test-edit-hosts-bulk.exp | |
| **edit-config** | (interactive) | ❌ | - | Not tested |
| **copykey** | HOST | ⚠️ | - | SSH-dependent |
| | --help | ✅ | test-cli-options.sh | |
| **cleanup-keys** | (interactive) | ❌ | - | Not tested |
| **cleanup-homelab** | (interactive) | ❌ | - | Not tested |

## 📋 Menu Navigation

| Menu | Location | Tested | Test File |
|------|----------|--------|-----------|
| Main menu | homelab | ✅ | test-homelab-menu.exp |
| MOTD submenu | homelab → MOTD | ✅ | test-motd-submenu.exp |
| Config submenu | homelab → Config | ✅ | test-config-submenu.exp |
| Backup menu | homelab → Backups | ✅ | test-backup-menu.exp |
| generate-motd style | generate-motd | ⚠️ | test-generate-motd-menu.sh |
| list-templates view | list-templates -v | ✅ | test-list-templates-view.exp |
| delete-template select | delete-template | ✅ | test-delete-template-select.exp |
| edit-hosts menu | edit-hosts | ✅ | test-edit-hosts.exp |

## 📋 Features

| Feature | Tested | Test File | Notes |
|---------|--------|-----------|-------|
| HLT markers | ✅ | test-hlt-markers.sh | |
| Deploy log | ⚠️ | test-deploy-log.sh | SSH-dependent |
| Service presets | ✅ | test-service-presets-extended.sh | 73 services |
| Smart port detection | ❌ | - | Not tested |
| Version consistency | ✅ | test-version-consistency.sh | |
| Error messages | ✅ | test-error-messages.sh | |
| Install verification | ✅ | run-tests.sh | 7 checks |
| Uninstall | ✅ | run-tests.sh | |

## 📋 Edge Cases

| Scenario | Tested | Test File |
|----------|--------|-----------|
| Invalid service name | ✅ | test-invalid-input.sh |
| Invalid hostname | ✅ | test-invalid-input.sh |
| Unreachable host | ✅ | run-tests.sh |
| Empty input | ⚠️ | - | Partial |
| Special characters | ⚠️ | - | Partial |
| Long service names | ❌ | - | Not tested |
| Concurrent execution | ❌ | - | Not tested |

## 📋 Summary

| Category | Tested | Partial | Missing |
|----------|--------|---------|---------|
| Commands | 10 | 3 | 1 |
| CLI Options | 18 | 4 | 6 |
| Menus | 8 | 1 | 0 |
| Features | 6 | 2 | 1 |
| Edge Cases | 3 | 2 | 2 |
| **Total** | **45** | **12** | **10** |

## 🔴 Missing Tests (Priority Order)

1. **edit-config** - Interactive config editing
2. **cleanup-keys** - SSH key cleanup flow
3. **cleanup-homelab** - Backup cleanup flow
4. **bulk-generate-motd** - Full wizard flow
5. **generate-motd preview** - Style preview menu
6. **motd-designer interactive** - Block selection flow
7. **Smart port detection** - lib/port-detection.sh
8. **Long service names** - Edge case
9. **Concurrent execution** - Race conditions
10. **New ASCII styles** - emboss, pagga, trek, term (only 6 of 10 tested)
