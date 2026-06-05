# ---- Shared shell config (sourced by both .bashrc and .zshrc) ----

# ---- pyenv ----
export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# ---- Claude Code PATH ----
export PATH="$HOME/.local/bin:$PATH"

# ---- Zscaler / corporate CA ----
# Machine-specific; configured in ~/.config/shell/shared.local.sh (sourced at the bottom).
# Rebuild the combined bundle with scripts/regen-zscaler-bundle.sh on a new work laptop.

# ---- Aliases: General ----
alias ll="ls -lAh"
alias la="ls -A"

# ---- Navigation: project dirs ----
# Each cd<x> jumps to a project. Paths come from env vars so machine-specific
# locations stay out of the committed repo — set UI_DIR / MICROAPPS_DIR in
# ~/.config/shell/shared.local.sh (gitignored, sourced at the bottom), same
# pattern as SSL_DIR. Without those vars set, the functions print a hint.
cdui() { cd "${UI_DIR:?set UI_DIR in ~/.config/shell/shared.local.sh}" || return; }
cdmi() { cd "${MICROAPPS_DIR:?set MICROAPPS_DIR in ~/.config/shell/shared.local.sh}" || return; }

# ---- Aliases: Git ----
alias gs="git status"
alias gp="git pull"
alias gc="git commit"
alias main='git checkout main && git pull'
alias wtr="git worktree remove"

# ---- Aliases: Docker ----
alias dps="docker ps"
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"

# ---- Aliases: Python ----
alias py="python3"

# ---- Aliases: GCloud ----
alias gcauth='gcloud auth login --update-adc'

# ---- Aliases: DevOps ----
# alias k="kubectl"
# alias tf="terraform"

# ---- Functions: ZoomInfo Token ----
getToken() {
  local ENV="${1:-stg}"
  # Default employee user is machine-specific; override via ZI_EMPLOYEE_USER in shared.local.sh.
  local EMPLOYEE_USER="${3:-${ZI_EMPLOYEE_USER:-string}}"

  local ACCOUNT_ID
  case "$ENV" in
    stg) ACCOUNT_ID="${2:-20114632}" ;;
    prd) ACCOUNT_ID="${2:-30317674}" ;;
    *)
      echo "Invalid env '$ENV' (use: stg or prd)"
      return 1
      ;;
  esac

  local URL="https://passive-login-service.zios-apps-primary.${ENV}.zi-int.com/passiveLogin"

  local TOKEN
  TOKEN=$(
    curl -s --location "$URL" \
      --header 'accept: application/json' \
      --header 'Content-Type: application/json' \
      --data "{
        \"accountIds\": [${ACCOUNT_ID}],
        \"refreshCache\": true,
        \"employeeUser\": \"${EMPLOYEE_USER}\"
      }" \
    | jq -r ".tokensMap[\"${ACCOUNT_ID}\"]"
  )

  if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "❌ Failed to retrieve token for account ${ACCOUNT_ID} in ${ENV}"
    return 1
  fi

  export ZI_TOKEN="$TOKEN"
  export ZI_ENV="$ENV"

  echo "✅ Token exported:"
  echo "   ZI_ENV=${ENV}"
  echo "   ZI_TOKEN=$TOKEN"

  if command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$TOKEN" | pbcopy
    echo "📋 Token copied to clipboard"
  fi
}

alias gst='getToken stg'
alias gpt='getToken prd'

# ---- Local machine config (not committed) ----
if [ -f "$HOME/.config/shell/shared.local.sh" ]; then
  . "$HOME/.config/shell/shared.local.sh"
fi
