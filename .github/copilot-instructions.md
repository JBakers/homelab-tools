# Homelab Tools - AI Agent Instructions

## Project Overview
Bash toolkit for managing homelab infrastructure with auto-detecting MOTD generators (60+ services), SSH management, and bulk operations. Target: Linux homelabs (Debian/Ubuntu). Uses clean terminal UIs with arrow navigation and ANSI colors.

## Architecture

### Directory Structure
- **`bin/`** - Main executables (12 commands: `homelab`, `generate-motd`, `deploy-motd`, `undeploy-motd`, `bulk-generate-motd`, `list-templates`, `delete-template`, `edit-hosts`, `edit-config`, `cleanup-keys`, `copykey`, `cleanup-homelab`)
- **`lib/`** - Shared libraries (`menu-helpers.sh` for arrow navigation, `version.sh` for version management, `constants.sh`)
- **`config/`** - Config examples and MOTD templates (`server-motd/generic.sh`)
- **`templates/`** - User-created MOTD templates (stored in `~/.local/share/homelab-tools/templates/`)

### Installation Model
- **Source**: `~/homelab-tools/` or `/tmp/homelab-tools/` (during install)
- **Target**: `/opt/homelab-tools/` (system-wide, requires sudo)
- **Symlinks**: `/home/<user>/.local/bin/` → `/opt/homelab-tools/bin/*`
- **PATH**: Added to `~/.bashrc` with versioned comments for clean uninstall

### Key Components

#### 1. MOTD Generation System
Generates dynamic bash scripts that display system info on SSH login:
- **60+ Service Presets**: Auto-detection for Pi-hole, Plex, Jellyfin, *arr stack (Sonarr/Radarr/etc), Home Assistant, Proxmox, and more
- **Smart Defaults**: Each preset includes service name, description, Web UI port, and version detection commands
- **Number Handling**: Services like `pihole2` automatically become "Pi-hole 2" (extracts trailing digits)
- **ASCII Art Styles**: Optional 5 styles via `toilet` (Rainbow Future, Mono Future, etc.) or clean functional default
- **Template Output**: Bash scripts in `~/.local/share/homelab-tools/templates/<service>.sh`

#### 2. Arrow Menu System
Interactive terminal UI with keyboard navigation:
- **Core Function**: `show_arrow_menu()` in `lib/menu-helpers.sh`
- **Navigation**: ↑↓ arrow keys, vim keys (j/k), Enter to select, ESC/Q to quit
- **Menu Result**: Sets global `MENU_RESULT` variable (0-based index, -1 for quit/ESC)
- **Fallback Mode**: `simple_menu()` for terminals without arrow key support (via `HLT_MENU_SIMPLE=1`)
- **Pattern**: Use `choose_menu()` wrapper that auto-detects which menu mode to use

#### 3. Template Management & Deployment Tracking
Templates are reusable, deployable MOTD scripts with lifecycle tracking:
- **Storage**: `~/.local/share/homelab-tools/templates/<service>.sh` (user-writable)
- **Deploy Log**: `~/.local/share/homelab-tools/deploy-log` tracks deployments (format: `<service>|<hostname>|<timestamp>|<hash>`)
- **Status Indicators**:
  - 🟢 Deployed - Template exists and matches deployed version
  - 🟡 Ready - Template exists but not deployed
  - 🔴 Stale - Deployed version differs from current template
- **Commands**:
  - `deploy-motd <service>` - Upload to `/tmp/motd.sh` → install to `/etc/update-motd.d/00-custom`
  - `undeploy-motd <service>` - Remove from remote host (searches for `00-motd.sh`)
  - `list-templates -s` - Show deployment status for all templates
  - `list-templates -v` - Interactive preview mode with arrow navigation

#### 4. SSH Operations
Remote execution via SSH with careful privilege escalation:
- **Pattern**: `scp` to upload, `ssh -t` for interactive sudo commands
- **Target Location**: `/etc/update-motd.d/00-custom` (Debian/Ubuntu MOTD system)
- **Host Resolution**: Uses `~/.ssh/config` entries (managed via `edit-hosts`)
- **Key Management**: `copykey` distributes keys, `cleanup-keys` removes stale host keys after container rebuilds

## Critical Patterns

### Communication & Language
- **Communicatie:** altijd in het Nederlands met de gebruiker
- **Code & strings:** altijd in het Engels (code, comments, user-facing tekst)

