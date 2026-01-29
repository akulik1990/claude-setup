#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Claude Code & Claude Desktop - Setup Script
# ============================================================
# Single-command setup: applies daily-driver permissions,
# installs skills and MCP servers.
#
# Usage:
#   git clone https://github.com/akulik1990/claude-setup.git ~/.claude/setup
#   bash ~/.claude/setup/setup.sh install
#   # Restart Claude Code
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
SKILLS_DIR="$HOME_DIR/.claude/skills"
SETUP_DIR="$HOME_DIR/.claude/setup"
SETTINGS_FILE="$HOME_DIR/.claude/settings.json"
LOCAL_SETTINGS_FILE="$HOME_DIR/.claude/settings.local.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERR]${NC} $1"; }
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }

# -----------------------------------------------------------
# usage()
# -----------------------------------------------------------
usage() {
  echo ""
  echo "Usage: setup.sh <command>"
  echo ""
  echo "Commands:"
  echo "  install     Full setup: apply permissions, install skills, configure MCP servers"
  echo ""
  echo "Quick start:"
  echo "  1. git clone https://github.com/akulik1990/claude-setup.git ~/.claude/setup"
  echo "  2. bash ~/.claude/setup/setup.sh install"
  echo "  3. Restart Claude Code"
  echo ""
}

# -----------------------------------------------------------
# check_prereqs()
# -----------------------------------------------------------
check_prereqs() {
  info "Checking prerequisites..."

  # Node.js
  if command -v node &>/dev/null; then
    log "Node.js $(node --version)"
  else
    err "Node.js not found. Install it first: https://nodejs.org"
    exit 1
  fi

  # npx
  if command -v npx &>/dev/null; then
    NPX_PATH=$(which npx)
    log "npx found at $NPX_PATH"
  else
    err "npx not found"
    exit 1
  fi

  # Python
  if command -v python3 &>/dev/null; then
    log "Python $(python3 --version 2>&1)"
  else
    err "Python 3 not found"
    exit 1
  fi

  # Git
  if command -v git &>/dev/null; then
    log "Git $(git --version)"
  else
    err "Git not found"
    exit 1
  fi

  # Claude Code
  if command -v claude &>/dev/null; then
    log "Claude Code $(claude --version 2>&1 | head -1)"
  else
    warn "Claude Code CLI not found. Install: npm install -g @anthropic-ai/claude-code"
  fi
}

