# dotfiles

Personal dotfiles for macOS and Linux (Ubuntu/WSL), managed with [GNU Stow](https://www.gnu.org/software/stow/). One command to go from a fresh machine to fully configured.

## Structure

```
dotfiles/
├── install.sh          # One-command setup (macOS + Linux)
├── Brewfile            # Homebrew packages and apps (macOS only)
├── shell/
│   └── .config/shell/
│       ├── shared.sh         # Cross-shell aliases, functions, env vars
│       └── bash-defaults.sh  # Ubuntu/Debian bash boilerplate
├── zsh/
│   └── .zshrc          # zsh config (macOS): sources shared.sh + Homebrew, fnm, plugins
├── bash/
│   └── .bashrc         # bash config (Linux): sources shared.sh + Starship
├── git/
│   └── .gitconfig      # Git identity, editor, aliases
├── vscode/
│   └── settings.json   # VS Code preferences and formatters
├── ssh/
│   └── config          # SSH defaults, GitHub host, jump-host patterns
├── claude/
│   └── settings.json   # Claude Code permissions (merged into ~/.claude/settings.json)
├── worktree/
│   └── wt              # Git worktree helper script
└── zscaler/
    └── setup-zscaler-certs.sh  # Zscaler root CA setup (opt-in)
```

## Setup

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Restart your terminal when done.

### Install Options

Every step can be skipped or opted into individually:

```bash
./install.sh                    # Full default install
./install.sh --skip-brew        # Skip Homebrew + Brewfile entirely
./install.sh --skip-brew-install  # Skip Homebrew installer only
./install.sh --skip-brewfile    # Skip Brewfile package install only
./install.sh --skip-claude      # Skip Claude Code install + permissions
./install.sh --skip-node        # Skip fnm / Node install
./install.sh --skip-pyenv       # Skip pyenv / Python install
./install.sh --skip-vscode-cli  # Skip VS Code CLI symlink
./install.sh --no-common        # Skip common setup (wt install + stow)
./install.sh --zscaler          # Install Zscaler root CA certs (off by default)
./install.sh --help             # Show all options
```

Flags can be combined:

```bash
# Minimal: just stow dotfiles + Claude permissions, skip everything else
./install.sh --skip-brew --skip-node --skip-pyenv --skip-vscode-cli

# Corporate laptop: full install + Zscaler certs
./install.sh --zscaler
```

## What Gets Installed

### macOS

- **Homebrew** — package manager
- **Brewfile packages** — VS Code, Docker, iTerm2, kubectl, terraform, awscli, helm, k9s, starship, etc.
- **fnm** — Node version manager (installs LTS)
- **pyenv** — Python version manager (installs 3.12)
- **Claude Code** — native installer (auto-updates) + permissions merged from `claude/settings.json`
- **VS Code CLI** — `code` symlink
- **wt** — git worktree helper installed to `/usr/local/bin`
- **Stow** — symlinks `shell zsh git vscode ssh`

### Linux

- **System packages** — stow, git, curl, jq
- **Starship** — shell prompt
- **pyenv** — Python version manager
- **Claude Code** — native installer + permissions
- **Stow** — symlinks `shell bash git ssh`

## Keeping Things Updated

```bash
brew update && brew upgrade                    # Update all brew packages
fnm install --lts && fnm default lts-latest    # Update Node LTS
pyenv install 3.x && pyenv global 3.x         # Update Python
```

## Customization Required

`git/.gitconfig` contains placeholder values — update before first use:

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

## Notes

- Never commit secrets, API keys, or SSH private keys
- Keep sensitive config in `~/.env` (gitignored)
- SSH private keys live in `~/.ssh/` — never in this repo
