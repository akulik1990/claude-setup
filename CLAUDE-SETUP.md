# Claude Code & Claude Desktop - Full Setup Guide

This document contains instructions for Claude (the AI) to fully set up a new machine with all skills, MCP servers, hooks, and configurations. It also serves as human-readable documentation.

## Quickstart (New Machine)

```bash
# 1. Clone the repo
git clone https://github.com/akulik1990/claude-setup.git ~/.claude/setup

# 2. Install: skills, MCP servers, and daily-driver permissions
bash ~/.claude/setup/setup.sh install

# 3. Restart Claude Code to apply settings
```

After setup, the **daily-driver** permission model is active:
- **Auto-approved:** MCP tools, Read, Glob, Grep, WebFetch, WebSearch, safe Bash commands
- **Needs approval:** Write, Edit, uncategorized Bash commands
- **Denied:** rm -rf /, fork bombs, force-push to main, disk wiping

---

## Prerequisites

Before running the setup, ensure the following are installed:
- **Node.js** (v18+) with npm/npx
- **Python 3** (3.9+)
- **Git**
- **Claude Code CLI** (`npm install -g @anthropic-ai/claude-code`)
- **Claude Desktop** (macOS app from anthropic.com)

---

## Step 1: Install uv/uvx (Python Package Runner)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
```

Verify: `uvx --version`

---

## Step 2: Create Directory Structure

```bash
mkdir -p ~/.claude/skills
mkdir -p ~/.claude/commands
mkdir -p ~/.claude/setup
```

---

## Step 3: Install Skills

Skills are SKILL.md files that give Claude domain-specific knowledge. They go in `~/.claude/skills/` organized by category.

### Clone All Skill Repositories

```bash
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Official / Enterprise
git clone --depth 1 https://github.com/anthropics/skills.git anthropics-skills
git clone --depth 1 https://github.com/vercel-labs/agent-skills.git vercel-skills
git clone --depth 1 https://github.com/getsentry/skills.git sentry-skills
git clone --depth 1 https://github.com/cloudflare/skills.git cloudflare-skills
git clone --depth 1 https://github.com/stripe/ai.git stripe-skills
git clone --depth 1 https://github.com/supabase/agent-skills.git supabase-skills
git clone --depth 1 https://github.com/neondatabase/agent-skills.git neon-skills
git clone --depth 1 https://github.com/trailofbits/skills.git trailofbits-skills
git clone --depth 1 https://github.com/better-auth/skills.git better-auth-skills
git clone --depth 1 https://github.com/huggingface/skills.git huggingface-skills
git clone --depth 1 https://github.com/expo/skills.git expo-skills
git clone --depth 1 https://github.com/tinybirdco/tinybird-agent-skills.git tinybird-skills

# Community
git clone --depth 1 https://github.com/obra/superpowers.git obra-superpowers
git clone --depth 1 https://github.com/coreyhaines31/marketingskills.git marketing-skills
git clone --depth 1 https://github.com/czlonkowski/n8n-skills.git n8n-skills
git clone --depth 1 https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering.git context-engineering
git clone --depth 1 https://github.com/alinaqi/claude-bootstrap.git claude-bootstrap
git clone --depth 1 https://github.com/antonbabenko/terraform-skill.git terraform-skill
git clone --depth 1 https://github.com/zxkane/aws-skills.git aws-skills
git clone --depth 1 https://github.com/lackeyjb/playwright-skill.git playwright-skill
git clone --depth 1 https://github.com/ibelick/ui-skills.git ui-skills
git clone --depth 1 https://github.com/wrsmith108/varlock-claude-skill.git varlock-skill
git clone --depth 1 https://github.com/massimodeluisa/recursive-decomposition-skill.git recursive-decomposition
git clone --depth 1 https://github.com/dmmulroy/cloudflare-skill.git dmmulroy-cloudflare
git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git ui-ux-pro-max
git clone --depth 1 https://github.com/SHADOWPR0/security-bluebook-builder.git security-bluebook
git clone --depth 1 https://github.com/SHADOWPR0/beautiful_prose.git beautiful-prose
git clone --depth 1 https://github.com/wrsmith108/linear-claude-skill.git linear-skill
git clone --depth 1 https://github.com/fvadicamo/dev-agent-skills.git dev-agent-skills
git clone --depth 1 https://github.com/ComposioHQ/awesome-claude-skills.git composio-skills
git clone --depth 1 https://github.com/callstackincubator/agent-skills.git callstack-skills
git clone --depth 1 https://github.com/frmoretto/clarity-gate.git clarity-gate
git clone --depth 1 https://github.com/op7418/NanoBanana-PPT-Skills.git nanobanana-ppt
```

### Copy Skills to Correct Locations

The automated script `setup.sh` handles this. The structure is:

```
~/.claude/skills/
  anthropic/       (16 skills) - PDF, DOCX, PPTX, XLSX, frontend-design, etc.
  vercel/          (5 skills)  - React best practices, web design guidelines
  sentry/          (9 skills)  - Code review, commits, PRs, bug finding
  cloudflare/      (9 skills)  - Workers, Wrangler, Durable Objects, web perf
  stripe/          (2 skills)  - Stripe best practices, SDK upgrades
  databases/       (3 skills)  - Supabase Postgres, Neon, Tinybird
  trailofbits/     (47 skills) - Security analysis, fuzzing, static analysis
  obra/            (14 skills) - TDD, debugging, parallel agents, git workflows
  marketing/       (25 skills) - SEO, CRO, copywriting, email, ads
  n8n/             (7 skills)  - n8n automation workflows
  context-engineering/ (13 skills) - Context optimization, multi-agent patterns
  better-auth/     (2 skills)  - Authentication best practices
  huggingface/     (8 skills)  - ML model training, datasets, evaluation
  expo/            (9 skills)  - React Native/Expo development
  bootstrap/       (53 skills) - Project initialization, various tech stacks
  community/       (52 skills) - Playwright, Terraform, AWS, UI/UX, etc.
