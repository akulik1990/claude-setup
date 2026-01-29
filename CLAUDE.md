# Global Instructions

## MCP Servers

### Context7 - Documentation Lookup
Always use Context7 MCP tools (`mcp__context7__resolve-library-id` and `mcp__context7__get-library-docs`) proactively when you need library/API documentation, code generation help, setup or configuration steps, or troubleshooting for any programming library or framework. Do not wait for the user to say "use context7" - fetch up-to-date documentation whenever it would improve the quality of your response.

### Memory - Persistent Knowledge Graph
Use the Memory MCP (`mcp__memory__*`) to persist important information across sessions:
- `create_entities` / `create_relations` - Store user preferences, project details, decisions, and relationships between concepts.
- `search_nodes` / `open_nodes` - Recall previously stored context before starting work on a project.
- `add_observations` - Append new facts to existing entities as you learn more.
- Proactively store key decisions, architectural choices, and user preferences so they survive across sessions. When starting work on a known project, search memory first to recall prior context.

### Filesystem - File Operations
Use the Filesystem MCP (`mcp__filesystem__*`) for file and directory operations:
- `read_text_file` / `read_multiple_files` - Read file contents.
- `write_file` / `edit_file` - Create or modify files.
- `list_directory` / `directory_tree` - Explore directory structures.
- `search_files` - Find files by glob pattern.
- `move_file` / `create_directory` - Organize files and folders.
- `get_file_info` - Check file metadata (size, timestamps, permissions).

### Git - Repository Operations
Use the Git MCP (`mcp__git__*`) for version control:
- `git_status` / `git_diff_unstaged` / `git_diff_staged` - Inspect working tree state.
- `git_add` / `git_commit` - Stage and commit changes.
- `git_log` / `git_show` - View commit history and details.
- `git_branch` / `git_create_branch` / `git_checkout` - Branch management.
- `git_diff` - Compare branches or commits.

### Fetch - Web Content Retrieval
Use the Fetch MCP (`mcp__fetch__fetch`) to retrieve and read web content. Useful for fetching documentation pages, API responses, or any URL content. Prefer this over the built-in WebFetch when you need raw markdown output or when WebFetch has restrictions.

### Puppeteer - Browser Automation
Use the Puppeteer MCP (`mcp__puppeteer__*`) for browser-based tasks:
- `puppeteer_navigate` - Open a URL in a headless browser.
- `puppeteer_screenshot` - Capture screenshots of pages or elements.
- `puppeteer_click` / `puppeteer_fill` / `puppeteer_select` - Interact with page elements.
- `puppeteer_evaluate` - Execute JavaScript in the browser console.
- Use this for testing web UIs, scraping dynamic content, or debugging visual issues.

### Sequential Thinking - Structured Problem Solving
Use Sequential Thinking MCP (`mcp__sequential-thinking__sequentialthinking`) for complex problems that benefit from step-by-step reasoning:
- Break down multi-step problems with room for revision.
- Plan and design with the ability to branch, backtrack, or revise earlier thoughts.
- Generate and verify solution hypotheses.
- Use when a problem requires careful analysis, multiple considerations, or when the full scope isn't immediately clear.

### MCP Registry - Connector Discovery
Use the MCP Registry (`mcp__mcp-registry__*`) when the user asks about connecting to external services:
- `search_mcp_registry` - Search for available MCP connectors by keyword.
- `suggest_connectors` - Present unconnected services with Connect buttons.

## Agents (Task Tool)

Use the Task tool with these specialized `subagent_type` values:

- **Explore** - Fast codebase exploration. Use for finding files by pattern, searching code for keywords, or answering questions about codebase structure. Specify thoroughness: "quick", "medium", or "very thorough".
- **Plan** - Software architect agent. Use for designing implementation strategies, identifying critical files, and considering trade-offs. Returns step-by-step plans.
- **Bash** - Command execution specialist. Use for git operations, running builds, and other terminal tasks.
- **general-purpose** - Multi-step research and task execution. Use when a search may require multiple rounds of exploration.

Prefer the **Explore** agent over direct Glob/Grep for open-ended codebase questions. Use **Plan** agent before implementing complex features. Launch multiple agents in parallel when tasks are independent.

## Skills (Slash Commands)

Skills are invoked via the Skill tool (or the user typing `/skillname`). There are 317 skills installed across 17 providers in `~/.claude/skills/`. Use the most relevant skill when its domain matches the task. Key providers and when to use them:

### anthropic/
Document processing and design. Use for:
- `/anthropic:pdf`, `/anthropic:docx`, `/anthropic:pptx`, `/anthropic:xlsx` - Processing and manipulating Office/PDF documents.
- `/anthropic:frontend-design`, `/anthropic:canvas-design` - UI and visual design tasks.
- `/anthropic:mcp-builder` - Building new MCP servers.
- `/anthropic:skill-creator` - Creating new skills.

### bootstrap/
Large collection of development patterns. Use for:
- AI/LLM integration patterns, agentic development.
- Database setup (Aurora, DynamoDB, CosmosDB, etc.).
- Framework scaffolding (React, React Native, Flutter).
- Development practices (code review, testing, security).

### cloudflare/
Cloudflare-specific development. Use for:
- `/cloudflare:agents-sdk` - Building AI agents on Cloudflare.
- Workers, Durable Objects, Wrangler deployment.
- Web performance optimization.

### community/
Largest collection (94 skills). Use for:
- Google services integration (Docs, Sheets, Drive, Gmail, Calendar).
- Code operations (refactoring, auditing, execution).
- Task management (Linear, Notion).
- Browser/UI testing.

### context-engineering/
Advanced context and memory management. Use for:
- Optimizing context windows and prompt engineering.
- Multi-agent coordination patterns.
- Memory system design.

### databases/
Database-specific skills. Use for:
- `/databases:supabase` - Supabase/PostgreSQL.
- `/databases:neon` - Neon serverless Postgres.
- `/databases:tinybird` - Tinybird analytics.

### expo/
React Native / Expo development. Use for:
- Expo project setup, CI/CD, deployment.
- Tailwind CSS configuration for React Native.

### huggingface/
ML/AI model workflows. Use for:
- Model training and fine-tuning.
- Dataset management, paper publishing.

### n8n/
Workflow automation. Use for:
- Building n8n workflows and automations.
- Code execution nodes (JavaScript, Python).

### obra/
Development workflow and collaboration. Use for:
- Brainstorming, parallel agent coordination.
- Git worktrees, TDD, systematic debugging.

### sentry/
Error tracking and code quality. Use for:
- Code review with Sentry conventions.
- Commit messages and PR workflows.

### stripe/
Payment integration. Use for:
- Stripe best practices and upgrade guides.

### trailofbits/
Security auditing and analysis (96 skills). Use for:
- Vulnerability scanning (Solana, Algorand, Cosmos, etc.).
- Fuzzing (AFL++, LibFuzzer, libAFL).
- Static analysis (Semgrep, CodeQL).
- Security workflows and pen-testing support.

### vercel/
Vercel deployment and React patterns. Use for:
- React best practices, composition patterns.
- Web design guidelines, Vercel deployment.

### When to invoke a skill
- When the user explicitly types a slash command (e.g., `/commit`, `/pdf`).
- Proactively when a task clearly falls within a skill's domain (e.g., use `anthropic:pdf` when asked to work with PDFs, use `trailofbits:*` for security audits, use `databases:supabase` when setting up Supabase).
- When you need specialized domain knowledge that a skill provides over general reasoning.
