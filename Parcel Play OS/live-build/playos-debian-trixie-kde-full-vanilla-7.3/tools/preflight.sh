#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== PlayOS Preflight: Debian Trixie KDE Full Vanilla 7.3 ==="

for cmd in lb debootstrap xorriso mksquashfs grub-mkimage; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Required tool '$cmd' is not installed."
        exit 1
    fi
done

echo "Preflight check passed successfully."
exit 0
