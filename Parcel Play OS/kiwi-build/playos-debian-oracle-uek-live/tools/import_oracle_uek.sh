#!/bin/bash
# Tool: Import Oracle Unbreakable Enterprise Kernel (UEK) RPMs and packaging into DEB for KIWI NG
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${PROFILE_DIR}/work"
REPO_DIR="${PROFILE_DIR}/repo"

echo "=== PlayOS Oracle UEK Kernel Importer for KIWI NG ==="

mkdir -p "${WORK_DIR}/rpms" "${WORK_DIR}/pkg-image/DEBIAN" "${WORK_DIR}/pkg-modules/DEBIAN" "${REPO_DIR}"

# Oracle UEK R7 Repository URL (Oracle Linux 9 x86_64)
UEK_REPO_URL="https://yum.oracle.com/repo/OracleLinux/OL9/UEKR7/x86_64/getPackage"

echo "1. Checking local Oracle UEK RPMs in ${WORK_DIR}/rpms..."
if ! ls "${WORK_DIR}/rpms"/kernel-uek-*.rpm >/dev/null 2>&1; then
    echo "Notice: No local kernel-uek RPMs found in ${WORK_DIR}/rpms. Downloading automatically..."
    curl -sSL "https://yum.oracle.com/repo/OracleLinux/OL9/UEKR7/x86_64/getPackage/kernel-uek-core-5.15.0-200.131.27.el9uek.x86_64.rpm" -o "${WORK_DIR}/rpms/kernel-uek-core-5.15.0-200.131.27.el9uek.x86_64.rpm"
    curl -sSL "https://yum.oracle.com/repo/OracleLinux/OL9/UEKR7/x86_64/getPackage/kernel-uek-modules-5.15.0-200.131.27.el9uek.x86_64.rpm" -o "${WORK_DIR}/rpms/kernel-uek-modules-5.15.0-200.131.27.el9uek.x86_64.rpm"
fi

echo "2. Extracting Oracle UEK RPM contents..."
cd "${WORK_DIR}"
for rpm in rpms/*.rpm; do
    echo "  Extracting ${rpm}..."
    rpm2cpio "${rpm}" | cpio -idmv >/dev/null 2>&1 || true
done

UEK_KVER=$(ls lib/modules 2>/dev/null | grep uek | head -n 1 || true)
if [ -z "${UEK_KVER}" ]; then
    echo "Error: Could not identify extracted UEK kernel version in lib/modules!"
    exit 1
fi

echo "Identified Oracle UEK Kernel Version: ${UEK_KVER}"

echo "3. Packaging oracle-kernel-uek-image DEB..."
mkdir -p "${WORK_DIR}/pkg-image/boot"
cp -a boot/vmlinuz-${UEK_KVER} "${WORK_DIR}/pkg-image/boot/vmlinuz-${UEK_KVER}"
cp -a boot/config-${UEK_KVER} "${WORK_DIR}/pkg-image/boot/config-${UEK_KVER}" 2>/dev/null || true
cp -a boot/System.map-${UEK_KVER} "${WORK_DIR}/pkg-image/boot/System.map-${UEK_KVER}" 2>/dev/null || true

cat << EOF > "${WORK_DIR}/pkg-image/DEBIAN/control"
Package: oracle-kernel-uek-image
Version: ${UEK_KVER}
Architecture: amd64
Maintainer: PlayOS Engineering <playos-dev@local>
Description: Oracle Unbreakable Enterprise Kernel (UEK) binary image for PlayOS Debian Live
 Provides Oracle UEK kernel (vmlinuz-${UEK_KVER}) packaged for Debian userspace.
EOF

dpkg-deb --build "${WORK_DIR}/pkg-image" "${REPO_DIR}/oracle-kernel-uek-image_${UEK_KVER}_amd64.deb"

echo "4. Packaging oracle-kernel-uek-modules DEB..."
mkdir -p "${WORK_DIR}/pkg-modules/lib/modules"
cp -a "lib/modules/${UEK_KVER}" "${WORK_DIR}/pkg-modules/lib/modules/"

cat << EOF > "${WORK_DIR}/pkg-modules/DEBIAN/control"
Package: oracle-kernel-uek-modules
Version: ${UEK_KVER}
Architecture: amd64
Maintainer: PlayOS Engineering <playos-dev@local>
Depends: oracle-kernel-uek-image
Description: Oracle Unbreakable Enterprise Kernel (UEK) modules for PlayOS Debian Live
 Provides kernel modules for Oracle UEK (${UEK_KVER}) packaged for Debian userspace.
EOF

dpkg-deb --build "${WORK_DIR}/pkg-modules" "${REPO_DIR}/oracle-kernel-uek-modules_${UEK_KVER}_amd64.deb"

echo "5. Generating local APT repository index in ${REPO_DIR}..."
cd "${REPO_DIR}"
apt-ftparchive packages . > Packages
gzip -c9 Packages > Packages.gz

echo "=== Oracle UEK DEB Packaging & Local Repository Ready ==="
echo "Repository path: ${REPO_DIR}"
exit 0
