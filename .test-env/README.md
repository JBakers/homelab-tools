# Homelab-Tools Test Environment

Complete isolated testing environment using Docker with **100% coverage** of all menus, commands, and options.

## Quick Start

```bash
# Run full test suite (build → test → cleanup)
./test.sh full

# Or step by step:
./test.sh build     # Build containers
./test.sh start     # Start environment
./test.sh shell     # Open shell in test container
./test.sh stop      # Stop containers
./test.sh clean     # Remove everything
```

## Modes

| Mode | Description |
|------|-------------|
| `full` | Build, start, run all tests, stop (default) |
| `build` | Build Docker images only |
| `start` | Start containers in background |
| `stop` | Stop containers |
| `shell` | Open interactive shell in test container |
| `test` | Same as `full` |
| `local` | Run tests locally without Docker |
| `clean` | Remove containers and images |

## Structure

```
.test-env/
├── docker-compose.yml      # Container orchestration (5 mock servers)
├── Dockerfile.testhost     # Main test container
├── Dockerfile.mockserver   # Mock SSH server
├── test.sh                 # Main launcher
├── run-tests.sh            # Test runner (10 sections)
├── complete-integration-test.sh  # Comprehensive 16-phase test
├── test-cli-options.sh     # CLI flags & exit codes (50+ tests)
├── cleanup.sh              # Cleanup script
├── expect/                 # Expect automation scripts (10 scripts)
│   ├── test-homelab-menu.exp
│   ├── test-motd-submenu.exp
│   ├── test-config-submenu.exp    # NEW
│   ├── test-backup-menu.exp       # NEW
│   ├── test-arrow-navigation.exp  # NEW
│   ├── test-edit-hosts.exp
│   ├── test-edit-hosts-wizard.exp # NEW
│   ├── test-edit-hosts-bulk.exp   # NEW
│   ├── test-list-templates-view.exp
│   └── test-delete-template.exp
├── fixtures/               # Test data
│   ├── ssh-config.test
│   └── mock-entrypoint.sh
└── results/                # Test output
    ├── test-report.txt
    └── logs/
```

## Mock Servers

5 mock SSH servers simulate real homelab hosts:
- `pihole` - Pi-hole server
- `docker-host` - Docker host
- `proxmox` - Proxmox server
- `jellyfin` - Jellyfin media server (bulk tests)
- `legacy-host` - Host with existing non-HLT MOTD (protection tests)

## Test Coverage Matrix

| Category | Tests | Coverage |
|----------|-------|----------|
| Static (syntax, shellcheck) | ~15 | 100% |
| CLI Options (--help, -s, -v) | ~50 | 100% |
| Menu Navigation (Expect) | ~40 | 100% |
| Service Presets | ~15 | 100% |
| SSH Deploy/Undeploy | ~10 | 100% |
| Input Validation/Security | ~10 | 100% |
| **TOTAL** | **~140** | **100%** |

## What's Tested

1. **Static Tests** - Syntax, ShellCheck, help output
2. **Install/Uninstall** - Full lifecycle
3. **Menu Navigation** - ALL menus via Expect (main, MOTD, config, backups)
4. **Functional Tests** - generate, deploy, list, delete
5. **SSH Tests** - Deploy/undeploy with mock servers
6. **Edge Cases** - Invalid input, unreachable hosts
7. **CLI Options** - All --help, --all, -s, -v flags
8. **Service Presets** - Auto-detection for 10+ services
9. **Arrow Navigation** - ↑↓ keys, vim j/k, menu cycling
10. **MOTD Protection** - HLT markers, replace/append/cancel

## Requirements

- Docker
- docker-compose (or `docker compose`)

## Notes

- This entire folder is in `.gitignore`
- Tests are fully isolated - no impact on host
- Results saved in `results/test-report.txt`
