#!/bin/bash
# Prep hook to configure apt to allow unauthenticated repositories and keys in chroot image-root
set -e
for rootdir in output/build/image-root /output/build/image-root /tmp/kiwi-live/output/build/image-root; do
    if [ -d "$rootdir" ]; then
        mkdir -p "$rootdir/etc/apt/apt.conf.d" "$rootdir/etc/apt/trusted.gpg.d"
        echo 'Acquire::AllowInsecureRepositories "true";' > "$rootdir/etc/apt/apt.conf.d/99unauthenticated"
        echo 'Acquire::AllowWeakRepositories "true";' >> "$rootdir/etc/apt/apt.conf.d/99unauthenticated"
        echo 'APT::Get::AllowUnauthenticated "true";' >> "$rootdir/etc/apt/apt.conf.d/99unauthenticated"
        if [ -f /var/cache/kiwi/apt-get/trusted.gpg ]; then
            cp -f /var/cache/kiwi/apt-get/trusted.gpg "$rootdir/etc/apt/trusted.gpg.d/playos-local.gpg"
        fi
        echo "Configured image-root apt security settings at $rootdir"
    fi
done
exit 0
