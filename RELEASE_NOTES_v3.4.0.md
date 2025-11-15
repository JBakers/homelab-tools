# 🚀 Homelab Tools v3.4.0 Release Notes

**Release Date:** 16 November 2025  
**Author:** J.Bakers

---

## 🚀 What's New

- All scripts and documentation updated to v3.4.0
- Bulk generate workflow now supports "yes to all" for clean, automated MOTD generation
- Expanded MOTD style selection: clean default, 5 ASCII art options, live preview
- Input validation and command injection protection in all relevant scripts
- Interactive menu and prompts reworked for clarity and usability
- Improved installation instructions and FHS-compliant structure
- Minor bugfixes and consistency improvements

---

## 🔧 Upgrade Instructions

### From v3.3.0 or earlier

```bash
cd ~/homelab-tools
git pull
sudo ./install.sh
source ~/.bashrc
```

### Fresh Install

```bash
cd ~
git clone https://github.com/JBakers/homelab-tools.git
cd homelab-tools
sudo ./install.sh
source ~/.bashrc
```

---

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed changes.

---

Made with ❤️ by [J.Bakers](https://github.com/JBakers)
