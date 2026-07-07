# Local machine config (not committed — gitignored via *.local.sh).
# Sourced at the end of ~/.config/shell/shared.sh.

# ── Zscaler Root CA (work laptop) ──
# Behind Zscaler TLS inspection, tools need the Zscaler root in their trust store.
#   - NODE_EXTRA_CA_CERTS is *appended* to Node's built-in roots → the Zscaler cert alone is correct.
#   - REQUESTS_CA_BUNDLE / SSL_CERT_FILE / CURL_CA_BUNDLE *replace* the trust store entirely →
#     they need the combined bundle (public roots + Zscaler), else gcloud/curl/requests break.
# Rebuild the combined bundle with scripts/regen-zscaler-bundle.sh in the dotfiles repo.
if [ -f "$HOME/.config/zscaler/ZscalerRootCA.crt" ]; then
  export ZSCALER_CERT="$HOME/.config/zscaler/ZscalerRootCA.crt"
  export NODE_EXTRA_CA_CERTS="$ZSCALER_CERT"          # Node appends → zscaler-only is correct
  if [ -f "$HOME/tools/certs/gcloud-ca-combined.pem" ]; then
    export ZSCALER_CA_BUNDLE="$HOME/tools/certs/gcloud-ca-combined.pem"
  else
    export ZSCALER_CA_BUNDLE="$ZSCALER_CERT"           # fallback until bundle is regenerated
  fi
  export REQUESTS_CA_BUNDLE="$ZSCALER_CA_BUNDLE"
  export SSL_CERT_FILE="$ZSCALER_CA_BUNDLE"
  export CURL_CA_BUNDLE="$ZSCALER_CA_BUNDLE"
fi

# ---- Navigation: project dirs (used by cdui / cdmi in shared.sh) ----
export UI_DIR="$HOME/dev/gtm-one-app-ui"
export MICROAPPS_DIR="$HOME/dev/microapps"

# ---- Machine-specific env (moved out of ~/.zshrc during stow reconcile) ----
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
export SSL_DIR="$HOME/dev/zoominfo-ssl"          # shared ZoomInfo dev cert dir (zi-dev-ssl-setup)

# ---- getToken default employee user (consumed by getToken in shared.sh) ----
export ZI_EMPLOYEE_USER="pulseforge"