```

**Total: ~316 skills**

---

## Step 4: Configure MCP Servers

**Important:** All paths must be absolute. The `setup.sh` script resolves these automatically using `$HOME`. JSON config files don't support variables, so `setup.sh` writes the correct absolute paths for the current user at install time.

### For Claude Code (CLI)

Add MCP servers using the `claude mcp add` command with `--scope user` for global availability:

```bash
# Filesystem access (use $HOME — covers all user files)
claude mcp add --transport stdio --scope user filesystem -- npx -y @modelcontextprotocol/server-filesystem "$HOME"

# Persistent memory
claude mcp add --transport stdio --scope user memory -- npx -y @modelcontextprotocol/server-memory

# Web fetching
claude mcp add --transport stdio --scope user fetch -- "$HOME/.local/bin/uvx" mcp-server-fetch

# Browser automation
claude mcp add --transport stdio --scope user puppeteer -- npx -y @modelcontextprotocol/server-puppeteer

# Step-by-step reasoning
claude mcp add --transport stdio --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking

# Git operations
claude mcp add --transport stdio --scope user git -- "$HOME/.local/bin/uvx" mcp-server-git

# Up-to-date library documentation (Context7)
claude mcp add --transport stdio --scope user context7 -- npx -y @upstash/context7-mcp@latest
```

Verify: `claude mcp list`

### For Claude Desktop (macOS only)

Create/edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "<FULL_PATH_TO_NPX>",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "<HOME>"]
    },
    "memory": {
      "command": "<FULL_PATH_TO_NPX>",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "puppeteer": {
      "command": "<FULL_PATH_TO_NPX>",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "fetch": {
      "command": "<HOME>/.local/bin/uvx",
      "args": ["mcp-server-fetch"]
    },
    "sequential-thinking": {
      "command": "<FULL_PATH_TO_NPX>",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "context7": {
      "command": "<FULL_PATH_TO_NPX>",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

**Note:** The git MCP server is excluded from Claude Desktop because it requires a git repository context to function. Claude Desktop doesn't run in project directories, so the git server would constantly error. It's configured only for Claude Code, which operates in project directories.

**Important:** Replace `<FULL_PATH_TO_NPX>` with the actual path (find via `which npx`) and `<HOME>` with the user's home directory (e.g. `/Users/jane` on macOS, `/home/jane` on Linux). Claude Desktop requires absolute paths because it doesn't inherit your shell PATH. The `setup.sh` script handles this automatically.

---

## Step 5: Configure Permissions

The setup script applies the daily-driver permission configuration during install:

- **Auto-approved:** Read, Glob, Grep, WebFetch, WebSearch, all MCP tools, safe Bash patterns (git, npm, node, python3, ls, etc.)
- **Requires approval:** Write, Edit, any Bash command not matching a safe pattern
- **Denied:** rm -rf /, fork bombs, force-push to main/master, git reset --hard, git clean -fd, disk wiping

### How Permissions Work

- **`permissions.allow`**: Tools matching these are pre-approved. Bare names (e.g. `"Read"`) approve all uses. Patterns with parens (e.g. `"Bash(git *)"`) approve specific commands.
- **`permissions.deny`**: Overrides allow rules. Blocks destructive operations.
- **`hooks.PreToolUse`**: Runs before tool execution. Can return `allow`, `deny`, or `ask`. The daily-driver config uses `"mcp__.*"` to catch-all MCP tools (including future servers).
- **MCP servers**: Listed by server name (e.g. `mcp__memory`). The `mcp__.*` hook provides belt-and-suspenders coverage.

### Per-Project Overrides

For projects where you want full autonomy (Write/Edit auto-approved), copy the webdev template:
```bash
cp ~/.claude/setup/webdev-project-settings.json YOUR_PROJECT/.claude/settings.json
```

### Security Notes

- The `deny` list blocks fork bombs, disk wiping, recursive deletion of root/home, and destructive git operations
- Environment files (`.env`) are NOT blocked by default — add `"Read(./.env)"` to deny if needed
- Project-level `.claude/settings.json` can override global settings for specific projects

---

## Step 6: How Hooks Work (Reference)

### Available Hook Events

| Event | When | Use Case |
|-------|------|----------|
| `PreToolUse` | Before any tool runs | Auto-approve, validate, modify input |
| `PostToolUse` | After tool succeeds | Format code, validate output, log |
| `SessionStart` | Session begins | Load environment, set context |
| `Stop` | Claude finishes | Check if all tasks are complete |
| `Notification` | Alert sent | Custom notifications |

### Hook Output Format

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Optional reason",
    "updatedInput": {},
    "additionalContext": "Extra info for Claude"
  }
}
```

