#!/bin/bash
# Prep hook to configure apt to allow insecure/unsigned repositories in chroot image-root
set -e
for rootdir in output/build/image-root /output/build/image-root /tmp/kiwi-live/output/build/image-root; do
    if [ -d "$rootdir" ]; then
        mkdir -p "$rootdir/etc/apt/apt.conf.d"
        cat << 'EOF' > "$rootdir/etc/apt/apt.conf.d/99unauthenticated"
Acquire::AllowInsecureRepositories "true";
Acquire::AllowWeakRepositories "true";
APT::Get::AllowUnauthenticated "true";
EOF
        echo "Wrote 99unauthenticated to $rootdir/etc/apt/apt.conf.d/"
    fi
done
exit 0
