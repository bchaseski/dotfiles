#!/bin/bash
# Install wt to /usr/local/bin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo install -m 755 "$SCRIPT_DIR/wt" /usr/local/bin/wt
echo "Installed wt -> /usr/local/bin/wt"
