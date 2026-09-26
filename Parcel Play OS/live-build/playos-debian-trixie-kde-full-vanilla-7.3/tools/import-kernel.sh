#!/bin/bash
# Import Linux Vanilla 7.3 kernel DEBs into live-build packages.chroot
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PACKAGES_DIR="${PROFILE_DIR}/config/packages.chroot"
SOURCE_KERNEL_DIR="/home/marcel/kernel-debs"

echo "=== PlayOS Vanilla 7.3 Kernel Importer ==="
mkdir -p "${PACKAGES_DIR}"

if [ ! -d "${SOURCE_KERNEL_DIR}" ]; then
    echo "Error: Source kernel directory not found at ${SOURCE_KERNEL_DIR}"
    exit 1
fi

echo "Copying Linux 7.3 kernel DEBs to ${PACKAGES_DIR}..."
cp -v "${SOURCE_KERNEL_DIR}"/*.deb "${PACKAGES_DIR}/"

echo "=== Vanilla 7.3 Kernel Import Completed ==="
ls -lh "${PACKAGES_DIR}"
exit 0
