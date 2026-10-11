#!/bin/bash
# install-claude-plugins.sh
#
# Part 1 — Top 10 Claude Plugins
#   Source: https://pub.towardsai.net/stop-prompting-start-commanding-the-top-10-claude-plugins-that-actually-ship-work-ddefec8b0f45
#
# Part 2 — 8 Skills Every Claude Code Setup Needs
#   Source: https://medium.com/data-science-collective/the-8-skills-every-claude-code-setup-needs-in-2026-eb7e72cbf91f
#
# NOTE: Verify package names at https://claude.com/plugins before running.
# Third-party articles may not reflect exact official names.

SUCCESS=()
FAILED=()

run_install() {
  local cmd="$1"
  local label="$2"
  echo "→ $label"
  echo "  $ $cmd"
  if eval "$cmd"; then
    SUCCESS+=("$label")
    echo "  ✓ Done"
  else
    FAILED+=("$label")
    echo "  ✗ Failed (skipping)"
  fi
  echo ""
}

# ══════════════════════════════════════════════════════
#  PART 1 — Top 10 Claude Plugins (Towards AI)
# ══════════════════════════════════════════════════════
echo ""
echo "══════════════════════════════════════════════════════"
echo "  PART 1 — Top 10 Claude Plugins"
echo "══════════════════════════════════════════════════════"
echo ""

run_install \
  "claude plugin install frontend-design@claude-plugins-official" \
  "frontend-design"

run_install \
  "claude plugin install superpowers@claude-plugins-official" \
  "superpowers"

run_install \
  "claude plugin install context7@claude-plugins-official" \
  "context7"

run_install \
  "claude plugin install code-review@claude-plugins-official" \
  "code-review"

run_install \
  "claude plugin install code-simplifier@claude-plugins-official" \
  "code-simplifier"

run_install \
  "claude plugin install skill-creator@claude-plugins-official" \
  "skill-creator"

run_install \
  "claude plugin install github@claude-plugins-official" \
  "github"

run_install \
  "claude plugin install playwright@claude-plugins-official" \
  "playwright"

run_install \
  "claude plugin install feature-dev@claude-plugins-official" \
  "feature-dev"

run_install \
  "claude plugin install claude-md-management@claude-plugins-official" \
  "claude-md-management"

# ══════════════════════════════════════════════════════
#  PART 2 — 8 Skills Every Claude Code Setup Needs
# ══════════════════════════════════════════════════════
echo ""
echo "══════════════════════════════════════════════════════"
echo "  PART 2 — 8 Skills Every Claude Code Setup Needs"
echo "══════════════════════════════════════════════════════"
echo ""


# Document processing bundle: PDF, XLSX, DOCX, PPTX in one command
run_install \
  "claude plugin install document-skills@anthropic-agent-skills" \
  "document-skills (pdf + xlsx + docx + pptx bundle)"

# Frontend design pair
run_install \
  "claude plugin install frontend-design@anthropics/claude-code" \
  "frontend-design (anthropics/claude-code)"

run_install \
  "claude plugin install theme-factory@anthropic-agent-skills" \
  "theme-factory"

# Playwright-based webapp testing
run_install \
  "claude plugin install webapp-testing@anthropic-agent-skills" \
  "webapp-testing"

# MCP builder bridge
run_install \
  "claude plugin install mcp-builder@anthropic-agent-skills" \
  "mcp-builder"

# Static analysis / security (Trail of Bits)
run_install \
  "claude plugin marketplace add trailofbits/skills && claude plugin install static-analysis@trailofbits" \
  "static-analysis (trailofbits)"

# /simplify, /debug, /batch, /loop, /claude-api are bundled into Claude Code —
# no install needed. Noted here for completeness.
echo "ℹ  Built-in skills (/simplify /debug /batch /loop /claude-api) are"
echo "   already bundled with Claude Code — no install required."
echo ""

# agent-sandbox — community skill (disler/agent-sandbox-skill).
# The article provides NO /plugin install command for this one; only a git clone.
# Skipping automated install. To install manually:
#   git clone https://github.com/disler/agent-sandbox-skill.git ~/.claude/skills/agent-sandbox
echo "⚠  agent-sandbox is a community skill with no /plugin install command."
echo "   Install manually if needed:"
echo "   git clone https://github.com/disler/agent-sandbox-skill.git ~/.claude/skills/agent-sandbox"
echo ""

# ══════════════════════════════════════════════════════
#  SUMMARY
# ══════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════"
echo " Summary"
echo "══════════════════════════════════════════════════════"
echo "Installed (${#SUCCESS[@]}):"
for p in "${SUCCESS[@]}"; do echo "  ✓ $p"; done

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "Failed (${#FAILED[@]}):"
  for p in "${FAILED[@]}"; do echo "  ✗ $p"; done
  echo ""
  echo "Check exact package names at: https://claude.com/plugins"
  exit 1
fi

echo ""
echo "All attempted installs succeeded."
