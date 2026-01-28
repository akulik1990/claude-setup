# Claude Code Setup

Single-command setup for Claude Code: installs 316 skills from 40+ repos, configures 6 MCP servers, and applies daily-driver permissions.

## What's Included

- **316 skills** across 16 categories (Anthropic, Vercel, Sentry, Cloudflare, Stripe, databases, security, and more)
- **6 MCP servers**: filesystem, memory, fetch, puppeteer, sequential-thinking, git
- **Permission management**: daily-driver mode with safe defaults
- **Claude Desktop config**: auto-configured alongside Claude Code

## Prerequisites

- [Node.js](https://nodejs.org) (v18+)
- Python 3
- Git
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/akulik1990/claude-setup.git ~/.claude/setup

# 2. Run setup
bash ~/.claude/setup/setup.sh install

# 3. Restart Claude Code
```

That's it. After restarting, you'll have all skills, MCP servers, and permissions configured.

## What Gets Configured

### Permissions (daily-driver mode)

| Level | Tools |
|-------|-------|
| **Auto-approved** | MCP tools, Read, Glob, Grep, WebFetch, WebSearch, scoped Bash commands (git, npm, docker, etc.) |
| **Requires approval** | Write, Edit, unscoped Bash |
| **Denied** | `rm -rf /`, fork bombs, force-push to main, `git reset --hard`, etc. |

### Settings Architecture

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
# Restart Claude Code
```

## File Structure

```
~/.claude/setup/
├── setup.sh                        # Setup script
├── settings-daily-driver.json      # Permissions + hooks + deny rules
├── settings-daily-driver-local.json # Permissions-only (high-precedence layer)
├── webdev-project-settings.json    # Per-project template (fully permissive)
├── CLAUDE-SETUP.md                 # Detailed setup documentation
└── README.md                       # This file
```
