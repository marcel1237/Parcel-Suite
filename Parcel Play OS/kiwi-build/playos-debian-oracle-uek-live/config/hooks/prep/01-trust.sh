#!/bin/bash
# Prep hook to propagate trusted keyring into chroot image-root
set -e
if [ -f /var/cache/kiwi/apt-get/trusted.gpg ]; then
    # Ensure trusted.gpg.d exists in image-root if root is set
    mkdir -p etc/apt/trusted.gpg.d
    cp -f /var/cache/kiwi/apt-get/trusted.gpg etc/apt/trusted.gpg.d/playos-local.gpg
    echo "Propagated trusted keyring to chroot etc/apt/trusted.gpg.d/playos-local.gpg"
fi
exit 0
