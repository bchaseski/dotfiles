# ---- Shared shell config (sourced by both .bashrc and .zshrc) ----

# ---- pyenv ----
export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# ---- Claude Code PATH ----
export PATH="$HOME/.local/bin:$PATH"

# ── Zscaler Root CA ──────────────────────────────────────────────────────────
if [ -f "$HOME/.config/zscaler/ZscalerRootCA.crt" ]; then
  export ZSCALER_CERT="$HOME/.config/zscaler/ZscalerRootCA.crt"
  export NODE_EXTRA_CA_CERTS="$ZSCALER_CERT"
  export REQUESTS_CA_BUNDLE="$ZSCALER_CERT"
  export SSL_CERT_FILE="$ZSCALER_CERT"
  export CURL_CA_BUNDLE="$ZSCALER_CERT"
fi

# ---- Aliases: General ----
alias ll="ls -lAh"
alias la="ls -A"

# ---- Aliases: Git ----
alias gs="git status"
alias gp="git pull"
alias gc="git commit"
alias main='git checkout main && git pull'

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
  local ACCOUNT_ID="${2:-20114632}"
  local EMPLOYEE_USER="${3:-string}"

  case "$ENV" in
    stg|prd) ;;
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
}

alias gst='getToken stg'
alias gpt='getToken prd'

# ---- Local machine config (not committed) ----
if [ -f "$HOME/.config/shell/shared.local.sh" ]; then
  . "$HOME/.config/shell/shared.local.sh"
fi
