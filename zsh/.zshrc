# ---- Shared config (aliases, functions, env vars) ----
if [[ ! -f "$HOME/.config/shell/shared.sh" ]]; then
  echo "Restowing shell config..."
  (cd "$HOME/dev/personal/dotfiles" && stow --target="$HOME" shell)
fi
source "$HOME/.config/shell/shared.sh"

# ---- Starship prompt ----
eval "$(starship init zsh)"

# ---- Homebrew (macOS) ----
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # GNU userland (prefer GNU tools over macOS BSD versions)
  export PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
  export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
  export PATH="$(brew --prefix)/opt/grep/libexec/gnubin:$PATH"

  # zsh plugins (installed via Homebrew)
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ---- fnm (Node version manager) ----
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

# ---- Aliases: zsh-specific ----
alias reload="source ~/.zshrc"
