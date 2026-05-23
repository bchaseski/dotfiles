#!/bin/bash
# install-claude-plugins.sh

set -e  # Exit on first error

PLUGINS=(
  "frontend-design@claude-plugins-official"
  "superpowers@claude-plugins-official"
  "context7@claude-plugins-official"
  "code-review@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "skill-creator@claude-plugins-official"
  "github@claude-plugins-official"
  "playwright@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
)

echo "======================================"
echo " Claude Plugin Bulk Installer"
echo "======================================"
echo ""

SUCCESS=()
FAILED=()

for plugin in "${PLUGINS[@]}"; do
  echo "→ Installing $plugin ..."
  if claude plugin install "$plugin"; then
    SUCCESS+=("$plugin")
    echo "  ✓ Done"
  else
    FAILED+=("$plugin")
    echo "  ✗ Failed (skipping)"
  fi
  echo ""
done

echo "======================================"
echo " Summary"
echo "======================================"
echo "Installed (${#SUCCESS[@]}):"
for p in "${SUCCESS[@]}"; do echo "  ✓ $p"; done

if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "Failed (${#FAILED[@]}):"
  for p in "${FAILED[@]}"; do echo "  ✗ $p"; done
  echo ""
  echo "For failed plugins, check: https://claude.com/plugins"
  exit 1
fi

echo ""
echo "All plugins installed successfully."
