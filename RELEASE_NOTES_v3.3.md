# 🏗️ Homelab Tools v3.3.0 Release Notes

**Release Date:** 15 November 2025
**Author:** J.Bakers
**Type:** Installation & Structure Improvement Release (v3.2 → v3.3)

---

## 🚀 What's New

### 🏗️ Clean Installation Structure

This release improves the installation structure to keep your home directory clean while maintaining system-wide access.

**New Installation Layout:**
- **`/opt/homelab-tools/`** - Program files (system-wide, organized)
- **`~/.local/bin/`** - Symlinks (standard user bin directory)
- **`~/.local/share/homelab-tools/templates/`** - User data (templates)

**Benefits:**
- ✅ No clutter in home directory root
- ✅ Follows Linux Filesystem Hierarchy Standard (FHS)
- ✅ System-wide program with user-level data
- ✅ Clean separation of concerns

---

### 🔧 Installation Improvements

**Sudo Usage:**
- Only required for `/opt/` installation
- User data remains in `~/.local/`
- Clear indication when sudo is needed

**Uninstall Script:**
- Fixed `$INSTALL_DIR` unbound variable bug
- Supports both old and new installation paths
- Proper cleanup of all components

---

## 📊 Statistics

- ✅ **Clean structure** - No files in home directory root
- ✅ **FHS compliant** - Follows standard Linux directory layout
- ✅ **Bug-free uninstall** - All variables properly bound
- ✅ **Backward compatible** - Uninstalls old installations too

---

## 🔧 Upgrade Instructions

### From v3.2 or earlier

```bash
cd ~/homelab-tools
git pull
sudo ./install.sh
source ~/.bashrc
```

**Note:** This will migrate from `~/homelab-tools/` to `/opt/homelab-tools/`

### Fresh Install

```bash
cd ~
git clone https://github.com/JBakers/homelab-tools.git
cd homelab-tools
sudo ./install.sh
source ~/.bashrc
```

---

## ⚠️ Breaking Changes

**Installation Location Changed:**
- Old: `~/homelab-tools/` (clutters home directory)
- New: `/opt/homelab-tools/` (clean, system-wide)

The installer will automatically handle the migration. Your templates and SSH config remain untouched.

---

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed changes.

---

## 🙏 Acknowledgments

Special thanks to the security audit that identified these critical issues!

---

**Happy (and Secure!) Homelab Managing!** 🏠🔒

Made with ❤️ by [J.Bakers](https://github.com/JBakers)

[⬆ Back to Top](#homelab-tools-v320-release-notes)