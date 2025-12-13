# TODO: Homelab-Tools Project Checklist

> This checklist is updated with every commit. Keep it in the project root as TODO.md.

## 🔴 PRIORITY: Complete File Audit

### bin/ Scripts Audit
- [ ] **homelab** - Main menu script
  - Status: Working, arrow navigation fixed
  - TODO: Test all menu paths, verify q=cancel works everywhere
- [ ] **bulk-generate-motd** - Bulk MOTD generator
  - Status: Working, q=cancel added
  - TODO: Test all generation modes, verify ASCII preview
- [ ] **generate-motd** - Single MOTD generator
  - Status: Working, q=cancel added
  - TODO: Verify all ASCII styles work, test customization flow
- [ ] **deploy-motd** - Deploy MOTD to hosts
  - Status: Working
  - TODO: Test SSH deployment, error handling
- [ ] **cleanup-keys** - SSH key cleanup
  - Status: Working, q=cancel present
  - TODO: Test single and bulk cleanup
- [ ] **cleanup-homelab** - Remove orphaned templates
  - Status: Needs review
  - TODO: Verify it only removes orphans, test thoroughly
- [ ] **copykey** - SSH key distribution
  - Status: Working
  - TODO: Test with unreachable hosts
- [ ] **edit-config** - Edit homelab config
  - Status: Working, q=cancel added
  - TODO: Verify config is saved correctly
- [ ] **edit-hosts** - Edit SSH config
  - Status: Working
  - TODO: Verify editor opens correctly
- [ ] **list-templates** - List MOTD templates
  - Status: Working
  - TODO: Verify output formatting

### lib/ Library Audit
- [ ] **menu-helpers.sh** - Shared menu functions
  - Status: Working, arrow nav + timeout fixed
  - TODO: Test in different terminal emulators

### Root Scripts Audit
- [ ] **install.sh** - Installation script
  - Status: Working
  - TODO: Test fresh install, upgrade, migration
- [ ] **uninstall.sh** - Uninstallation script
  - Status: Needs review
  - TODO: Test complete removal, verify no orphaned files
- [ ] **bump-dev.sh** - Bump dev version
  - Status: Working
  - TODO: Verify version format
- [ ] **bump-version.sh** - Bump release version
  - Status: Needs review
  - TODO: Test version bump workflow
- [ ] **update-version.sh** - Update version in files
  - Status: Needs review
  - TODO: Verify all files are updated
- [ ] **release.sh** - Release workflow
  - Status: Needs review
  - TODO: Test release process
- [ ] **export.sh** - Export configuration
  - Status: Needs review
  - TODO: Verify export format and content
- [x] **migrate-to-opt.sh** - Legacy migration
  - Status: REMOVED - was integrated into install.sh
- [ ] **config.sh** - Main configuration
  - Status: Working
  - TODO: Verify all settings are used

### Config Files Audit
- [ ] **config.sh.example** - Example config
  - Status: OK
  - TODO: Ensure no sensitive data
- [x] **config/hosts.txt.example** - Example hosts
  - Status: REMOVED - obsolete (using ~/.ssh/config now)
- [ ] **config/ssh-config.example** - Example SSH config
  - Status: OK
  - TODO: Verify format is correct
- [ ] **config/server-motd/generic.sh** - Generic MOTD template
  - Status: Needs review
  - TODO: Verify it works with current generate-motd
- [x] **config/server-motd/test.sh** - Test MOTD template
  - Status: REMOVED - obsolete

### Documentation Audit
- [ ] **README.md** - Main documentation
  - Status: Needs update
  - TODO: Update with new features, remove broken refs
- [ ] **CHANGELOG.md** - Change history
  - Status: Needs update
  - TODO: Add recent changes
- [ ] **QUICKSTART.md** - Quick start guide
  - Status: Needs review
  - TODO: Verify steps are correct
- [ ] **CONTRIBUTING.md** - Contribution guide
  - Status: OK
  - TODO: Review guidelines
- [ ] **SECURITY.md** - Security policy
  - Status: OK
  - TODO: Review policy
- [ ] **LICENSE** - License file
  - Status: OK
- [ ] **VERSION** - Version file
  - Status: OK
- [x] **.todos.md** - Old todo file
  - Status: REMOVED - superseded by TODO.md
- [ ] **claude.md** - AI assistant context
  - Status: gitignored, OK
  - TODO: Verify not referenced in public docs

## 🟠 HIGH PRIORITY: Installation & Uninstall
- [x] Detect and handle legacy ~/homelab-tools installations
- [x] Always install to /opt/homelab-tools
- [x] Ensure ~/.local/bin/homelab symlink points to /opt
- [x] Test and improve uninstall.sh
- [x] Add uninstall option to main menu
- [x] Remove or integrate migrate-to-opt.sh (removed)

## 🟡 MEDIUM PRIORITY: Code Cleanup
- [x] Remove `.todos.md` (removed)
- [x] Remove `migrate-to-opt.sh` (removed)
- [x] Remove `config/hosts.txt.example` (removed - obsolete)
- [x] Remove `config/server-motd/test.sh` (removed - obsolete)
- [ ] Add .editorconfig for consistent code style

## 🟢 LOW PRIORITY: Enhancements
- [ ] Add uninstall option to main menu
- [ ] Improve ASCII art preview performance
- [ ] Add more MOTD templates/styles
- [ ] Add host group support for bulk operations

## Documentation & Versioning
- [ ] Update README with new features
- [ ] Update CHANGELOG with recent changes
- [ ] Ensure version info is shown everywhere

## Internationalization (i18n)
- [x] Convert all Dutch text in scripts to English (install.sh)
- [ ] Convert remaining scripts to English

## 🔴 PRIORITY: Security & Privacy
- [x] Remove or audit `.markdownlint.json`
- [x] Remove reference to `claude.md` from README.md
- [x] Create SECURITY.md
- [x] Audit example configs for sensitive data
- [x] Add warning in config.sh.example
- [ ] Add language support option (LANG=en/nl/de/fr/es)
- [ ] Create language files (lib/lang/en.sh, lib/lang/nl.sh, etc.)
- [ ] Update all user-facing messages to use language variables
- [ ] Add language selection in install.sh and configuration menu
- [ ] Document language support in README

---

**Instructions:**  
- Update this TODO.md with every commit (add, check off, or clarify items as needed).
- Use this as the single source of truth for project progress and code review.
- Priority: 🔴 Security → 🟠 High → 🟡 Medium → Regular tasks
