# TODO: Homelab-Tools

> Quick task list - mark [x] when done, move to archive on commit.

## 🔴 Critical (Fix Before Release)

- [x] Fix all ShellCheck warnings
- [x] Fix VERSION file mismatch (bump to dev.25)
- [x] Translate all Dutch text to English

## 🟠 High Priority

- [ ] Test all menu paths and q=cancel
- [ ] Test bulk-generate-motd modes
- [ ] Test uninstall.sh thoroughly
- [ ] Review cleanup-homelab script

## 🟡 Medium

- [ ] Add .editorconfig
- [ ] Update QUICKSTART.md
- [ ] Test release.sh workflow

## 🟢 Low

- [ ] Improve ASCII preview performance
- [ ] Add more MOTD templates
- [ ] Add i18n support (future)

---

## ✅ v3.5.0-dev.25 Done
- All ShellCheck warnings fixed (config.sh.example, menu-helpers.sh, generate-motd)
- Complete English translation of all scripts (no more Dutch text)
- Version sync: VERSION file now matches all scripts
- Fixed install.sh tip_count syntax error

## ✅ v3.5.0-dev.24 Done
- Arrow nav fixed • q=cancel everywhere • Uninstall menu • .bashrc cleanup
- Security audit • Removed obsolete files • Simplified TODO.md
