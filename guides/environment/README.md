# Environment & System Configuration Guides

Hub for general development environment setup, terminal configuration, and remote access patterns.

---

## Quick Reference

| Topic | Purpose | Audience |
|-------|---------|----------|
| [SSH Configuration](./ssh-configuration.md) | Remote access patterns: direct SSH vs SSM, key management, troubleshooting | Developers using AWS, remote servers |
| [Terminal & Shell Setup](./terminal-setup.md) | Windows Terminal, WSL2, shell configuration, dotfiles | WSL2 users, multi-platform developers |
| [WSL2 Environment Setup](./wsl2-setup.md) | WSL2 configuration, Ubuntu profile setup, integration with Windows Terminal | Windows developers using WSL |

---

## Common Tasks

### I need to connect to a remote server
→ See [SSH Configuration](./ssh-configuration.md)

### My SSH connections keep dropping or fail with "UNKNOWN port" errors
→ See [SSH Configuration: Troubleshooting](./ssh-configuration.md#troubleshooting)

### I want to set up my terminal on Windows
→ See [Terminal & Shell Setup](./terminal-setup.md)

### I'm using WSL2 and want to optimize it
→ See [WSL2 Environment Setup](./wsl2-setup.md)

---

## Architecture Philosophy

These guides follow the project's hub-and-spoke architecture:
- **Entry point**: This README
- **Detail guides**: Specific configuration topics
- **Tools reference**: See [configs/tools.md](../../configs/tools.md) for installed tools
- **Automation patterns**: See [workflows/script-patterns.md](../../workflows/script-patterns.md) for shell scripting

---

## Related Documentation

- [configs/tools.md](../../configs/tools.md) - Tool reference and installation
- [workflows/script-patterns.md](../../workflows/script-patterns.md) - Bash automation patterns
- [guides/scripting/](../scripting/) - Shell scripting best practices
- [.specs/constitution.md](../../.specs/constitution.md) - Repository architecture principles
