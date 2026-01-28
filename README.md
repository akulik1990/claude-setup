# Claude Code Setup

Three-phase setup system for Claude Code: installs 316 skills from 40+ repos, configures 6 MCP servers, and manages permissions.

## What's Included

- **316 skills** across 16 categories (Anthropic, Vercel, Sentry, Cloudflare, Stripe, databases, security, and more)
- **6 MCP servers**: filesystem, memory, fetch, puppeteer, sequential-thinking, git
- **Permission management**: permissive mode for setup, daily-driver mode for regular use
- **Claude Desktop config**: auto-configured alongside Claude Code

## Prerequisites

- [Node.js](https://nodejs.org) (v18+)
- Python 3
- Git
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/akulik1990/claude-setup.git ~/.claude/setup
```

### 2. Bootstrap (permissive permissions)

```bash
bash ~/.claude/setup/setup.sh bootstrap
```

This clears `~/.claude/settings.json` and writes permissive permissions to `~/.claude/settings.local.json` so the install phase runs without prompts.

**Restart Claude Code after this step.**

### 3. Install (skills + MCP servers)

```bash
bash ~/.claude/setup/setup.sh install
```

This clones 40+ skill repos, installs 316 skills to `~/.claude/skills/`, and configures 6 MCP servers for both Claude Code and Claude Desktop.

**Restart Claude Code after this step.**

### 4. Test

Open Claude Code and ask it to run the tests:

```
Run the setup test from ~/.claude/setup/TEST-INSTRUCTIONS.md
```

### 5. Finalize (daily-driver permissions)

Once tests pass:

```bash
bash ~/.claude/setup/setup.sh finalize
```

This locks down permissions:
- **Auto-approved**: MCP tools, Read, Glob, Grep, WebFetch, WebSearch, scoped Bash commands (git, npm, docker, etc.)
- **Requires approval**: Write, Edit, unscoped Bash
- **Denied**: `rm -rf /`, fork bombs, force-push to main, `git reset --hard`, etc.

**Restart Claude Code after this step.**

## File Structure

```
~/.claude/setup/
├── setup.sh                        # Main setup script (3 phases)
├── settings-bootstrap.json         # Permissive permissions (used during setup)
├── settings-daily-driver.json      # Restrictive permissions + hooks + deny rules
├── settings-daily-driver-local.json # Permissions-only (high-precedence layer)
├── webdev-project-settings.json    # Per-project template (fully permissive)
├── CLAUDE-SETUP.md                 # Detailed setup documentation
├── TEST-INSTRUCTIONS.md            # Post-install test suite
└── README.md                       # This file
```

## Settings Architecture

Claude Code uses two settings files with different precedence:

| File | Precedence | Purpose |
|------|-----------|---------|
| `~/.claude/settings.json` | Lower | Canonical config: permissions + hooks + deny rules |
| `~/.claude/settings.local.json` | **Higher** | Permissions only. Claude Code auto-modifies this file when you approve tools, so we seed it with the correct permissions to prevent prompts. |

## Per-Project Overrides

For projects where you want fully permissive settings (e.g., web dev), copy the template:

```bash
mkdir -p your-project/.claude
cp ~/.claude/setup/webdev-project-settings.json your-project/.claude/settings.json
```

## Updating

Pull the latest and re-run install:

```bash
cd ~/.claude/setup
git pull
bash setup.sh install
bash setup.sh finalize
```
