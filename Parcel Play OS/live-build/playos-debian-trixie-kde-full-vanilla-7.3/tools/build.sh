#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Building PlayOS Debian Trixie KDE Full Vanilla 7.3 Live ISO ==="

cd "${PROFILE_DIR}"
"${SCRIPT_DIR}/import-kernel.sh"
"${SCRIPT_DIR}/preflight.sh"

sudo lb clean --purge
sudo ./auto/config
sudo lb build

echo "=== Build Finished ==="
ls -lh *.iso
exit 0
