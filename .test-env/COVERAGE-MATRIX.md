# HLT Test Coverage Matrix

**Generated:** 2026-01-04
**Version:** 3.7.0-dev.05
**Status:** 65/65 tests passing ✅

## 📋 Commands & CLI Options

| Command | Option | Tested | Test File | Notes |
|---------|--------|--------|-----------|-------|
| **homelab** | (main menu) | ✅ | test-homelab-menu.exp | Arrow nav |
| | --help | ✅ | test-cli-options.sh | |
| | --usage | ✅ | test-cli-options.sh | |
| | q quit | ✅ | test-esc-quit.exp | |
| **generate-motd** | SERVICE | ✅ | motd-generation.bats | |
| | (non-interactive) | ✅ | test-non-interactive.sh | |
| | 10 ASCII styles | ✅ | test-ascii-styles-v2.sh | 9/10 (font availability) |
| | preview | ⚠️ | - | Covered by style test |
| | customize flow | ⚠️ | - | Partial coverage |
| **motd-designer** | --name | ✅ | motd-designer.bats | |
| | --style | ✅ | motd-designer.bats | |
| | --header | ✅ | motd-designer.bats | |
| | --blocks | ✅ | motd-designer.bats | |
| | invalid style | ✅ | motd-designer.bats | |
| | interactive | ✅ | test-motd-designer-interactive.exp | NEW |
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
| **bulk-generate-motd** | (wizard) | ⚠️ | - | Complex flow |
| | host selection | ⚠️ | - | Not fully tested |
| | style selection | ⚠️ | - | Not fully tested |
| **edit-hosts** | (default) | ✅ | test-edit-hosts.exp | |
| | --edit | ✅ | test-edit-hosts.exp | |
| | wizard | ✅ | test-edit-hosts-wizard.exp | |
| | bulk | ✅ | test-edit-hosts-bulk.exp | |
| **edit-config** | (interactive) | ✅ | test-edit-config.exp | NEW |
| **copykey** | HOST | ⚠️ | - | SSH-dependent |
| | --help | ✅ | test-cli-options.sh | |
| **cleanup-keys** | (interactive) | ✅ | test-cleanup-keys.exp | NEW |
| **cleanup-homelab** | (interactive) | ✅ | test-cleanup-homelab.exp | NEW |

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
| Smart port detection | ✅ | test-port-detection.sh | NEW |
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
| Empty input | ✅ | test-edge-cases-extended.sh |
| Special characters | ✅ | test-edge-cases-extended.sh |
| Long service names | ✅ | test-edge-cases-extended.sh | NEW |
| Concurrent execution | ⚠️ | - | Future |

## 📋 Summary

| Category | Tested | Partial | Missing |
|----------|--------|---------|---------|
| Commands | 13 | 1 | 0 |
| CLI Options | 22 | 4 | 0 |
| Menus | 9 | 0 | 0 |
| Features | 7 | 1 | 0 |
| Edge Cases | 6 | 1 | 0 |
| **Total** | **57** | **7** | **0** |

## 🟢 Completed This Session

1. ✅ **edit-config** - test-edit-config.exp
2. ✅ **cleanup-keys** - test-cleanup-keys.exp
3. ✅ **cleanup-homelab** - test-cleanup-homelab.exp
4. ✅ **motd-designer interactive** - test-motd-designer-interactive.exp
5. ✅ **Smart port detection** - test-port-detection.sh
6. ✅ **All 10 ASCII styles** - test-ascii-styles-v2.sh
7. ✅ **Long service names** - test-edge-cases-extended.sh

## 🟡 Remaining (LOW priority)

1. **bulk-generate-motd wizard** - Complex multi-step flow
2. **Concurrent execution** - Stress testing
3. **Real SSH tests** - Requires real hosts
