# ---- Bash defaults (Ubuntu/Debian boilerplate) ----
source "$HOME/.config/shell/bash-defaults.sh"

# ---- Shared config (aliases, functions, env vars) ----
source "$HOME/.config/shell/shared.sh"

# ---- Homebrew (Linux, if installed) ----
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ---- Starship prompt ----
eval "$(starship init bash)"

# ---- Aliases: bash-specific ----
alias reload="source ~/.bashrc"
