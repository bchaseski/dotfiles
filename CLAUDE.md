# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles for macOS and Linux (Ubuntu/WSL), managed with GNU Stow. Each top-level directory (`zsh/`, `bash/`, `shell/`, `git/`, `vscode/`, `ssh/`) maps to a tool's config files. Stow symlinks them into `~` so they're version-controlled without copying.

## Setup

```bash
# Full setup on a new machine (macOS or Linux)
chmod +x install.sh && ./install.sh
```

`install.sh` detects the OS and runs platform-specific setup:
- **macOS**: Homebrew, `brew bundle`, fnm (Node LTS), pyenv (Python 3.12), VS Code CLI, then stows `shell zsh git vscode ssh`
- **Linux**: apt packages, Starship, pyenv, then stows `shell bash git ssh`

To apply dotfiles without running the full install:
```bash
# macOS
stow shell zsh git vscode ssh

# Linux
stow shell bash git ssh
```

To add a new tool's config:
```bash
mkdir newtool
# place config at newtool/.config/newtool/config (mirroring ~/ structure)
stow newtool
```

## Architecture

- **Stow symlinks**: Each subdirectory mirrors the home directory structure. `zsh/.zshrc` → `~/.zshrc`, `bash/.bashrc` → `~/.bashrc`, `shell/.config/shell/` → `~/.config/shell/`, etc.
- **Shared shell config**: `shell/.config/shell/shared.sh` contains aliases, functions, and env vars common to both bash and zsh. Both `.bashrc` and `.zshrc` source this file.
- **Shell-specific config**: `zsh/.zshrc` has zsh/macOS-specific setup (Homebrew, plugins, fnm). `bash/.bashrc` has bash/Linux-specific setup (Ubuntu defaults, Starship bash).
- **Packages**: All Homebrew dependencies declared in `Brewfile` (macOS only). Run `brew bundle` to sync.
- **No Makefile or tests** — this is config, not code.
- **Secrets are never committed** — `.gitignore` excludes SSH keys, `.env*`, and `*.pem`/`*.key` files.

## Key Files

| File | Purpose |
|------|---------|
| `install.sh` | One-command new machine setup (macOS + Linux) |
| `Brewfile` | All CLI tools + GUI apps (Homebrew, macOS only) |
| `shell/.config/shell/shared.sh` | Cross-shell aliases, functions, env vars |
| `shell/.config/shell/bash-defaults.sh` | Ubuntu/Debian bash boilerplate |
| `zsh/.zshrc` | zsh config: sources shared.sh + Homebrew, fnm, plugins |
| `bash/.bashrc` | bash config: sources bash-defaults + shared.sh + Starship |
| `git/.gitconfig` | Git identity, editor (VS Code), aliases |
| `vscode/settings.json` | Editor preferences, formatters (Prettier, Black) |
| `ssh/config` | SSH defaults, GitHub host, jump-host patterns |

## Customization Required

`git/.gitconfig` contains placeholder values — update before first use:
```
[user]
    name = Your Name
    email = your.email@example.com
```
