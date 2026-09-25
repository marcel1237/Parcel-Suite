#!/bin/bash
# KIWI NG Configuration Script for PlayOS Debian + Oracle UEK
set -e

echo "=== PlayOS KIWI NG Post-Installation Hook ==="

# 1. Configure trusted local APT repository for Oracle UEK kernel
echo "deb [trusted=yes] file:///var/local/playos-uek-repo trixie main" > /etc/apt/sources.list.d/playos-uek.list
apt-get update

# 2. Install Oracle UEK kernel image and modules
apt-get install -y --allow-unauthenticated oracle-kernel-uek-image oracle-kernel-uek-modules

# 3. Configure default target for systemd
systemctl set-default graphical.target

# 4. Enable Live services
if systemctl list-unit-files | grep -q NetworkManager; then
    systemctl enable NetworkManager.service
fi

if systemctl list-unit-files | grep -q lightdm; then
    systemctl enable lightdm.service
fi

# 5. Configure Dracut to support Oracle UEK and Live Boot OverlayFS
if [ -d /etc/dracut.conf.d ]; then
    cat << 'EOF' > /etc/dracut.conf.d/playos-uek.conf
add_dracutmodules+=" dmsquash-live pollcdrom qemu qemu-net "
filesystems+=" overlay squashfs iso9660 ext4 "
drivers+=" overlay loop squashfs "
EOF
fi

# 6. Generate Initramfs for Oracle UEK kernel
UEK_VERSION=$(ls /lib/modules | grep uek | tail -n 1)
if [ -n "$UEK_VERSION" ]; then
    echo "Generating dracut initramfs for Oracle UEK kernel version: $UEK_VERSION"
    dracut --force --kver "$UEK_VERSION" /boot/initrd.img-"$UEK_VERSION"
fi

# 7. Clean APT cache to minimize SquashFS image size
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "=== PlayOS KIWI NG Configuration Completed ==="
exit 0
