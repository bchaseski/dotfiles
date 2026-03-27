#!/bin/bash
# =============================================================================
# Zscaler Root CA Certificate - Full System Setup
# Certificate: ZscalerRootCertificate-2048-SHA256-Feb2025.crt
# Covers: macOS Keychain, zshrc env vars, git, curl, npm, Python (certifi)
# =============================================================================

set -e

CERT_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ZscalerRootCertificate-2048-SHA256-Feb2025.crt"
CERT_DIR="$HOME/.config/zscaler"
CERT_DEST="$CERT_DIR/ZscalerRootCA.crt"
ZSHRC="$HOME/.zshrc"

# ─────────────────────────────────────────────────────────────────────────────
# 0. Preflight check
# ─────────────────────────────────────────────────────────────────────────────
if [ ! -f "$CERT_SOURCE" ]; then
  echo "❌  Certificate not found at: $CERT_SOURCE"
  echo "    Please make sure the file exists and try again."
  exit 1
fi

echo ""
echo "🔐  Zscaler Root CA Certificate Setup"
echo "────────────────────────────────────────────────────────"
echo "    Source : $CERT_SOURCE"
echo "    Install: $CERT_DEST"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# 1. Copy cert to permanent location
# ─────────────────────────────────────────────────────────────────────────────
echo "📁  [1/7] Copying certificate to $CERT_DIR ..."
mkdir -p "$CERT_DIR"
cp "$CERT_SOURCE" "$CERT_DEST"
echo "    ✅  Done"

# ─────────────────────────────────────────────────────────────────────────────
# 2. macOS System Keychain (requires sudo)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🔑  [2/7] Adding to macOS System Keychain (requires sudo) ..."
sudo security add-trusted-cert \
  -d \
  -r trustRoot \
  -k /Library/Keychains/System.keychain \
  "$CERT_DEST"
echo "    ✅  Done — Zscaler Root CA is now trusted system-wide"

# ─────────────────────────────────────────────────────────────────────────────
# 3. ~/.zshrc — environment variables
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🐚  [3/7] Adding environment variables to ~/.zshrc ..."

ZSHRC_BLOCK="
# ── Zscaler Root CA ──────────────────────────────────────────────────────────
# Added by setup-zscaler-certs.sh
export ZSCALER_CERT=\"\$HOME/.config/zscaler/ZscalerRootCA.crt\"
export NODE_EXTRA_CA_CERTS=\"\$ZSCALER_CERT\"  # Node.js / npm
export REQUESTS_CA_BUNDLE=\"\$ZSCALER_CERT\"   # Python requests / pip
export SSL_CERT_FILE=\"\$ZSCALER_CERT\"        # General SSL (curl, wget, etc.)
export CURL_CA_BUNDLE=\"\$ZSCALER_CERT\"       # curl (redundant but explicit)
# ─────────────────────────────────────────────────────────────────────────────
"

# Only add if not already present
if grep -q "Zscaler Root CA" "$ZSHRC" 2>/dev/null; then
  echo "    ⚠️   ~/.zshrc already contains Zscaler block — skipping"
else
  echo "$ZSHRC_BLOCK" >> "$ZSHRC"
  echo "    ✅  Done"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 4. git — global SSL CA bundle
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🔗  [4/7] Configuring git to trust Zscaler cert ..."
git config --global http.sslCAInfo "$CERT_DEST"
echo "    ✅  Done  (http.sslCAInfo = $CERT_DEST)"

# ─────────────────────────────────────────────────────────────────────────────
# 5. curl — ~/.curlrc
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🌐  [5/7] Configuring curl (~/.curlrc) ..."
CURLRC="$HOME/.curlrc"
CURL_LINE="cacert = $CERT_DEST"

if grep -q "cacert" "$CURLRC" 2>/dev/null; then
  echo "    ⚠️   ~/.curlrc already has a cacert entry — skipping"
  echo "         If you need to update it, edit $CURLRC manually"
else
  echo "" >> "$CURLRC"
  echo "# Zscaler Root CA" >> "$CURLRC"
  echo "$CURL_LINE" >> "$CURLRC"
  echo "    ✅  Done"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 6. npm — global cafile config
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "📦  [6/7] Configuring npm cafile ..."
if command -v npm &>/dev/null; then
  npm config set cafile "$CERT_DEST"
  echo "    ✅  Done  (npm config set cafile $CERT_DEST)"
else
  echo "    ⚠️   npm not found — skipping (NODE_EXTRA_CA_CERTS in .zshrc covers Node.js)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# 7. Python — append to certifi's CA bundle
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "🐍  [7/7] Appending certificate to Python certifi bundle ..."

append_to_certifi() {
  local python_bin="$1"
  if ! command -v "$python_bin" &>/dev/null; then
    return
  fi
  local certifi_bundle
  certifi_bundle=$("$python_bin" -c "import certifi; print(certifi.where())" 2>/dev/null)
  if [ -z "$certifi_bundle" ]; then
    echo "    ⚠️   certifi not found for $python_bin — skipping"
    return
  fi
  # Check if already appended
  if grep -q "Zscaler" "$certifi_bundle" 2>/dev/null; then
    echo "    ⚠️   Zscaler cert already in $certifi_bundle — skipping"
    return
  fi
  echo "" >> "$certifi_bundle"
  echo "# Zscaler Root CA (added by setup-zscaler-certs.sh)" >> "$certifi_bundle"
  cat "$CERT_DEST" >> "$certifi_bundle"
  echo "    ✅  Appended to: $certifi_bundle  (via $python_bin)"
}

# Try common Python interpreters
appended=false
for py in python3 python python3.12 python3.11 python3.10; do
  if command -v "$py" &>/dev/null; then
    append_to_certifi "$py"
    appended=true
    break
  fi
done
if ! $appended; then
  echo "    ⚠️   No Python interpreter found — REQUESTS_CA_BUNDLE in .zshrc covers most cases"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Done!
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────────────────"
echo "✅  All done! Zscaler Root CA is now configured for:"
echo ""
echo "   • macOS System Keychain  (Safari, Chrome, system TLS)"
echo "   • ~/.zshrc               (NODE_EXTRA_CA_CERTS, REQUESTS_CA_BUNDLE,"
echo "                             SSL_CERT_FILE, CURL_CA_BUNDLE)"
echo "   • git                   (http.sslCAInfo)"
echo "   • curl                  (~/.curlrc cacert)"
echo "   • npm                   (cafile)"
echo "   • Python certifi         (CA bundle)"
echo ""
echo "   ⚡  Run: source ~/.zshrc"
echo "      to activate the environment variables in your current shell."
echo "────────────────────────────────────────────────────────"
echo ""
