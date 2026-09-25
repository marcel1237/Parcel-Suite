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
    if command -v rpm2cpio >/dev/null 2>&1; then
        rpm2cpio "${rpm}" | cpio -idmv >/dev/null 2>&1 || true
    elif command -v 7z >/dev/null 2>&1; then
        7z x -y "${rpm}" >/dev/null 2>&1 || true
        for cpiofile in *.cpio *.cpio.zst *.cpio.xz *.cpio.gz; do
            if [ -f "$cpiofile" ]; then
                if [[ "$cpiofile" == *.zst ]]; then
                    7z x -y "$cpiofile" >/dev/null 2>&1 || true
                fi
                cpio -idmv < "${cpiofile%.zst}" >/dev/null 2>&1 || true
                rm -f "$cpiofile" "${cpiofile%.zst}"
            fi
        done
    fi
done

UEK_KVER=$(ls lib/modules 2>/dev/null | grep uek | head -n 1 || true)
if [ -z "${UEK_KVER}" ]; then
    echo "Error: Could not identify extracted UEK kernel version in lib/modules!"
    exit 1
fi

UEK_DEB_VER=$(echo "${UEK_KVER}" | tr '_' '-')
echo "Identified Oracle UEK Kernel Version: ${UEK_KVER} (DEB Version: ${UEK_DEB_VER})"

echo "3. Packaging oracle-kernel-uek-image DEB..."
mkdir -p "${WORK_DIR}/pkg-image/boot"
if [ -f "boot/vmlinuz-${UEK_KVER}" ]; then
    cp -a "boot/vmlinuz-${UEK_KVER}" "${WORK_DIR}/pkg-image/boot/vmlinuz-${UEK_KVER}"
elif [ -f "lib/modules/${UEK_KVER}/vmlinuz" ]; then
    cp -a "lib/modules/${UEK_KVER}/vmlinuz" "${WORK_DIR}/pkg-image/boot/vmlinuz-${UEK_KVER}"
elif ls boot/vmlinuz-* >/dev/null 2>&1; then
    cp -a boot/vmlinuz-* "${WORK_DIR}/pkg-image/boot/vmlinuz-${UEK_KVER}"
fi

cp -a "boot/config-${UEK_KVER}" "${WORK_DIR}/pkg-image/boot/config-${UEK_KVER}" 2>/dev/null || true
cp -a "boot/System.map-${UEK_KVER}" "${WORK_DIR}/pkg-image/boot/System.map-${UEK_KVER}" 2>/dev/null || true

cat << EOF > "${WORK_DIR}/pkg-image/DEBIAN/control"
Package: oracle-kernel-uek-image
Version: ${UEK_DEB_VER}
Architecture: amd64
Maintainer: PlayOS Engineering <playos-dev@local>
Description: Oracle Unbreakable Enterprise Kernel (UEK) binary image for PlayOS Debian Live
 Provides Oracle UEK kernel (vmlinuz-${UEK_KVER}) packaged for Debian userspace.
EOF

dpkg-deb --build "${WORK_DIR}/pkg-image" "${REPO_DIR}/oracle-kernel-uek-image_${UEK_DEB_VER}_amd64.deb"

echo "4. Packaging oracle-kernel-uek-modules DEB..."
mkdir -p "${WORK_DIR}/pkg-modules/lib/modules"
cp -a "lib/modules/${UEK_KVER}" "${WORK_DIR}/pkg-modules/lib/modules/"

cat << EOF > "${WORK_DIR}/pkg-modules/DEBIAN/control"
Package: oracle-kernel-uek-modules
Version: ${UEK_DEB_VER}
Architecture: amd64
Maintainer: PlayOS Engineering <playos-dev@local>
Depends: oracle-kernel-uek-image
Description: Oracle Unbreakable Enterprise Kernel (UEK) modules for PlayOS Debian Live
 Provides kernel modules for Oracle UEK (${UEK_KVER}) packaged for Debian userspace.
EOF

dpkg-deb --build "${WORK_DIR}/pkg-modules" "${REPO_DIR}/oracle-kernel-uek-modules_${UEK_DEB_VER}_amd64.deb"

echo "4b. Packaging dracut-kiwi-live metapackage for KIWI NG compatibility..."
mkdir -p "${WORK_DIR}/pkg-kiwi-live/DEBIAN"
cat << EOF > "${WORK_DIR}/pkg-kiwi-live/DEBIAN/control"
Package: dracut-kiwi-live
Version: 1.0.0
Architecture: all
Maintainer: PlayOS Engineering <playos-dev@local>
Depends: live-boot, dracut, dracut-live
Description: KIWI NG live ISO metapackage for PlayOS Debian userspace
 Provides dracut-kiwi-live dependency for KIWI NG live ISO generation.
EOF

dpkg-deb --build "${WORK_DIR}/pkg-kiwi-live" "${REPO_DIR}/dracut-kiwi-live_1.0.0_all.deb"

echo "5. Generating standard Debian repository structure in ${REPO_DIR}..."
cd "${REPO_DIR}"
rm -rf dists pool
mkdir -p dists/trixie/main/binary-amd64 pool/main
mv *.deb pool/main/ 2>/dev/null || true

cat << 'EOF' > apt-ftparchive.conf
Dir::ArchiveDir ".";
TreeDefault::Directory ".";
TreeDefault::SrcDirectory ".";
Default::Packages::Extensions ".deb";
Default::Packages::Compress ". gzip";

BinDirectory "pool/main" {
    Packages "dists/trixie/main/binary-amd64/Packages";
    BinOverride "";
    ExtraOverride "";
};
EOF

apt-ftparchive generate apt-ftparchive.conf
gzip -c9 dists/trixie/main/binary-amd64/Packages > dists/trixie/main/binary-amd64/Packages.gz
apt-ftparchive release dists/trixie > dists/trixie/Release

# Generate local GPG signing key for local repository authentication
if ! gpg --list-keys "PlayOS Local" >/dev/null 2>&1; then
    cat << 'EOF' > /tmp/gpg-batch
%no-protection
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Name-Real: PlayOS Local
Name-Email: playos@local
Expire-Date: 0
%commit
EOF
    gpg --batch --generate-key /tmp/gpg-batch
    rm -f /tmp/gpg-batch
fi

cd dists/trixie
rm -f Release.gpg InRelease
gpg --batch --yes --default-key "PlayOS Local" --armor --detach-sign -o Release.gpg Release
gpg --batch --yes --default-key "PlayOS Local" --armor --clearsign -o InRelease Release
cd "${REPO_DIR}"

gpg --armor --export "PlayOS Local" > "${REPO_DIR}/playos-repo.key"
cp -a "${REPO_DIR}/playos-repo.key" /tmp/playos-repo.key
chmod 644 /tmp/playos-repo.key

sudo rm -rf /var/local/playos-uek-repo
sudo mkdir -p /var/local/playos-uek-repo
sudo cp -a "${REPO_DIR}/"* /var/local/playos-uek-repo/
echo "Signed Debian repository mirrored to: /var/local/playos-uek-repo"

echo "=== Oracle UEK DEB Packaging & Local Repository Ready ==="
echo "Repository path: ${REPO_DIR}"
exit 0