### Adding Custom Hooks

To add a custom hook (e.g., auto-format after file edits):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_PROJECT_DIR\"",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

---

## Step 7: Global CLAUDE.md (Behavioral Instructions)

The setup script installs `~/.claude/CLAUDE.md`, which contains global behavioral instructions that Claude reads at the start of every session. This file tells Claude:

- **When and how to use each MCP server** (Context7 for docs, Memory for persistence, Puppeteer for browser tasks, etc.)
- **When to invoke skills proactively** (e.g., use `anthropic:pdf` for PDF tasks, `trailofbits:*` for security audits)
- **Which agents to use** (Explore for codebase search, Plan for architecture, etc.)

The file is maintained in the setup repo as `CLAUDE.md` and copied to `~/.claude/CLAUDE.md` during install. To customize, edit `~/.claude/CLAUDE.md` directly (it will be overwritten on next `setup.sh install`), or edit the source in the setup repo to make changes persistent.

---

## Verification

After setup, verify everything:

```bash
# Check skills count
find ~/.claude/skills -name "SKILL.md" | wc -l
# Expected: ~316

# Check MCP servers
claude mcp list

# Check settings
cat ~/.claude/settings.json | python3 -m json.tool

# Test a skill is readable
head -5 ~/.claude/skills/anthropic/pdf/SKILL.md
```

---

## Maintenance

### Adding New Skills
```bash
# Clone the repo
git clone --depth 1 https://github.com/USER/REPO.git /tmp/new-skill

# Copy SKILL.md to appropriate category
mkdir -p ~/.claude/skills/community/new-skill-name
cp /tmp/new-skill/path/to/SKILL.md ~/.claude/skills/community/new-skill-name/

# Clean up
rm -rf /tmp/new-skill
```

### Adding New MCP Servers
```bash
# For Claude Code
claude mcp add --transport stdio --scope user SERVER_NAME -- COMMAND ARGS

# For Claude Desktop - edit the config file
# ~/Library/Application Support/Claude/claude_desktop_config.json
```

### Updating Skills
```bash
# Re-run install to pull latest versions
bash ~/.claude/setup/setup.sh install
```

### Removing a Skill
```bash
rm -rf ~/.claude/skills/CATEGORY/SKILL_NAME
```

### Removing an MCP Server
```bash
claude mcp remove SERVER_NAME --scope user
```

---

## Skill Categories Quick Reference

| Category | Count | Covers |
|----------|-------|--------|
| anthropic | 16 | Documents (PDF/DOCX/PPTX/XLSX), frontend design, canvas, web artifacts |
| vercel | 5 | React/Next.js best practices, web design, deployment |
| sentry | 9 | Code review, commits, PRs, bug finding, settings audit |
| cloudflare | 9 | Workers, KV, R2, D1, Wrangler, web performance, agents |
| stripe | 2 | Payment integration best practices, SDK upgrades |
| databases | 3 | Supabase Postgres, Neon Serverless, Tinybird analytics |
| trailofbits | 47 | Security auditing, fuzzing, static analysis, smart contracts |
| obra | 14 | TDD, debugging, parallel agents, git workflows, code review |
| marketing | 25 | SEO, CRO, copywriting, email sequences, A/B testing, ads |
| n8n | 7 | Workflow automation, node configuration, validation |
| context-eng | 13 | Context optimization, multi-agent patterns, memory systems |
| better-auth | 2 | Authentication setup and best practices |
| huggingface | 8 | ML model training, datasets, evaluation, CLI |
| expo | 9 | React Native/Expo app design, deployment, upgrades |
| bootstrap | 53 | Project init for React, Node, Python, Flutter, Supabase, AWS, etc. |
| community | 52 | Playwright, Terraform, AWS, UI/UX, Linear, security, prose |

---

## MCP Servers Quick Reference

| Server | Transport | Where | Purpose |
|--------|-----------|-------|---------|
| filesystem | npx (stdio) | Code + Desktop | Read/write files in user's home directory |
| memory | npx (stdio) | Code + Desktop | Persistent knowledge graph across sessions |
| fetch | uvx (stdio) | Code + Desktop | Fetch and extract content from URLs |
| puppeteer | npx (stdio) | Code + Desktop | Browser automation, screenshots, page interaction |
| sequential-thinking | npx (stdio) | Code + Desktop | Step-by-step reasoning for complex problems |
| git | uvx (stdio) | Code only | Git operations (status, diff, log, commit) |
| context7 | npx (stdio) | Code + Desktop | Up-to-date library/framework documentation |
