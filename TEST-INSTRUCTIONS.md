# Claude Code Setup - Test Instructions

Run these tests to verify the full setup is working. Report results in a summary table at the end.

**IMPORTANT: This test suite is gated. You MUST complete Step 1 first and wait for user confirmation before proceeding to any other tests.**

**NOTE: These tests run AFTER `setup.sh install` (Phase 2) and BEFORE `setup.sh finalize` (Phase 3). At this point, permissions are still permissive — all tools should auto-approve. After tests pass, the user runs `setup.sh finalize` to lock down to daily-driver mode.**

## 1. Hooks Test (GATE — must pass before continuing)

Run these 4 tool calls to check if permissions are auto-approving correctly:

1. `Bash`: Run `echo "hooks test"`
2. `Read`: Read `~/.claude/settings.local.json`
3. `mcp__filesystem__list_directory` on the user's home directory
4. `mcp__memory__read_graph` (tests a second MCP server)

After running all 4, report how many permission prompts appeared and **ask the user to confirm**:
- If user confirms 0 prompts → proceed to remaining tests
- If user reports any prompts → STOP. Do NOT continue. Help debug the permissions issue instead.

## 2. MCP Server Tests

Test each of the 6 MCP servers with a real call:

| Server | Test |
|--------|------|
| filesystem | `mcp__filesystem__list_directory` on the user's home directory |
| memory | `mcp__memory__read_graph` (read the knowledge graph) |
| fetch | `mcp__fetch__fetch` on `https://httpbin.org/get` |
| puppeteer | `mcp__puppeteer__puppeteer_navigate` to `https://example.com`, then take a screenshot |
| sequential-thinking | `mcp__sequential-thinking__sequentialthinking` with a simple test thought |
| git | `mcp__git__git_status` on a repo in ~/Projects (find one first) |

## 3. Built-in Tool Tests

Test each built-in tool (all should auto-approve in permissive mode):

- **Bash**: Run `echo "hello from bash"` and `ls ~`
- **Read**: Read `~/.claude/settings.local.json`
- **Glob**: Search for `**/*.json` in `~/.claude/setup/`
- **Grep**: Search for "mcp__memory" in `~/.claude/settings.local.json`
- **WebFetch**: Fetch `https://example.com`
- **WebSearch**: Search for "claude code hooks documentation"
- **Write**: Write a temp file `/tmp/claude-test.txt` with "test"
- **Edit**: Edit `/tmp/claude-test.txt` to change "test" to "test passed", then delete it

## 4. Skills Verification

- Count total SKILL.md files: `find ~/.claude/skills -name "SKILL.md" | wc -l`
- Expected: 316
- List the skill categories: `ls ~/.claude/skills/`
- Expected 16 categories: anthropic, better-auth, bootstrap, cloudflare, community, context-engineering, databases, expo, huggingface, marketing, n8n, obra, sentry, stripe, trailofbits, vercel

## 5. Pre-Finalize Settings Verification

Verify the current state (permissive mode, post-install):
- `~/.claude/settings.json` is `{}` (empty)
- `~/.claude/settings.local.json` EXISTS and contains permissive permissions:
  - Bare `"Bash"` IS in `permissions.allow`
  - `"Write"` and `"Edit"` ARE in `permissions.allow`
  - All 7 MCP servers are in `permissions.allow` (mcp__memory, mcp__filesystem, mcp__puppeteer, mcp__git, mcp__fetch, mcp__sequential-thinking, mcp__mcp-registry)
  - `permissions.deny` has 6 safety entries
- `~/.claude/setup/.phase1-complete` EXISTS (removed by finalize)

## 6. Setup Files Verification

Check these exist in `~/.claude/setup/`:
- `setup.sh` (executable)
- `CLAUDE-SETUP.md`
- `webdev-project-settings.json`
- `TEST-INSTRUCTIONS.md` (this file)

Verify `setup.sh` uses `$HOME_DIR` (not hardcoded usernames) for filesystem MCP paths.
Verify `setup.sh` accepts `bootstrap`, `install`, and `finalize` subcommands (run with no args to see usage).

## 7. Task Agent Test

Use the Task tool to spawn an Explore subagent to answer: "What skill categories exist in ~/.claude/skills and how many skills does each have?"

This tests that subagent spawning works.

## 8. Post-Finalize Verification (run AFTER `setup.sh finalize`)

After the user runs `bash ~/.claude/setup/setup.sh finalize` and restarts Claude Code, verify:

Read `~/.claude/settings.json` and verify:
- `Write` is NOT in `permissions.allow`
- `Edit` is NOT in `permissions.allow`
- Bare `"Bash"` is NOT in `permissions.allow` (only `Bash(pattern)` entries)
- `Read`, `Glob`, `Grep`, `WebFetch`, `WebSearch` ARE in `permissions.allow`
- All 7 MCP servers are in `permissions.allow` (mcp__memory, mcp__filesystem, mcp__puppeteer, mcp__git, mcp__fetch, mcp__sequential-thinking, mcp__mcp-registry)
- `permissions.deny` has 10 entries (6 original + git push --force main/master, git reset --hard, git clean -fd)
- `hooks.PreToolUse` has 1 entry with `"matcher": "mcp__.*"` (NOT `"*"`)

Read `~/.claude/settings.local.json` and verify:
- Contains `permissions.allow` with the same entries as `settings.json` (MCP servers, Bash patterns, Read/Glob/Grep/WebFetch/WebSearch)
- Does NOT contain `Write`, `Edit`, bare `Bash`, hooks, or deny rules

Other checks:
- `~/.claude/setup/.phase1-complete` does NOT exist

## Results Template

After all tests (steps 1-7), report results like this:

```
SETUP TEST RESULTS (Post-Install, Pre-Finalize)
================================================
Permission prompts received: X (target: 0 for all tools in permissive mode)

MCP Servers (6/6):
  filesystem:          PASS/FAIL
  memory:              PASS/FAIL
  fetch:               PASS/FAIL
  puppeteer:           PASS/FAIL
  sequential-thinking: PASS/FAIL
  git:                 PASS/FAIL

Built-in Tools (8/8):
  Bash:       PASS/FAIL
  Read:       PASS/FAIL
  Glob:       PASS/FAIL
  Grep:       PASS/FAIL
  WebFetch:   PASS/FAIL
  WebSearch:  PASS/FAIL
  Write:      PASS/FAIL
  Edit:       PASS/FAIL

Skills: X/316
Categories: X/16
Pre-finalize settings: PASS/FAIL
Setup files: PASS/FAIL
Task agent: PASS/FAIL

NEXT: Run `bash ~/.claude/setup/setup.sh finalize` then restart Claude Code.
```
