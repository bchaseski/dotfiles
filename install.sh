#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

INSTALL_BREW=true
INSTALL_BREW_INSTALL=true
INSTALL_BREWFILE=true
INSTALL_CLAUDE=true
INSTALL_NODE=true
INSTALL_PYENV=true
INSTALL_VSCODE_CLI=true
INSTALL_COMMON=true
INSTALL_ZSCALER=false

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --help, -h            Show this help message
  --skip-brew           Skip installing Homebrew and Brewfile
  --skip-brew-install   Skip Homebrew installer only
  --skip-brewfile       Skip Brewfile package install only
  --skip-claude         Skip installing Claude Code
  --skip-node           Skip fnm / Node install
  --skip-pyenv          Skip pyenv / Python install
  --skip-vscode-cli     Skip VS Code CLI symlink
  --no-common           Skip common setup (wt install + stow)
  --zscaler             Install Zscaler certs via zscaler/setup-zscaler-certs.sh
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      --skip-brew)
        INSTALL_BREW=false
        INSTALL_BREW_INSTALL=false
        INSTALL_BREWFILE=false
        ;;
      --skip-brew-install)
        INSTALL_BREW_INSTALL=false
        ;;
      --skip-brewfile)
        INSTALL_BREWFILE=false
        ;;
      --skip-claude)
        INSTALL_CLAUDE=false
        ;;
      --skip-node)
        INSTALL_NODE=false
        INSTALL_PYENV=false
        ;;
      --skip-pyenv)
        INSTALL_PYENV=false
        ;;
      --skip-vscode-cli)
        INSTALL_VSCODE_CLI=false
        ;;
      --no-common)
        INSTALL_COMMON=false
        ;;
      --zscaler|--install-zscaler)
        INSTALL_ZSCALER=true
        ;;
      *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

install_claude_settings() {
  local src="${DOTFILES_DIR}/claude/.claude/settings.json"
  local dst="$HOME/.claude/settings.json"

  if [[ ! -f "$src" ]]; then
    echo "⚠️  Repo Claude settings file not found: $src"
    return
  fi

  echo "🔐 Symlinking Claude settings to $dst..."
  mkdir -p "$(dirname "$dst")"

  if [[ -f "$dst" && ! -L "$dst" ]]; then
    echo "    📋 Backing up existing $dst to ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  ln -sf "$src" "$dst"
  echo "    ✅ Done"
}

parse_args "$@"

# Prompt for sudo once and keep the timestamp alive for the duration of the script
sudo -v
while true; do sudo -n true; sleep 240; kill -0 $$ 2>/dev/null || exit; done &
_SUDO_PID=$!

# ── macOS setup ──────────────────────────────────────────────────────────────
install_macos() {
  if [[ "$INSTALL_BREW_INSTALL" == true ]]; then
    echo "🍺 Installing Homebrew..."
    if ! command -v brew &>/dev/null; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  else
    echo "⏭️  Skipping Homebrew installer."
  fi

  if command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
  fi

  if [[ "$INSTALL_BREWFILE" == true ]]; then
    echo "📦 Installing packages from Brewfile..."
    if command -v brew &>/dev/null; then
      brew bundle install --file="$DOTFILES_DIR/Brewfile" || echo "⚠️  brew bundle had errors — some packages may be missing. Continuing..."
    else
      echo "⚠️  brew not found; cannot install Brewfile packages."
    fi
  else
    echo "⏭️  Skipping Brewfile package install."
  fi

  if [[ "$INSTALL_CLAUDE" == true ]]; then
    echo "🤖 Installing Claude Code (native installer — auto-updates)..."
    curl -fsSL https://claude.ai/install.sh | bash
  else
    echo "⏭️  Skipping Claude Code install."
  fi

  if [[ "$INSTALL_NODE" == true ]]; then
    echo "🟢 Installing Node.js via fnm..."
    if command -v fnm &>/dev/null; then
      eval "$(fnm env)"
      fnm install --lts
      fnm default lts-latest
    else
      echo "⚠️  fnm not found; skipping Node install."
    fi
  else
    echo "⏭️  Skipping Node.js install."
  fi

  if [[ "$INSTALL_PYENV" == true ]]; then
    echo "🐍 Setting up Python via pyenv..."
    if command -v pyenv &>/dev/null; then
      pyenv install 3.12 --skip-existing
      pyenv global 3.12
    else
      echo "⚠️  pyenv not found; skipping Python setup."
    fi
  else
    echo "⏭️  Skipping pyenv / Python setup."
  fi

  if [[ "$INSTALL_VSCODE_CLI" == true ]]; then
    echo "⚙️  Setting up VS Code CLI..."
    sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
  else
    echo "⏭️  Skipping VS Code CLI setup."
  fi
}

# ── Linux setup ──────────────────────────────────────────────────────────────
install_linux() {
  echo "📦 Installing system packages..."
  sudo apt-get update
  sudo apt-get install -y stow git curl jq

  echo "⭐ Installing Starship prompt..."
  if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  echo "🐍 Setting up Python via pyenv..."
  if ! command -v pyenv &>/dev/null; then
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev wget llvm \
      libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
      libffi-dev liblzma-dev
    curl https://pyenv.run | bash
  fi

  echo "🤖 Installing Claude Code (native installer — auto-updates)..."
  curl -fsSL https://claude.ai/install.sh | bash

  # Back up existing .bashrc before stow replaces it
  if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    echo "📋 Backing up existing ~/.bashrc to ~/.bashrc.bak"
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
  fi
}

# ── Common setup (both platforms) ────────────────────────────────────────────
install_common() {
  echo "🌿 Installing wt (git worktree helper)..."
  sudo install -m 755 "$DOTFILES_DIR/worktree/wt" "$(brew --prefix)/bin/wt"

  echo "🔗 Symlinking dotfiles with stow..."
  cd "$DOTFILES_DIR"

  if [[ "$OS" == "Darwin" ]]; then
    stow shell zsh git vscode ssh
  else
    stow shell bash git ssh
  fi

  if [[ "$INSTALL_CLAUDE" == true ]]; then
    install_claude_settings
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  install_macos
elif [[ "$OS" == "Linux" ]]; then
  install_linux
else
  echo "❌ Unsupported OS: $OS"
  kill $_SUDO_PID 2>/dev/null
  exit 1
fi

if [[ "$INSTALL_COMMON" == true ]]; then
  install_common
else
  echo "⏭️  Skipping common setup."
fi

if [[ "$INSTALL_ZSCALER" == true ]]; then
  echo "🔐 Running Zscaler certificate setup..."
  bash "$DOTFILES_DIR/zscaler/setup-zscaler-certs.sh"
else
  echo "⏭️  Skipping Zscaler setup (use --zscaler to enable)."
fi

kill $_SUDO_PID 2>/dev/null
echo "✅ Done! Restart your terminal."