# -----------------------------------------------------------
# do_install()
# -----------------------------------------------------------
do_install() {
  echo ""
  echo "============================================"
  echo "  Claude Code Setup"
  echo "============================================"
  echo ""

  # -----------------------------------------------------------
  # Apply daily-driver permissions upfront
  # -----------------------------------------------------------
  info "Applying daily-driver permissions..."
  cp "$SCRIPT_DIR/settings-daily-driver.json" "$SETTINGS_FILE"
  log "settings.json written"
  cp "$SCRIPT_DIR/settings-daily-driver-local.json" "$LOCAL_SETTINGS_FILE"
  log "settings.local.json written"

  # -----------------------------------------------------------
  # Check Prerequisites
  # -----------------------------------------------------------
  check_prereqs

  # -----------------------------------------------------------
  # Install uv/uvx
  # -----------------------------------------------------------
  info "Installing uv/uvx..."
  if command -v uvx &>/dev/null; then
    log "uvx already installed: $(uvx --version 2>&1)"
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME_DIR/.local/bin:$PATH"
    if command -v uvx &>/dev/null; then
      log "uvx installed: $(uvx --version 2>&1)"
    else
      warn "uvx install may need shell restart. Adding to PATH."
      source "$HOME_DIR/.local/bin/env" 2>/dev/null || true
    fi
  fi

  UVX_PATH="${HOME_DIR}/.local/bin/uvx"

  # -----------------------------------------------------------
  # Create Directory Structure
  # -----------------------------------------------------------
  info "Creating directory structure..."
  mkdir -p "$SKILLS_DIR"/{anthropic,vercel,sentry,cloudflare,stripe,databases,trailofbits,obra,marketing,n8n,context-engineering,better-auth,huggingface,expo,bootstrap,community}
  mkdir -p "$HOME_DIR/.claude/commands"
  mkdir -p "$SETUP_DIR"
  log "Directory structure created"

  # -----------------------------------------------------------
  # Clone Skill Repositories
  # -----------------------------------------------------------
  info "Cloning skill repositories (this may take a moment)..."
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"

  REPOS=(
    "anthropics/skills.git|anthropics-skills"
    "vercel-labs/agent-skills.git|vercel-skills"
    "getsentry/skills.git|sentry-skills"
    "cloudflare/skills.git|cloudflare-skills"
    "stripe/ai.git|stripe-skills"
    "supabase/agent-skills.git|supabase-skills"
    "neondatabase/agent-skills.git|neon-skills"
    "trailofbits/skills.git|trailofbits-skills"
    "better-auth/skills.git|better-auth-skills"
    "huggingface/skills.git|huggingface-skills"
    "expo/skills.git|expo-skills"
    "tinybirdco/tinybird-agent-skills.git|tinybird-skills"
    "obra/superpowers.git|obra-superpowers"
    "coreyhaines31/marketingskills.git|marketing-skills"
    "czlonkowski/n8n-skills.git|n8n-skills"
    "muratcankoylan/Agent-Skills-for-Context-Engineering.git|context-engineering"
    "alinaqi/claude-bootstrap.git|claude-bootstrap"
    "antonbabenko/terraform-skill.git|terraform-skill"
    "zxkane/aws-skills.git|aws-skills"
    "lackeyjb/playwright-skill.git|playwright-skill"
    "ibelick/ui-skills.git|ui-skills"
    "wrsmith108/varlock-claude-skill.git|varlock-skill"
    "massimodeluisa/recursive-decomposition-skill.git|recursive-decomposition"
    "dmmulroy/cloudflare-skill.git|dmmulroy-cloudflare"
    "nextlevelbuilder/ui-ux-pro-max-skill.git|ui-ux-pro-max"
    "SHADOWPR0/security-bluebook-builder.git|security-bluebook"
    "SHADOWPR0/beautiful_prose.git|beautiful-prose"
    "wrsmith108/linear-claude-skill.git|linear-skill"
    "fvadicamo/dev-agent-skills.git|dev-agent-skills"
    "ComposioHQ/awesome-claude-skills.git|composio-skills"
    "callstackincubator/agent-skills.git|callstack-skills"
    "frmoretto/clarity-gate.git|clarity-gate"
    "op7418/NanoBanana-PPT-Skills.git|nanobanana-ppt"
    "Prat011/awesome-llm-skills.git|prat-skills"
    "smerchek/claude-epub-skill.git|epub-skill"
    "chrisvoncsefalvay/claude-d3js-skill.git|d3js-skill"
    "coffeefuelbump/csv-data-summarizer-claude-skill.git|csv-summarizer"
    "michalparkola/tapestry-skills-for-claude-code.git|tapestry-skills"
    "mhattingpete/claude-skills-marketplace.git|marketplace-skills"
    "sanjay3290/ai-skills.git|sanjay-skills"
    "yusufkaraaslan/Skill_Seekers.git|skill-seekers"
    "emaynard/claude-family-history-research-skill.git|family-history"
    "conorluddy/ios-simulator-skill.git|ios-simulator"
    "PleasePrompto/notebooklm-skill.git|notebooklm"
  )

  clone_count=0
  for repo_entry in "${REPOS[@]}"; do
    IFS='|' read -r repo dirname <<< "$repo_entry"
    if [ ! -d "$dirname" ]; then
      git clone --depth 1 "https://github.com/$repo" "$dirname" 2>/dev/null && \
        clone_count=$((clone_count + 1)) || \
        warn "Failed to clone $repo"
    fi
  done
  log "Cloned $clone_count repositories"

  # -----------------------------------------------------------
  # Copy Skills to ~/.claude/skills/
  # -----------------------------------------------------------
  info "Installing skills..."

  copy_skills() {
    local src_pattern="$1"
    local dest_category="$2"

    find $src_pattern -name "SKILL.md" 2>/dev/null | while read skill_file; do
      skill_name=$(basename "$(dirname "$skill_file")")
      if [ "$skill_name" = "skills" ] || [ "$skill_name" = "." ]; then
        skill_name=$(basename "$(dirname "$(dirname "$skill_file")")")
      fi
      mkdir -p "$SKILLS_DIR/$dest_category/$skill_name"
      cp "$skill_file" "$SKILLS_DIR/$dest_category/$skill_name/" 2>/dev/null
    done
  }

  # Anthropic
  for d in "$TMPDIR"/anthropics-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/anthropic/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/anthropic/$name/" 2>/dev/null || true
  done

  # Vercel
  for d in "$TMPDIR"/vercel-skills/skills/*/; do
    name=$(basename "$d")
    if [ "$name" = "claude.ai" ]; then
      for sub in "$d"*/; do
        sname=$(basename "$sub")
        mkdir -p "$SKILLS_DIR/vercel/$sname"
        cp "$sub"SKILL.md "$SKILLS_DIR/vercel/$sname/" 2>/dev/null || true
      done
    else
      mkdir -p "$SKILLS_DIR/vercel/$name"
      cp "$d"SKILL.md "$SKILLS_DIR/vercel/$name/" 2>/dev/null || true
    fi
  done

  # Sentry
  for d in "$TMPDIR"/sentry-skills/plugins/sentry-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/sentry/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/sentry/$name/" 2>/dev/null || true
  done

  # Cloudflare
  for d in "$TMPDIR"/cloudflare-skills/*/; do
    name=$(basename "$d")
    [ -f "$d"SKILL.md ] && mkdir -p "$SKILLS_DIR/cloudflare/$name" && cp "$d"SKILL.md "$SKILLS_DIR/cloudflare/$name/" 2>/dev/null || true
  done
  mkdir -p "$SKILLS_DIR/cloudflare/cloudflare-comprehensive"
  cp "$TMPDIR"/dmmulroy-cloudflare/skills/cloudflare/SKILL.md "$SKILLS_DIR/cloudflare/cloudflare-comprehensive/" 2>/dev/null || true

  # Stripe
  for d in "$TMPDIR"/stripe-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/stripe/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/stripe/$name/" 2>/dev/null || true
  done

  # Databases
  mkdir -p "$SKILLS_DIR/databases"/{supabase-postgres,neon,tinybird}
  cp "$TMPDIR"/supabase-skills/skills/supabase-postgres-best-practices/SKILL.md "$SKILLS_DIR/databases/supabase-postgres/" 2>/dev/null || true
  cp "$TMPDIR"/neon-skills/skills/using-neon/SKILL.md "$SKILLS_DIR/databases/neon/" 2>/dev/null || true
  cp "$TMPDIR"/tinybird-skills/skills/tinybird-best-practices/SKILL.md "$SKILLS_DIR/databases/tinybird/" 2>/dev/null || true

  # Trail of Bits
  for plugin_dir in "$TMPDIR"/trailofbits-skills/plugins/*/; do
    find "$plugin_dir" -name "SKILL.md" | while read sf; do
      sn=$(basename "$(dirname "$sf")")
      [ "$sn" = "skills" ] && sn=$(basename "$plugin_dir")
      mkdir -p "$SKILLS_DIR/trailofbits/$sn"
      cp "$sf" "$SKILLS_DIR/trailofbits/$sn/" 2>/dev/null || true
    done
  done

  # Obra Superpowers
  for d in "$TMPDIR"/obra-superpowers/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/obra/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/obra/$name/" 2>/dev/null || true
  done

  # Marketing
  for d in "$TMPDIR"/marketing-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/marketing/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/marketing/$name/" 2>/dev/null || true
  done

  # n8n
  for d in "$TMPDIR"/n8n-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/n8n/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/n8n/$name/" 2>/dev/null || true
  done

  # Context Engineering
  for d in "$TMPDIR"/context-engineering/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/context-engineering/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/context-engineering/$name/" 2>/dev/null || true
  done

  # Better Auth
  for d in "$TMPDIR"/better-auth-skills/better-auth/*/; do
    name=$(basename "$d")
    [ -f "$d"SKILL.md ] && mkdir -p "$SKILLS_DIR/better-auth/$name" && cp "$d"SKILL.md "$SKILLS_DIR/better-auth/$name/" 2>/dev/null || true
  done

  # Hugging Face
  for d in "$TMPDIR"/huggingface-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/huggingface/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/huggingface/$name/" 2>/dev/null || true
  done

  # Expo
  find "$TMPDIR"/expo-skills -name "SKILL.md" | while read sf; do
    sn=$(basename "$(dirname "$sf")")
    mkdir -p "$SKILLS_DIR/expo/$sn"
    cp "$sf" "$SKILLS_DIR/expo/$sn/" 2>/dev/null || true
  done

  # Bootstrap
  for d in "$TMPDIR"/claude-bootstrap/skills/*/; do
    name=$(basename "$d")
    [ -f "$d"SKILL.md ] && mkdir -p "$SKILLS_DIR/bootstrap/$name" && cp "$d"SKILL.md "$SKILLS_DIR/bootstrap/$name/" 2>/dev/null || true
  done

  # Community (all remaining)
  community_repos=(
    "playwright-skill/skills/playwright-skill|playwright"
    "varlock-skill/skills/varlock|varlock"
    "recursive-decomposition/plugins/recursive-decomposition/skills/recursive-decomposition|recursive-decomposition"
    "terraform-skill|terraform"
    "security-bluebook|security-bluebook"
    "beautiful-prose|beautiful-prose"
    "linear-skill|linear"
    "clarity-gate/skills/clarity-gate|clarity-gate"
    "nanobanana-ppt|nanobanana-ppt"
    "ui-ux-pro-max/.claude/skills/ui-ux-pro-max|ui-ux-pro-max"
  )

  for entry in "${community_repos[@]}"; do
    IFS='|' read -r src dest <<< "$entry"
    if [ -f "$TMPDIR/$src/SKILL.md" ]; then
      mkdir -p "$SKILLS_DIR/community/$dest"
      cp "$TMPDIR/$src/SKILL.md" "$SKILLS_DIR/community/$dest/" 2>/dev/null || true
    fi
  done

  # UI Skills (ibelick)
  for d in "$TMPDIR"/ui-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/community/ui-$name"
    cp "$d"SKILL.md "$SKILLS_DIR/community/ui-$name/" 2>/dev/null || true
  done

  # AWS Skills
  find "$TMPDIR"/aws-skills -name "SKILL.md" | while read sf; do
    sn=$(basename "$(dirname "$sf")")
    mkdir -p "$SKILLS_DIR/community/aws-$sn"
    cp "$sf" "$SKILLS_DIR/community/aws-$sn/" 2>/dev/null || true
  done

  # Dev Agent Skills
  for d in "$TMPDIR"/dev-agent-skills/skills/*/; do
    name=$(basename "$d")
    mkdir -p "$SKILLS_DIR/community/$name"
    cp "$d"SKILL.md "$SKILLS_DIR/community/$name/" 2>/dev/null || true
  done

  # Composio Skills
  for d in "$TMPDIR"/composio-skills/*/; do
    name=$(basename "$d")
    [ -f "$d"SKILL.md ] && [ "$name" != "template-skill" ] && \
      mkdir -p "$SKILLS_DIR/community/composio-$name" && \
      cp "$d"SKILL.md "$SKILLS_DIR/community/composio-$name/" 2>/dev/null || true
  done

  # Callstack
  find "$TMPDIR"/callstack-skills -name "SKILL.md" | while read sf; do
    sn=$(basename "$(dirname "$sf")")
    mkdir -p "$SKILLS_DIR/community/callstack-$sn"
    cp "$sf" "$SKILLS_DIR/community/callstack-$sn/" 2>/dev/null || true
  done

  # ---- From awesome-llm-skills repo (Prat011) ----

  # Prat011 local skills
  for d in "$TMPDIR"/prat-skills/*/; do
    name=$(basename "$d")
    if [ -f "$d"SKILL.md ] && [ "$name" != "template-skill" ]; then
      if [ ! -f "$SKILLS_DIR/anthropic/$name/SKILL.md" ] && \
         [ ! -f "$SKILLS_DIR/community/$name/SKILL.md" ] && \
         [ ! -f "$SKILLS_DIR/community/composio-$name/SKILL.md" ]; then
        mkdir -p "$SKILLS_DIR/community/$name"
        cp "$d"SKILL.md "$SKILLS_DIR/community/$name/" 2>/dev/null || true
      fi
    fi
  done

  # EPUB skill
  [ -f "$TMPDIR/epub-skill/SKILL.md" ] && mkdir -p "$SKILLS_DIR/community/epub-converter" && \
    cp "$TMPDIR/epub-skill/SKILL.md" "$SKILLS_DIR/community/epub-converter/" 2>/dev/null || true

  # D3.js skill
  find "$TMPDIR"/d3js-skill -name "SKILL.md" 2>/dev/null | head -1 | while read sf; do
    mkdir -p "$SKILLS_DIR/community/d3js-visualization"
    cp "$sf" "$SKILLS_DIR/community/d3js-visualization/" 2>/dev/null || true
  done

  # CSV summarizer
  find "$TMPDIR"/csv-summarizer -name "SKILL.md" 2>/dev/null | head -1 | while read sf; do
    mkdir -p "$SKILLS_DIR/community/csv-data-summarizer"
    cp "$sf" "$SKILLS_DIR/community/csv-data-summarizer/" 2>/dev/null || true
  done

  # Tapestry skills
  find "$TMPDIR"/tapestry-skills -name "SKILL.md" 2>/dev/null | while read sf; do
    sn=$(basename "$(dirname "$sf")")
    mkdir -p "$SKILLS_DIR/community/tapestry-$sn"
    cp "$sf" "$SKILLS_DIR/community/tapestry-$sn/" 2>/dev/null || true
  done

  # Marketplace skills (forensics, engineering workflow)
  find "$TMPDIR"/marketplace-skills -name "SKILL.md" 2>/dev/null | while read sf; do
    sn=$(basename "$(dirname "$sf")")
    [ ! -f "$SKILLS_DIR/community/$sn/SKILL.md" ] && \
      mkdir -p "$SKILLS_DIR/community/$sn" && \
      cp "$sf" "$SKILLS_DIR/community/$sn/" 2>/dev/null || true
  done

  # Sanjay skills (postgres, imagen, google integrations, deep-research)
  find "$TMPDIR"/sanjay-skills -name "SKILL.md" 2>/dev/null | while read sf; do
    sn=$(basename "$(dirname "$sf")")
    [ ! -f "$SKILLS_DIR/community/$sn/SKILL.md" ] && \
      mkdir -p "$SKILLS_DIR/community/$sn" && \
      cp "$sf" "$SKILLS_DIR/community/$sn/" 2>/dev/null || true
  done

  # Skill Seekers
  find "$TMPDIR"/skill-seekers -name "SKILL.md" 2>/dev/null | head -1 | while read sf; do
    mkdir -p "$SKILLS_DIR/community/skill-seekers"
    cp "$sf" "$SKILLS_DIR/community/skill-seekers/" 2>/dev/null || true
  done

  # Family History
  find "$TMPDIR"/family-history -name "SKILL.md" 2>/dev/null | head -1 | while read sf; do
    mkdir -p "$SKILLS_DIR/community/family-history-research"
    cp "$sf" "$SKILLS_DIR/community/family-history-research/" 2>/dev/null || true
  done

  # iOS Simulator
  find "$TMPDIR"/ios-simulator -name "SKILL.md" 2>/dev/null | head -1 | while read sf; do
    mkdir -p "$SKILLS_DIR/community/ios-simulator"
    cp "$sf" "$SKILLS_DIR/community/ios-simulator/" 2>/dev/null || true
  done

  # NotebookLM
  find "$TMPDIR"/notebooklm -name "SKILL.md" 2>/dev/null | head -1 | while read sf; do
    mkdir -p "$SKILLS_DIR/community/notebooklm"
    cp "$sf" "$SKILLS_DIR/community/notebooklm/" 2>/dev/null || true
  done

  TOTAL_SKILLS=$(find "$SKILLS_DIR" -name "SKILL.md" | wc -l | tr -d ' ')
  log "Installed $TOTAL_SKILLS skills"

  # -----------------------------------------------------------
  # Configure MCP Servers for Claude Code
  # -----------------------------------------------------------
  info "Configuring MCP servers for Claude Code..."

  if command -v claude &>/dev/null; then
    # Remove existing servers first (ignore errors)
    for server in filesystem memory fetch puppeteer sequential-thinking git context7; do
      claude mcp remove "$server" --scope user 2>/dev/null || true
    done

    claude mcp add --transport stdio --scope user filesystem -- npx -y @modelcontextprotocol/server-filesystem "$HOME_DIR" 2>/dev/null && log "Added filesystem MCP" || warn "Failed to add filesystem MCP"
    claude mcp add --transport stdio --scope user memory -- npx -y @modelcontextprotocol/server-memory 2>/dev/null && log "Added memory MCP" || warn "Failed to add memory MCP"
    claude mcp add --transport stdio --scope user fetch -- "$UVX_PATH" mcp-server-fetch 2>/dev/null && log "Added fetch MCP" || warn "Failed to add fetch MCP"
    claude mcp add --transport stdio --scope user puppeteer -- npx -y @modelcontextprotocol/server-puppeteer 2>/dev/null && log "Added puppeteer MCP" || warn "Failed to add puppeteer MCP"
    claude mcp add --transport stdio --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking 2>/dev/null && log "Added sequential-thinking MCP" || warn "Failed to add sequential-thinking MCP"
    claude mcp add --transport stdio --scope user git -- "$UVX_PATH" mcp-server-git 2>/dev/null && log "Added git MCP" || warn "Failed to add git MCP"
    claude mcp add --transport stdio --scope user context7 -- npx -y @upstash/context7-mcp@latest 2>/dev/null && log "Added context7 MCP" || warn "Failed to add context7 MCP"
  else
    warn "Claude Code CLI not found - skipping MCP server setup for CLI"
  fi

  # -----------------------------------------------------------
  # Configure MCP Servers for Claude Desktop
  # -----------------------------------------------------------
  info "Configuring MCP servers for Claude Desktop..."

  DESKTOP_CONFIG_DIR="$HOME_DIR/Library/Application Support/Claude"
  if [ -d "$DESKTOP_CONFIG_DIR" ] || [ "$(uname)" = "Darwin" ]; then
    mkdir -p "$DESKTOP_CONFIG_DIR"
    cat > "$DESKTOP_CONFIG_DIR/claude_desktop_config.json" << DESKTOPEOF
{
  "mcpServers": {
    "filesystem": {
      "command": "$NPX_PATH",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$HOME_DIR"]
    },
    "memory": {
      "command": "$NPX_PATH",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "puppeteer": {
      "command": "$NPX_PATH",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "fetch": {
      "command": "$UVX_PATH",
      "args": ["mcp-server-fetch"]
    },
    "sequential-thinking": {
      "command": "$NPX_PATH",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
DESKTOPEOF
    log "Claude Desktop MCP config written"
  else
    warn "Claude Desktop directory not found - skipping"
  fi

  # -----------------------------------------------------------
  # Install Global CLAUDE.md
  # -----------------------------------------------------------
  info "Installing global CLAUDE.md..."
  if [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/CLAUDE.md" "$HOME_DIR/.claude/CLAUDE.md"
    log "Global CLAUDE.md installed"
  else
    warn "CLAUDE.md not found in setup directory - skipping"
  fi

  # Remove temp files
  info "Cleaning up temporary files..."
  rm -rf "$TMPDIR"
  log "Cleanup complete"

  # -----------------------------------------------------------
  # Summary
  # -----------------------------------------------------------
  echo ""
  echo "============================================"
  echo -e "  ${GREEN}Setup Complete!${NC}"
  echo "============================================"
  echo ""
  echo "  Skills installed:  $TOTAL_SKILLS"
  echo "  Skills location:   ~/.claude/skills/"
  echo "  MCP servers:       7 (filesystem, memory, fetch, puppeteer, sequential-thinking, git, context7)"
  echo "  Desktop config:    ~/Library/Application Support/Claude/claude_desktop_config.json"
  echo ""
  echo "  PERMISSIONS (daily-driver mode):"
  echo "    Auto-approved:  MCP tools, Read, Glob, Grep, WebFetch, WebSearch, safe Bash commands"
  echo "    Needs approval: Write, Edit, uncategorized Bash commands"
  echo "    Denied:         rm -rf /, fork bombs, force-push to main, etc."
  echo ""
  echo "  NEXT STEP:"
  echo "  Restart Claude Code to apply the new settings."
  echo ""
  echo "============================================"
  echo ""
}

# -----------------------------------------------------------
# Main Dispatch
# -----------------------------------------------------------
case "${1:-}" in
  install)
    do_install
    ;;
  *)
    usage
    ;;
esac
