# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 3.6.x   | :white_check_mark: |
| 3.5.x   | :white_check_mark: |
| 3.4.x   | :x:                |
| < 3.4   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in Homelab-Tools, please report it responsibly:

1. **Do NOT open a public issue**
2. Create a private security advisory on GitHub
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will respond within 48 hours and work with you to resolve the issue.

## Security Best Practices

When using Homelab-Tools:

- **Never commit `config.sh`** - It's gitignored for a reason
- Always use `config.sh.example` as template
- Review SSH config before bulk operations
- Keep your installation updated
- Use strong passwords for SSH keys
- Verify file permissions after installation

## Known Security Features

- ✅ Input validation on all user input (command injection protection)
- ✅ `set -euo pipefail` in all scripts (fail-fast on errors)
- ✅ No hardcoded credentials or sensitive data
- ✅ FHS-compliant installation in /opt with proper permissions
- ✅ Secure file permissions (700 for dirs, 600 for configs)
- ✅ Automatic .bashrc cleanup (removes old PATH references safely)
- ✅ Legacy installation detection with backup options

## Security Audits

- **v3.2.0 (Nov 2025)** - Complete security audit and hardening
  - Command injection protection added
  - Input validation implemented
  - Error handling improved
  - All critical issues resolved

## Disclosure Timeline

When a vulnerability is reported:
1. **Day 0**: Acknowledge receipt within 48 hours
2. **Day 1-7**: Investigate and develop fix
3. **Day 7-14**: Test and release patch
4. **Day 14+**: Public disclosure (if applicable)

---

For questions about security, please open a discussion on GitHub.
