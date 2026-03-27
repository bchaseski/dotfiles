# dotfiles

My personal macOS development environment. One command to go from a fresh Mac to fully configured.

## Structure

```
dotfiles/
├── install.sh          # Run this first on a new Mac
├── Brewfile            # All packages and apps
├── zsh/
│   └── .zshrc          # Shell config, aliases, PATH
├── git/
│   └── .gitconfig      # Git settings and aliases
├── vscode/
│   └── settings.json   # VS Code preferences
└── ssh/
    └── config          # SSH host shortcuts
```

## Fresh Mac Setup

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

That's it. Restart your terminal when done.

## What Gets Installed

- **Homebrew** — package manager
- **fnm** — Node version manager (auto-switches per project)
- **pyenv** — Python version manager
- **Claude Code** — via native installer (auto-updates)
- **Claude Desktop** — via Homebrew cask
- **VS Code, Docker, iTerm2** — GUI apps via cask
- **kubectl, terraform, awscli, helm, k9s** — DevOps tools
- **starship** — shell prompt

## Keeping Things Updated

```bash
brew update && brew upgrade          # Update all brew packages
brew upgrade claude-code             # Update Claude Code (if installed via brew)
fnm install --lts && fnm default lts-latest  # Update Node LTS
pyenv install 3.x && pyenv global 3.x        # Update Python
```

## Adding a New Machine Later

Just clone and run `install.sh`. Stow handles all symlinks automatically.

## Notes

- Never commit secrets, API keys, or SSH private keys
- Keep sensitive config in `~/.env` (gitignored)
- SSH private keys live in `~/.ssh/` — never in this repo
