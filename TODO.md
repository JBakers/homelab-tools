# TODO: Homelab-Tools Project Checklist

> This checklist is updated with every commit. Keep it in the project root as TODO.md.

## 🔴 PRIORITY: Security & Privacy
- [x] Remove or audit `.markdownlint.json` from working directory
- [x] Remove reference to `claude.md` from README.md (file is gitignored)
- [x] Create SECURITY.md with security policy and responsible disclosure
- [x] Audit all example configs for sensitive data (e.g., hardcoded usernames in examples)
- [x] Add warning in config.sh.example about not committing sensitive data

## 🟠 HIGH PRIORITY: Installation & Uninstall
- [x] Detect and handle legacy ~/homelab-tools installations (ask user: backup+remove, backup only, or keep)
- [x] Always install to /opt/homelab-tools
- [x] Ensure ~/.local/bin/homelab symlink points to /opt/homelab-tools/bin/homelab
- [x] Test and improve uninstall.sh (translate to English, handle all cases)
- [ ] Add uninstall option to main menu
- [x] Remove or integrate migrate-to-opt.sh (now part of install.sh - will be removed)

## 🟡 MEDIUM PRIORITY: Code Cleanup
- [ ] Remove or archive `.todos.md` (superseded by TODO.md)
- [ ] Consolidate or remove old RELEASE_NOTES files if redundant
- [ ] Add .editorconfig for consistent code style
- [ ] Review and clean up bin/ scripts for consistency

## .bashrc & Welcome Banner
- [x] Audit ~/.bashrc for old homelab-tools PATH/exports/aliases (do not touch .ssh)
- [x] Remove only obsolete homelab-tools lines, keep .ssh untouched
- [x] Add ASCII welcome banner with auto-updating version info (from central VERSION file)
- [x] Show banner only in interactive shells, not in VS Code
- [x] Make banner optional via HLT_BANNER=0 in ~/.bashrc

## Menu & Usability
- [ ] Ensure homelab-tools menu always starts (fallback for unsupported terminals/input)
- [ ] Improve prompts and workflow for bulk generate (yes to all, ASCII style selection)
- [ ] Test all menu navigation and input methods

## Documentation & Versioning
- [ ] Update README and CHANGELOG with migration, banner option, and version info
- [ ] Ensure version info is managed centrally and shown everywhere
- [ ] Remove broken references (claude.md) from documentation

## Testing & Data Safety
- [ ] Test install, migration, and usage in a clean shell
- [ ] Ensure old data/templates/configs are safely backed up and migrated
- [ ] Test uninstall.sh thoroughly

## Internationalization (i18n)
- [x] Convert all Dutch text in scripts to English (install.sh complete)
- [ ] Convert remaining scripts: homelab, generate-motd, deploy-motd, etc.
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
