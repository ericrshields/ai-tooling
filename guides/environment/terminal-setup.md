# Terminal & Shell Setup

Configuration for Windows Terminal, shell selection, and optimization for development workflows.

---

## Terminal Emulator Selection

**Recommended for WSL2**: Windows Terminal (Microsoft's official, free)

| Feature | Windows Terminal | Alacritty | ConEmu | wezterm |
|---------|-----------------|-----------|--------|---------|
| **Native Windows** | ✅ Yes | ⚠️ Via WSL | ✅ Yes | ⚠️ Via WSL |
| **WSL2 Support** | ✅ Excellent | ✅ Good | ✅ Good | ✅ Good |
| **Built-in tabs/panes** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes |
| **GPU acceleration** | ❌ No | ✅ Yes | ❌ No | ❌ No |
| **Easy config** | ✅ JSON settings | ❌ YAML only | ⚠️ Steep curve | ✅ Lua |
| **Community size** | ✅ Large | ✅ Growing | ⚠️ Declining | ✅ Growing |

**Verdict**: **Windows Terminal** is best for most users (official, stable, WSL2-first design).

---

## Windows Terminal Setup

### Installation

```bash
# Via Windows Store (easiest)
# Search for "Windows Terminal" in Microsoft Store

# Or via winget:
winget install Microsoft.WindowsTerminal
```

### Configuration

**Settings file location**: `%APPDATA%\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`

**Essential Settings**:

```json
{
  "defaultProfile": "{07b52e3e-de2c-5db4-bd2d-ba144dd330ca}",
  "profiles": {
    "defaults": {
      "fontFace": "Cascadia Code",
      "fontSize": 10,
      "useAcrylic": true,
      "acrylicOpacity": 0.9
    },
    "list": [
      {
        "guid": "{07b52e3e-de2c-5db4-bd2d-ba144dd330ca}",
        "name": "Ubuntu",
        "source": "Windows.Terminal.Wsl",
        "startingDirectory": "//wsl$/Ubuntu/home/USERNAME",
        "bellStyle": "none",
        "antialiasingMode": "cleartype"
      }
    ]
  },
  "schemes": [
    {
      "name": "One Half Dark",
      "background": "#282C34",
      "foreground": "#ABB2BF"
    }
  ]
}
```

**Key Settings**:
- `defaultProfile`: Set to Ubuntu (WSL) instead of PowerShell
- `startingDirectory`: Opens in home directory, not system root
- `useAcrylic`: Transparency effect (can disable for performance)
- `bellStyle`: Disable annoying bell sound
- `antialiasingMode`: Better font rendering

### Why Use WSL Shell Instead of PowerShell

| Feature | PowerShell | Bash (WSL) |
|---------|-----------|-----------|
| **SSH behavior** | Inconsistent, PATH issues | Consistent POSIX behavior |
| **Script compatibility** | PowerShell-specific | Universal (most tools assume bash) |
| **Command availability** | Limited to Windows/PowerShell | All Unix tools available |
| **Environment variables** | Different format | Standard Unix format |
| **Remote SSH** | Can behave oddly over SSH | Reliable over SSH |
| **Dev tool support** | ⚠️ Some tools don't support | ✅ Full support |

**Bottom line**: Use **bash (WSL) for SSH and development work**. Use PowerShell only for Windows-specific tasks.

### Set WSL as Default Shell

1. Open Windows Terminal → Settings (Ctrl+,)
2. Go to "Startup"
3. Set "Default profile" → Ubuntu
4. Click "Save"

---

## WSL2 Shell Configuration

### Shell Selection: Bash vs Zsh vs Fish

For development with SSH, **bash is the safest choice** (most portable):

| Shell | Pros | Cons |
|-------|------|------|
| **Bash** | POSIX standard, universal, scripts work everywhere | Less modern features |
| **Zsh** | Modern, better completion, Oh My Zsh ecosystem | Not always installed on servers |
| **Fish** | User-friendly, excellent completions | Non-POSIX, breaks many scripts |

**Recommendation**: Use **bash** for consistency across local and remote machines.

### Bash Configuration

**File**: `~/.bashrc` (local settings, run for every new shell)

```bash
# Add to ~/.bashrc

# Set up PATH
export PATH=$PATH:~/.local/bin

# Aliases for common commands
alias ll='ls -lah'
alias gs='git status'
alias gd='git diff'
alias ssh-dev='ssh dev-cloud'

# Enable bash completion (Ubuntu 24.04)
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Add git branch to prompt
git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1='\u@\h:\W $(git_branch)\$ '

# Increase history size
export HISTSIZE=10000
export HISTFILESIZE=10000
```

### Dotfile Organization

Keep shell configs in a versioned directory:

```
~/.dotfiles/
├── bashrc
├── gitconfig
├── ssh/config
└── setup.sh
```

Symlink to home directory:
```bash
ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
```

---

## Performance Tips

### Windows Terminal Performance

1. **Disable transparency** if lagging:
   - Settings → Profiles → Ubuntu → Appearance
   - Set `useAcrylic` to `false`

2. **Reduce animation speed**:
   - Settings → Startup → Animation
   - Set to `fast` or `none`

3. **Close unused tabs**: Each tab runs a shell process

### WSL2 Performance Optimization

For comprehensive WSL2 performance tuning, resource allocation, and filesystem optimization, see [WSL2 Environment Setup: File System & Performance](./wsl2-setup.md#file-system--performance).

**Quick tips**:
- Keep development files in `~/projects` (WSL), not `/mnt/c/` (Windows drive) for 5x faster operations
- Allocate resources via `%USERPROFILE%\.wslconfig`: `memory=4GB`, `processors=4`
- Use WSL2 (not WSL1) for best performance

---

## SSH Configuration in Terminal

For SSH setup, key management, troubleshooting, and configuration patterns, see [SSH Configuration](./ssh-configuration.md).

**Quick setup in WSL**:
- Store keys in `~/.ssh/` with `chmod 700` permissions
- Set key permissions: `chmod 600 ~/.ssh/*`
- Enable SSH agent in `~/.bashrc` to avoid passphrase prompts
- Add SSH aliases: `alias ssh-dev='ssh dev-cloud'`

For complete SSH documentation including key generation, SSM troubleshooting, and connection recovery scripts, refer to the [SSH Configuration guide](./ssh-configuration.md).

---

## Keybindings & Productivity

### Useful Windows Terminal Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+T` | New tab |
| `Ctrl+Shift+T` | Duplicate tab |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Alt+Shift+V` | Split pane (vertical) |
| `Alt+Shift+H` | Split pane (horizontal) |

### Custom Keybindings

Add to `settings.json`:

```json
{
  "actions": [
    {
      "command": "newTab",
      "keys": "ctrl+t"
    },
    {
      "command": "closePane",
      "keys": "ctrl+shift+w"
    }
  ]
}
```

---

## Troubleshooting

### WSL Drive Permissions Issues

```bash
# Fix file permissions in WSL
sudo chown -R $USER ~/.ssh
sudo chmod 700 ~/.ssh
```

### PowerShell Randomly Opens Instead of Bash

Make sure Ubuntu is the default profile:
1. Settings → Startup → Default profile
2. Select "Ubuntu"
3. Click Save

### SSH Over Windows Terminal Hangs/Drops

See [SSH Configuration: Troubleshooting](./ssh-configuration.md#troubleshooting)

**Quick fix**: Use direct SSH instead of SSM Session Manager (simpler, more reliable)

---

## Related Documentation

- [SSH Configuration](./ssh-configuration.md) - Remote access and troubleshooting
- [WSL2 Environment Setup](./wsl2-setup.md) - WSL2-specific configuration
- [guides/scripting/](../scripting/) - Bash scripting best practices
- [configs/tools.md](../../configs/tools.md) - Tool installation and setup
