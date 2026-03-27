#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

# Prompt for sudo once and keep the timestamp alive for the duration of the script
sudo -v
while true; do sudo -n true; sleep 240; kill -0 $$ 2>/dev/null || exit; done &
_SUDO_PID=$!

# ── macOS setup ──────────────────────────────────────────────────────────────
install_macos() {
  echo "🍺 Installing Homebrew..."
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  echo "📦 Installing packages from Brewfile..."
  brew bundle install --file="$DOTFILES_DIR/Brewfile" || echo "⚠️  brew bundle had errors — some packages may be missing. Continuing..."

  echo "🤖 Installing Claude Code (native installer — auto-updates)..."
  curl -fsSL https://claude.ai/install.sh | bash

  echo "🟢 Installing Node.js via fnm..."
  eval "$(fnm env)"
  fnm install --lts
  fnm default lts-latest

  echo "🐍 Setting up Python via pyenv..."
  pyenv install 3.12 --skip-existing
  pyenv global 3.12

  echo "⚙️  Setting up VS Code CLI..."
  sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
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
  sudo install -m 755 "$DOTFILES_DIR/worktree/wt" /usr/local/bin/wt

  echo "🔗 Symlinking dotfiles with stow..."
  cd "$DOTFILES_DIR"

  if [[ "$OS" == "Darwin" ]]; then
    stow shell zsh git vscode ssh
  else
    stow shell bash git ssh
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

install_common

kill $_SUDO_PID 2>/dev/null
echo "✅ Done! Restart your terminal."
