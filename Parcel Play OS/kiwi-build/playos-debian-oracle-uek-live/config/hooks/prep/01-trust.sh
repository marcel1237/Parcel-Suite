#!/bin/bash
# Prep hook to propagate trusted keyring and unauthenticated settings into chroot image-root
set -e
for rootdir in output/build/image-root /output/build/image-root /tmp/kiwi-live/output/build/image-root; do
    if [ -d "$rootdir" ]; then
        mkdir -p "$rootdir/etc/apt/apt.conf.d" "$rootdir/etc/apt/trusted.gpg.d"
        echo 'Acquire::AllowInsecureRepositories "true";' > "$rootdir/etc/apt/apt.conf.d/99unauthenticated"
        echo 'Acquire::AllowWeakRepositories "true";' >> "$rootdir/etc/apt/apt.conf.d/99unauthenticated"
        echo 'APT::Get::AllowUnauthenticated "true";' >> "$rootdir/etc/apt/apt.conf.d/99unauthenticated"
        if [ -d /var/cache/kiwi/apt-get/trusted.gpg.d ]; then
            cp -a /var/cache/kiwi/apt-get/trusted.gpg.d/* "$rootdir/etc/apt/trusted.gpg.d/" 2>/dev/null || true
        fi
        if [ -f /var/cache/kiwi/apt-get/trusted.gpg ]; then
            cp -f /var/cache/kiwi/apt-get/trusted.gpg "$rootdir/etc/apt/trusted.gpg.d/playos-local.gpg"
        fi
        echo "Configured image-root apt trusted keyring and security settings at $rootdir"
    fi
done
exit 0
