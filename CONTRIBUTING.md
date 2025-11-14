# Contributing to Homelab Tools

Thanks for your interest in contributing! 🎉

## How to Contribute

### Reporting Bugs

Found a bug? Please open an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, bash version)

### Suggesting Features

Have an idea? Open an issue with:
- Clear description of the feature
- Use case / why it's useful
- Any implementation ideas

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages
6. Push and create a PR

### Code Style

- Use bash best practices
- Add comments for complex logic
- Keep functions focused and small
- Use meaningful variable names
- Test on Debian/Ubuntu if possible

### Testing

Before submitting:
```bash
# Test the main menu
./bin/homelab

# Test MOTD generation
./bin/generate-motd test

# Check for syntax errors
bash -n bin/*
```

### Adding New Services

To add auto-detection for a new service, edit `bin/generate-motd`:

1. Add a case pattern matching the service name
2. Set `service_name`, `description`, `has_webui`, `webui_port`
3. Test with `generate-motd yourservice`

Example:
```bash
yourservice*)
    service_name="YourService"
    description="What it does"
    has_webui="y"
    webui_port="8080"
    ;;
```

## Questions?

Feel free to open an issue for any questions!

---

**Happy homelab-ing!** 🏠✨
