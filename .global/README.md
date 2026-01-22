# Global Claude Code Configuration Files

This directory contains actual configuration files from `~/.claude/`.

## Files

### settings.json
Global user preferences for Claude Code.
- **Current setting**: `alwaysThinkingEnabled: true`
- **Location**: `~/.claude/settings.json`
- **Safe to edit**: Yes

### known_marketplaces.json
Registered plugin marketplaces.
- **Current marketplaces**: claude-plugins-official (Anthropic)
- **Location**: `~/.claude/plugins/known_marketplaces.json`
- **Safe to edit**: Yes (to add custom marketplaces)

### installed_plugins.json
Globally installed plugins (not project-specific).
- **Current state**: No global plugins installed
- **Location**: `~/.claude/plugins/installed_plugins.json`
- **Safe to edit**: No (managed by Claude Code)

## Usage

### To replicate in a new environment:

1. **Copy global settings**:
   ```bash
   mkdir -p ~/.claude
   cp settings.json ~/.claude/
   ```

2. **Add custom marketplace (if you have access)**:
   ```bash
   # Edit ~/.claude/plugins/known_marketplaces.json
   # Add custom marketplace configuration if needed
   ```

3. **Install project-specific plugins**:
   - Plugins are typically installed per-project
   - See project `.claude/settings.json` for required plugins

## Important Notes

- **MCP Servers**: Not configured here - see configs/mcp-integration-patterns.md
- **Session Data**: Not included (file-history, todos, cache) - runtime only
- **Private Marketplaces**: Require separate access and setup

See `../GLOBAL_CONFIG.md` for complete documentation.
