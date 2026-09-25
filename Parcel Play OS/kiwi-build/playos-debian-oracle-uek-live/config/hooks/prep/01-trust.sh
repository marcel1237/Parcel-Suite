#!/bin/bash
# Prep hook to mark local UEK repository as Trusted: yes in chroot deb822 sources
set -e
for rootdir in output/build/image-root /output/build/image-root /tmp/kiwi-live/output/build/image-root; do
    if [ -d "$rootdir" ]; then
        for srcfile in "$rootdir/var/cache/kiwi/apt-get/sources.list.d/"*.sources "$rootdir/etc/apt/sources.list.d/"*.sources "$rootdir/etc/apt/sources.list.d/"*.list; do
            if [ -f "$srcfile" ] && grep -q "playos-oracle-uek" "$srcfile"; then
                if ! grep -q "Trusted: yes" "$srcfile"; then
                    echo "Trusted: yes" >> "$srcfile"
                    echo "Added Trusted: yes to $srcfile"
                fi
            fi
        done
    fi
done
exit 0
