#!/bin/bash
# Prep hook to mark playos-oracle-uek sources as Trusted: yes
set -e
for srcfile in /var/cache/kiwi/apt-get/sources.list.d/* output/build/image-root/var/cache/kiwi/apt-get/sources.list.d/* /tmp/kiwi-live/output/build/image-root/var/cache/kiwi/apt-get/sources.list.d/*; do
    if [ -f "$srcfile" ] && grep -q "playos-oracle-uek" "$srcfile"; then
        if ! grep -q "Trusted: yes" "$srcfile"; then
            echo "Trusted: yes" >> "$srcfile"
            echo "Added Trusted: yes to $srcfile"
        fi
    fi
done
exit 0
