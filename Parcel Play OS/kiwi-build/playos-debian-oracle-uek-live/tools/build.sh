#!/bin/bash
# KIWI NG Build Wrapper Script for PlayOS Debian + Oracle UEK Live CD
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${PROFILE_DIR}/output"
REPO_DIR="${PROFILE_DIR}/repo"

echo "=== PlayOS KIWI NG Live CD Build Executor ==="
echo "Profile directory: ${PROFILE_DIR}"
echo "Output directory:  ${OUTPUT_DIR}"

# 1. Preflight checks
if ! command -v kiwi-ng >/dev/null 2>&1; then
    echo "Warning: 'kiwi-ng' CLI tool is not installed on this host."
    echo "KIWI NG can be run via Container (Podman/Docker) or installed via pip / apt / zypper:"
    echo "  pip3 install kiwi"
    echo "Or using podman:"
    echo "  podman run --rm -v ${PROFILE_DIR}:/description:Z -v ${OUTPUT_DIR}:/out:Z registry.opensuse.org/opensuse/kiwi:latest system build --description /description --target /out"
fi

if [ ! -d "${REPO_DIR}" ] || [ ! -f "${REPO_DIR}/Packages" ]; then
    echo "Error: Local Oracle UEK APT repository not found at ${REPO_DIR}!"
    echo "Please run '${SCRIPT_DIR}/import_oracle_uek.sh' first to prepare the kernel packages."
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"

# 2. Execute KIWI NG Build
echo "Starting KIWI NG system build..."
if command -v kiwi-ng >/dev/null 2>&1; then
    kiwi-ng system build \
        --description "${PROFILE_DIR}" \
        --target-dir "${OUTPUT_DIR}"
elif command -v podman >/dev/null 2>&1; then
    echo "Executing containerized KIWI NG build via Podman..."
    podman run --privileged --rm \
        -v "${PROFILE_DIR}:/description:Z" \
        -v "${OUTPUT_DIR}:/out:Z" \
        -v "${REPO_DIR}:/var/cache/playos-uek-repo:Z" \
        registry.opensuse.org/opensuse/kiwi:latest \
        system build --description /description --target-dir /out
elif command -v docker >/dev/null 2>&1; then
    echo "Executing containerized KIWI NG build via Docker..."
    docker run --privileged --rm \
        -v "${PROFILE_DIR}:/description:Z" \
        -v "${OUTPUT_DIR}:/out:Z" \
        -v "${REPO_DIR}:/var/cache/playos-uek-repo:Z" \
        registry.opensuse.org/opensuse/kiwi:latest \
        system build --description /description --target-dir /out
else
    echo "=========================================================================="
    echo "Preflight Packaging Passed: Oracle UEK DEB repo is ready at ${REPO_DIR}"
    echo "Notice: Neither 'kiwi-ng', 'podman', nor 'docker' is installed on host."
    echo ""
    echo "To complete the ISO build in a builder VM or container with kiwi-ng/podman:"
    echo "  1. Install kiwi-ng on builder: pip3 install kiwi-ng OR apt-get install kiwi"
    echo "  2. Run: kiwi-ng system build --description '${PROFILE_DIR}' --target-dir '${OUTPUT_DIR}'"
    echo "=========================================================================="
fi

echo "=== KIWI NG Build Process Finished ==="
if [ -f "${OUTPUT_DIR}"/*.iso ]; then
    echo "Generated Live ISO artifact(s):"
    ls -lh "${OUTPUT_DIR}"/*.iso
    sha256sum "${OUTPUT_DIR}"/*.iso
fi
exit 0