### Script Header (REQUIRED)
Every script starts with:
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Load paths and libraries
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [[ -L "$SCRIPT_PATH" ]]; do
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"
source "$LIB_DIR/menu-helpers.sh"
```

### Input Validation (SECURITY CRITICAL)
All user inputs MUST be validated to prevent command injection:
```bash
# Service names: alphanumeric + ._-
if [[ ! "$SERVICE" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo -e "${RED}✗ Invalid service name${RESET}"
    exit 1
fi

# Hostnames/IPs: strict pattern matching
if [[ ! "$HOST" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo -e "${RED}✗ Invalid hostname${RESET}"
    exit 1
fi
```
**Never** use user input directly in SSH/SCP/sed commands without validation.

### Color Standards
Use ANSI codes defined in every script:
```bash
CYAN='\033[0;36m'    # Headers, titles
GREEN='\033[0;32m'   # Success, positive actions
YELLOW='\033[1;33m'  # Warnings, prompts
RED='\033[0;31m'     # Errors
BOLD='\033[1m'       # Emphasis
RESET='\033[0m'      # Reset formatting
```

### Menu Pattern
```bash
choose_menu "Title" \
    "Option 1|description" \
    "Option 2|description" \
    "BACK"
result="$MENU_RESULT"  # Global var set by show_arrow_menu()

case "$result" in
    0) action1 ;;
    1) action2 ;;
    -1|*) return ;;  # Back/ESC/Q
esac
```

## Development Workflow

### Version Management
**Centralized Version System** (v3.6.0+):
- **Single Source of Truth**: `VERSION` file contains version string (e.g., `3.6.0-dev.35`)
- **All Scripts Read From**: `lib/version.sh` provides `get_version()` function
- **Never Hardcode**: Scripts use `# Version: See VERSION file` header comment

**Development Versioning**:
- **Format**: `MAJOR.MINOR.PATCH-dev.BUILD` (e.g., `3.6.0-dev.05`)
- **Auto-Increment**: `./bump-dev.sh "commit message"` bumps build number
- **Build Limit**: At `.09`, auto-bumps patch version (e.g., `3.6.0-dev.09` → `3.6.1-dev.00`)
- **Workflow**: When ready to commit → run `bump-dev.sh` → commit → push

**Release Process**:
```bash
# 1. Final development commit
git commit -m "Final changes for v3.6.0"
./bump-dev.sh

# 2. Create release
./release.sh        # Strips -dev, updates CHANGELOG.md

# 3. Merge to main
./merge-to-main.sh  # Excludes dev-only files

# 4. Tag and push
git tag -a v3.6.0 -m "Release v3.6.0"
git push origin main --tags
git checkout develop
```

**Quick Testing** (without git commit):
```bash
./sync-dev.sh  # Rsync workspace → /opt/homelab-tools/
               # Excludes: dev scripts, .git, GitHub-only docs
               # Use for rapid iteration testing
```

### Branch Strategy
**Three-tier structure**:

1. **`main` branch** - Production only:
   - Pure user-facing code
   - Excludes: `bump-dev.sh`, `release.sh`, `merge-to-main.sh`, `sync-dev.sh`, `test-runner.sh`
   - Excludes: `TESTING_CHECKLIST.md`, `TEST_SUMMARY.txt`, GitHub-only docs
   - Only project owner merges to main

2. **`develop` branch** - Active development:
   - All production code + development tools
   - Includes: All dev scripts, test suite, comprehensive docs
   - Where all development happens
   - Merged to main via `merge-to-main.sh` (clean merge, excludes dev files)

3. **Local only** (never committed):
   - `.test-env/` - Docker test environment
   - `claude.md` - AI assistant context
   - `TODO.md` - Personal task tracking
   - `.dev-workspace` - Marker file preventing accidental uninstall

**Workflow Rules**:
- ✅ All development on `develop` branch
- ✅ Test with `./test-runner.sh` before major changes
- ✅ Use `./sync-dev.sh` for quick testing (no git operations)
- ✅ Batch changes, commit only when user approves
- ✅ After commit: run `./bump-dev.sh` to update version
- ✅ Update TODO.md and CHANGELOG.md when adding features/fixes
- ❌ Never merge directly to `main` (use `merge-to-main.sh`)
- ❌ Never commit dev-only files to `main`

### Testing
Run comprehensive test suite:
```bash
./test-runner.sh  # 72 tests across 12 sections (5-10 min)
```

**Test Structure**:
- **12 Sections**: Pre-flight cleanup, fresh install, menu navigation, MOTD generation, deploy/undeploy, templates, uninstall
- **Interactive Checkboxes**: Tests marked with ✅/❌, progress saved to `~/.homelab-test-progress`
- **Automated Commands**: Each test has predefined command and verification condition
- **Menu Navigation Testing**: Uses `expect` for arrow key simulation

**Example Test Flow**:
1. Section 0: Complete uninstall → git pull → verify clean state
2. Section 1: Fresh install → verify /opt files → check symlinks
3. Section 4: Generate MOTD → verify template created → check syntax
4. Section 5: Deploy → verify remote file → test undeploy
5. Section 11: Final verification → complete uninstall

Tests include: installation, menu navigation, MOTD generation, deployment, uninstallation.

### Key Scripts
- **`install.sh`** - Copies to `/opt`, creates symlinks, adds to PATH, optionally configures SSH
- **`uninstall.sh`** - Removes from `/opt`, cleans symlinks, removes PATH entries from `~/.bashrc`
- **`sync-dev.sh`** - Quick rsync from workspace → `/opt` for testing changes
- **`bump-dev.sh`** - Auto-increment version, git commit, updates VERSION file only
- **`merge-to-main.sh`** - Clean merge develop→main, excludes dev-only files
- **`test-runner.sh`** - Comprehensive 72-test suite with interactive checkboxes

### Critical: .bashrc Cleanup Mechanism
**Problem**: Safely remove versioned PATH entries from `.bashrc` without corrupting file

**Solution**: AWK state machine in `install.sh` and `uninstall.sh`
```bash
# Pattern to detect:
# START HOMELAB-TOOLS v3.6.0
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
# END HOMELAB-TOOLS

# AWK State Machine:
awk '
    /^# START HOMELAB-TOOLS/ { in_block=1; next }
    /^# END HOMELAB-TOOLS/ { in_block=0; next }
    !in_block { print }
' ~/.bashrc
```

**Features**:
- Tracks nested `if/fi` pairs (doesn't break on nested conditions)
- Version-agnostic removal (removes any v3.x.x block)
- Validates with `bash -n` before applying changes
- Preserves ownership after sudo operations (`chown`)
- Safe for multiple install/uninstall cycles

**Why This Matters**: Earlier versions had bugs where uninstall corrupted `.bashrc`, leaving unclosed `if` statements. The AWK state machine solves this by tracking block boundaries precisely.

## Common Tasks

### Adding a New Service Preset
Edit [`bin/generate-motd`](../bin/generate-motd) case statement (~line 200):
```bash
mynewservice*)
    number=$(echo "$SERVICE" | grep -o '[0-9]\+$' || true)
    service_name="MyNewService${number:+ $number}"
    description="What it does"
    has_webui="y"
    webui_port="8080"
    ;;
```

**Service Auto-Detection Pattern**:
1. **Case Match**: Use `service*` pattern to catch `service`, `service1`, `service2`, etc.
2. **Number Extraction**: `grep -o '[0-9]\+$'` extracts trailing digits
3. **Name Construction**: `${number:+ $number}` adds space + number only if present
4. **Web UI**: Set `has_webui="y"` and `webui_port` for services with web interfaces
5. **Version Detection**: Add version commands like `DOCKER_VERSION=$(docker --version)`

**Examples from codebase**:
- `pihole*` → "Pi-hole" or "Pi-hole 2" (auto-detects number)
- `jellyfin*` → "Jellyfin" with port 8096
- `sonarr` → "Sonarr" with port 8989 (no number handling needed)

### Adding a Menu Option
Use arrow menu pattern with `choose_menu` from `lib/menu-helpers.sh`. See `bin/homelab` lines 350-450 for examples.

**Menu Implementation Pattern**:
```bash
while true; do
    choose_menu "Menu Title" \
        "Option 1|Description text" \
        "Option 2|Description text" \
        "BACK"
    result="$MENU_RESULT"
    
    case "$result" in
        0) handle_option1 ;;
        1) handle_option2 ;;
        -1|*) break ;;  # Back/ESC/Q exits loop
    esac
done
```

**Important**: Always provide a "BACK" option as the last menu item for proper navigation.

### SSH Remote Operations
Standard pattern for deploy/undeploy:
```bash
# Upload
scp "$template_file" "$HOST:/tmp/motd.sh" || exit 1

# Deploy
ssh -t "$HOST" "sudo bash -c 'cat /tmp/motd.sh > /etc/update-motd.d/00-custom && chmod +x /etc/update-motd.d/00-custom'" || exit 1
```

## Configuration
- **User config**: `/opt/homelab-tools/config.sh` (copy from `config.sh.example`)
- **Domain suffix**: `DOMAIN_SUFFIX=".home"` for Web UI URLs
- **IP detection**: `IP_METHOD="hostname"` or `"ip"`

## Security Notes
- All scripts run with `set -euo pipefail`
- Input validation prevents command injection (fixed in v3.5.0)
- Sudo operations require explicit privilege escalation
- SSH keys managed via `copykey` and `cleanup-keys`
- **Never commit** `config.sh` (in `.gitignore`)

## Code Style
- **Language**: Bash (English comments preferred, but Dutch present in some legacy code)
- **Quoting**: Always quote variables: `"$VAR"` not `$VAR`
- **Error handling**: Use `|| { echo "error"; exit 1; }` for critical operations
- **ShellCheck**: Code passes ShellCheck validation (SC2181, UUOC fixes applied)

## Historical Context & Security Fixes

### Critical Issues (All Fixed in v3.5.0)
**Command Injection Vulnerabilities** (CRITICAL - Fixed):
- User inputs in `generate-motd`, `deploy-motd`, `cleanup-keys`, `copykey` were used in shell commands without validation
- Attack vector: `generate-motd "; rm -rf / #"` could execute arbitrary commands
- **Fix**: Regex validation for all inputs (`^[a-zA-Z0-9._-]+$` for services, `^[a-zA-Z0-9.-]+$` for hosts)

**Number Duplication Bug** (Fixed):
- Services like `pihole2` showed "Pi-hole 2 2" - number added twice in case statement and regex
- **Fix**: Removed duplicate number addition logic

**Word Count Bug** (Fixed):
- `bulk-generate-motd` used `wc -w` (word count) instead of `wc -l` (line count)
- **Fix**: Changed to `wc -l` for accurate host counting

### Testing Recommendations
Before deployment, validate:
```bash
# Input validation
generate-motd "; echo hacked"  # Should reject
generate-motd "test123"        # Should work

# Number handling
generate-motd pihole2          # Should show "Pi-hole 2" (not "2 2")

# ShellCheck
shellcheck bin/*
```

## Critical Rules

### 🚨 NEVER DO THIS
1. **NEVER merge to main** - Only the project owner merges via `merge-to-main.sh`
2. **Delete files without permission** - `TODO.md`, `claude.md`, `VERSION`, `lib/version.sh` are critical
3. **Commits are user-driven** - Do not commit after every change; batch changes and only commit when explicitly approved by the user
4. **Skip version bumps** - Every commit must run `./bump-dev.sh`
5. **Hardcode versions** - Always use `VERSION` file + `lib/version.sh`
6. **Commit broken code** - Test with `./test-runner.sh` before committing
7. **Skip input validation** - All user inputs MUST be validated with regex

### Code Standards (Enforced)
- All scripts pass `shellcheck` and `bash -n` validation
- English for code/docs, Dutch for team communication
- Arrow key navigation (↑↓, j/k) for all menus, never numeric selection
- `q` = cancel/quit everywhere
- Quote all variables: `"$VAR"` not `$VAR`
- Error handling: `|| { echo "error"; exit 1; }`

### Testing Requirements
**MUST test before any commit:**
1. Syntax: `bash -n bin/script`
2. Help text: `command --help` (verify no escape code issues)
3. Functionality: Test expected behavior
4. Menu navigation: Arrow keys work, q=quit works
5. Integration: Works with other commands

**For major changes**: Run full `./test-runner.sh` (72 tests, 5-10 min)

## Documentation
- [`README.md`](../README.md) - User guide with 60+ service presets
- [`QUICKSTART.md`](../QUICKSTART.md) - 60-second getting started
- [`CONTRIBUTING.md`](../CONTRIBUTING.md) - Contribution guidelines
- [`CHANGELOG.md`](../CHANGELOG.md) - Version history and release notes
