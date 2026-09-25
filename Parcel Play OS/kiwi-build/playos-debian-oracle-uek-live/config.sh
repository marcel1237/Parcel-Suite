#!/bin/bash
# KIWI NG Configuration Script for PlayOS Debian + Oracle UEK
set -e

echo "=== PlayOS KIWI NG Post-Installation Hook ==="

# 1. Configure default target for systemd
systemctl set-default graphical.target

# 2. Enable Live services
if systemctl list-unit-files | grep -q NetworkManager; then
    systemctl enable NetworkManager.service
fi

if systemctl list-unit-files | grep -q lightdm; then
    systemctl enable lightdm.service
fi

# 3. Configure Dracut to support Oracle UEK and Live Boot OverlayFS
if [ -d /etc/dracut.conf.d ]; then
    cat << 'EOF' > /etc/dracut.conf.d/playos-uek.conf
add_dracutmodules+=" dmsquash-live pollcdrom qemu qemu-net "
filesystems+=" overlay squashfs iso9660 ext4 "
drivers+=" overlay loop squashfs "
EOF
fi

# 4. Generate Initramfs for Oracle UEK kernel
UEK_VERSION=$(ls /lib/modules | grep uek | tail -n 1)
if [ -n "$UEK_VERSION" ]; then
    echo "Generating dracut initramfs for Oracle UEK kernel version: $UEK_VERSION"
    dracut --force --kver "$UEK_VERSION" /boot/initrd.img-"$UEK_VERSION"
fi

# 5. Clean APT cache to minimize SquashFS image size
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "=== PlayOS KIWI NG Configuration Completed ==="
exit 0
