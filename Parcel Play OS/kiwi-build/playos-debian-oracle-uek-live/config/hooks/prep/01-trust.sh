#!/bin/bash
# Prep hook to copy trusted keyring into chroot image-root etc/apt/trusted.gpg.d/
set -e
for rootdir in output/build/image-root /output/build/image-root /tmp/kiwi-live/output/build/image-root; do
    if [ -d "$rootdir" ]; then
        mkdir -p "$rootdir/etc/apt/trusted.gpg.d"
        if [ -f /var/cache/kiwi/apt-get/trusted.gpg ]; then
            cp -f /var/cache/kiwi/apt-get/trusted.gpg "$rootdir/etc/apt/trusted.gpg.d/playos-local.gpg"
            echo "Copied trusted.gpg to $rootdir/etc/apt/trusted.gpg.d/playos-local.gpg"
        fi
    fi
done
exit 0
