#!/bin/bash
# Prep hook to append Trusted: yes to all apt deb822 sources in chroot image-root
set -e
for rootdir in output/build/image-root /output/build/image-root /tmp/kiwi-live/output/build/image-root; do
    if [ -d "$rootdir" ]; then
        for srcfile in "$rootdir/var/cache/kiwi/apt-get/sources.list.d/"*.sources "$rootdir/etc/apt/sources.list.d/"*.sources; do
            if [ -f "$srcfile" ]; then
                if ! grep -q "Trusted: yes" "$srcfile"; then
                    echo "Trusted: yes" >> "$srcfile"
                    echo "Appended Trusted: yes to $srcfile"
                fi
            fi
        done
    fi
done
exit 0
