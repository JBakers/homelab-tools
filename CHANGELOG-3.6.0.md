# Changelog v3.6.0-dev

## Version History (retroactive documentation)

All commits between v3.5.0 and v3.6.0-dev.1 should have had individual version bumps but didn't. This documents what they should have been:

### v3.6.0-dev.1 (88dcc20)
- feat: add undeploy-motd script
- fix: install.sh banner bug

### v3.6.0-dev.2 (49db855)
- fix: improve .bashrc cleanup safety in uninstall.sh

### v3.6.0-dev.3 (76e0c8f)
- fix: properly remove banner with nested if/fi tracking

### v3.6.0-dev.4 (383844a)
- fix: add sanity checks to .bashrc cleanup

### v3.6.0-dev.5 (ad3e43c)
- fix: use full awk cleanup in install.sh clean_user_data()

### v3.6.0-dev.6 (81c6c2c)
- fix: restore .bashrc ownership after cleanup

### v3.6.0-dev.7 (650abd1)
- feat: add deployment status to list-templates

### v3.6.0-dev.8 (b87b393)
- feat: add interactive MOTD preview to list-templates

### v3.6.0-dev.9 (45c9f3a)
- refactor: replace Jellyfin examples with Pi-hole

### v3.6.0-dev.10 (dc13f49)
- chore: bump version to 3.6.0-dev.1 (should have been dev.10)

---

**Going forward:** Every feature/fix commit will be followed by a version bump commit using `./bump-dev.sh`
