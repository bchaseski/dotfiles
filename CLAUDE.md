# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles for macOS and Linux (Ubuntu/WSL), managed with GNU Stow. Each top-level directory (`zsh/`, `bash/`, `shell/`, `git/`, `vscode/`, `ssh/`, `claude/`) maps to a tool's config files. Stow symlinks them into `~` so they're version-controlled without copying. The `claude/` directory is an exception — since `~/.claude/` contains runtime data, `install.sh` symlinks just `settings.json` rather than using stow.

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
- **Machine-local overrides**: `shared.sh` sources `~/.config/shell/shared.local.sh` last if it exists. That file is gitignored (`*.local.sh`) and holds per-machine, non-committed config (e.g. work-laptop CA certs).
- **No Makefile or tests** — this is config, not code.
- **Secrets are never committed** — `.gitignore` excludes SSH keys, `.env*`, `*.local.sh`, and `*.pem`/`*.key` files.

## Key Files

| File | Purpose |
|------|---------|
| `install.sh` | One-command new machine setup (macOS + Linux) |
| `Brewfile` | All CLI tools + GUI apps (Homebrew, macOS only) |
| `shell/.config/shell/shared.sh` | Cross-shell aliases, functions, env vars |
| `shell/.config/shell/bash-defaults.sh` | Ubuntu/Debian bash boilerplate |
| `scripts/regen-zscaler-bundle.sh` | Rebuild the combined CA bundle (public roots + Zscaler) on a new work laptop |
| `zsh/.zshrc` | zsh config: sources shared.sh + Homebrew, fnm, plugins |
| `bash/.bashrc` | bash config: sources bash-defaults + shared.sh + Starship |
| `git/.gitconfig` | Git identity, editor (VS Code), aliases |
| `vscode/settings.json` | Editor preferences, formatters (Prettier, Black) |
| `ssh/config` | SSH defaults, GitHub host, jump-host patterns |
| `claude/.claude/settings.json` | Claude Code permissions and settings (symlinked, not stowed) |

## Customization Required

`git/.gitconfig` contains placeholder values — update before first use:
```
[user]
    name = Your Name
    email = your.email@example.com
```

### Zscaler / corporate CA (work laptop)

Behind Zscaler's TLS inspection, tools must trust the Zscaler root. This is split three ways so
work-specific cert paths stay out of the public repo:

1. **Recipe (committed)** — `scripts/regen-zscaler-bundle.sh` rebuilds the combined bundle
   (public CA roots + Zscaler root) at `~/tools/certs/gcloud-ca-combined.pem`.
2. **Exports (machine-local, gitignored)** — `~/.config/shell/shared.local.sh` sets the CA env
   vars. `NODE_EXTRA_CA_CERTS` points at the Zscaler root alone (Node *appends* it);
   `REQUESTS_CA_BUNDLE`/`SSL_CERT_FILE`/`CURL_CA_BUNDLE` point at the combined bundle (they
   *replace* the trust store, so they need the public roots too — or gcloud/curl/requests break).
3. **Artifact (gitignored)** — the generated `*.pem` bundle itself.

New-laptop setup: export the Zscaler root to `~/.config/zscaler/ZscalerRootCA.crt`, run
`scripts/regen-zscaler-bundle.sh`, and create `~/.config/shell/shared.local.sh` with the CA exports.
