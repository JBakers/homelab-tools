# TODO: Homelab-Tools Project Checklist

> This checklist is updated with every commit. Keep it in the project root as TODO.md.

## Installation & Migration
- [x] Detect and handle legacy ~/homelab-tools installations (ask user: backup+remove, backup only, or keep)
- [x] Always install to /opt/homelab-tools
- [x] Ensure ~/.local/bin/homelab symlink points to /opt/homelab-tools/bin/homelab
- [ ] create uninstall

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


## Testing & Data Safety
- [ ] Test install, migration, and usage in a clean shell
- [ ] Ensure old data/templates/configs are safely backed up and migrated

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
