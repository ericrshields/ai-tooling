# Corridor - Security Layer for AI Coding

Research notes on Corridor.dev, a security platform for agentic coding tools.

**Research Date**: 2026-02-04
**Status**: Preliminary - documentation not fully accessible

---

## Overview

**Company**: Corridor (corridor.dev)
**Founded**: ~2025
**Funding**: $5.4M seed round led by Conviction
**Leadership**: Alex Stamos (former Facebook CISO) joined as top security executive

**Mission**: Provide real-time security reviews for AI-powered development without breaking developer flow.

---

## Problem Statement

AI coding tools (Claude Code, Cursor, Copilot, etc.) generate code rapidly, but traditional SAST tools:
- Miss context-heavy issues like authorization flaws
- Create friction in fast-paced AI-assisted workflows
- Weren't designed for agentic code generation patterns

Corridor aims to close this security gap by bringing AI-native security analysis into the development loop.

---

## Key Capabilities

Based on available information:

1. **Vulnerability Discovery**: Uses AI to automatically discover software vulnerabilities
2. **Bug Bounty Triage**: Helps triage bug bounty reports
3. **Authorization Flaw Detection**: Identifies context-heavy issues that traditional tools miss
4. **Real-Time Reviews**: Integrates security checks without breaking development flow

---

## Integration with Claude Code

### Likely Approach: MCP Server

Corridor has forked the [mcp-servers repository](https://github.com/CorridorSecurity/mcp-servers), suggesting MCP-based integration.

**Hypothetical Configuration** (unverified):
```json
{
  "mcpServers": {
    "corridor": {
      "command": "corridor-cli",
      "args": ["mcp-server"],
      "env": {
        "CORRIDOR_API_KEY": "..."
      }
    }
  }
}
```

### Available Tools

- **[corridor-cli](https://github.com/CorridorSecurity/corridor-cli)** - CLI tool (v0.0.16 as of Jan 2026)
- **[hookshot](https://github.com/CorridorSecurity/hookshot)** - Go-based tool (purpose unknown)

---

## Documentation Resources

| Resource | URL | Notes |
|----------|-----|-------|
| Main Site | https://corridor.dev/ | Marketing/overview |
| Knowledge Base | https://docs.corridor.dev/ | Official docs (JS-rendered) |
| GitHub Org | https://github.com/CorridorSecurity | CLI and tools |
| CLI Releases | https://github.com/CorridorSecurity/corridor-cli/releases | Latest: v0.0.16 |

---

## Research Gaps

The following information was not accessible during research:

- [ ] Exact installation steps for corridor-cli
- [ ] MCP server configuration details
- [ ] Pricing model (enterprise vs. free tier)
- [ ] Specific Claude Code integration guide
- [ ] What "hookshot" tool does
- [ ] Whether real-time analysis happens locally or via API

**Recommendation**: Check docs.corridor.dev directly (requires browser) or contact Corridor for integration documentation.

---

## Competitive Context

Corridor enters a growing market of AI security tools:

| Tool | Focus | Approach |
|------|-------|----------|
| Corridor | AI-generated code security | Real-time, agentic integration |
| Snyk | Supply chain, SAST | Traditional + AI enhancement |
| Semgrep | Pattern-based SAST | Rule-based scanning |
| GitHub Advanced Security | Code scanning, secrets | Platform-integrated |

Corridor's differentiation: Built specifically for agentic coding workflows from the ground up.

---

## Future Consideration

**When to revisit**:
- When implementing security scanning in AI-assisted workflows
- When evaluating MCP servers for security tools
- When Corridor releases more detailed documentation

**Potential use cases**:
1. Pre-commit security scanning during Claude Code sessions
2. Real-time vulnerability alerts while coding
3. Security review automation for AI-generated PRs

---

## Sources

- [Corridor Homepage](https://corridor.dev/)
- [Axios: Corridor AI Startup](https://www.axios.com/2025/08/05/corridor-ai-startup-alex-stamos)
- [American Bazaar: Interview with Founder](https://americanbazaaronline.com/2025/03/12/in-conversation-with-corridors-founder-ashwin-ramaswami-460600/)
- [GitHub: CorridorSecurity](https://github.com/CorridorSecurity)
- [Corridor Blog: Introducing Corridor](https://corridor.dev/blog/introducing-corridor/)
