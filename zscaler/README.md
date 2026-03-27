# Zscaler Setup

Configures the Zscaler Root CA certificate system-wide so tools like git, curl, npm, and Python don't fail SSL verification on a corporate network.

## What it does

Runs 7 setup steps:

1. Copies the cert to `~/.config/zscaler/ZscalerRootCA.crt`
2. Adds it to the **macOS System Keychain** (trusted root)
3. Exports `NODE_EXTRA_CA_CERTS`, `REQUESTS_CA_BUNDLE`, `SSL_CERT_FILE`, `CURL_CA_BUNDLE` in `~/.zshrc`
4. Sets `http.sslCAInfo` in global **git** config
5. Adds `cacert` to `~/.curlrc`
6. Sets `cafile` in **npm** global config
7. Appends the cert to the **Python certifi** bundle

## Usage

```bash
bash zscaler/setup-zscaler-certs.sh
```

The cert file (`ZscalerRootCertificate-2048-SHA256-Feb2025.crt`) is bundled in this directory — no manual download needed.

After running, reload your shell:

```bash
source ~/.zshrc
```

## Requirements

- macOS
- `sudo` access (for Keychain step)
