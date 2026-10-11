#!/usr/bin/env bash
# Rebuild the combined CA bundle used behind Zscaler TLS inspection:
#   public CA roots + the Zscaler root, in one PEM.
#
# Needed so gcloud, curl, and Python (requests) work behind Zscaler, since those
# tools *replace* their trust store via REQUESTS_CA_BUNDLE/SSL_CERT_FILE/CURL_CA_BUNDLE
# (see ~/.config/shell/shared.local.sh). NODE_EXTRA_CA_CERTS is separate — Node
# appends it, so it points at the Zscaler root alone.
#
# Prereq: export the Zscaler root cert to ~/.config/zscaler/ZscalerRootCA.crt first.
set -euo pipefail

ZSCALER_ROOT="$HOME/.config/zscaler/ZscalerRootCA.crt"
OUT="$HOME/tools/certs/gcloud-ca-combined.pem"

if [ ! -f "$ZSCALER_ROOT" ]; then
  echo "Missing $ZSCALER_ROOT — export the Zscaler root cert first." >&2
  exit 1
fi

# Source of public roots: prefer python certifi, else gcloud's bundled cacert.pem.
PUBLIC="$(python3 -m certifi 2>/dev/null || true)"
if [ -z "$PUBLIC" ]; then
  SDK_ROOT="$(gcloud info --format='value(installation.sdk_root)' 2>/dev/null || true)"
  PUBLIC="${SDK_ROOT}/lib/third_party/certifi/cacert.pem"
fi
if [ ! -f "$PUBLIC" ]; then
  echo "Could not locate a public CA bundle (tried python certifi and gcloud)." >&2
  echo "Install certifi (pip install certifi) or the gcloud SDK, then re-run." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
if [ -f "$OUT" ]; then
  cp "$OUT" "$OUT.bak.$(date +%Y%m%d%H%M%S)"
fi

cat "$PUBLIC" "$ZSCALER_ROOT" > "$OUT"
echo "Wrote $OUT ($(grep -c 'BEGIN CERTIFICATE' "$OUT") certs) from public roots: $PUBLIC"

# Optional: point gcloud at the bundle explicitly.
# gcloud config set core/custom_ca_certs_file "$OUT"
