#!/bin/bash
# Debug and trust prep hook
set -e
echo "=== Debugging Prep Hook 01-trust.sh ==="
for rootdir in output/build/image-root /output/build/image-root /tmp/kiwi-live/output/build/image-root .; do
    if [ -d "$rootdir" ]; then
        for srcfile in $(find "$rootdir" -name "*.sources" -o -name "*.list" 2>/dev/null || true); do
            echo "Found source file: $srcfile"
            if grep -q "playos-oracle-uek" "$srcfile"; then
                if ! grep -q "Trusted: yes" "$srcfile"; then
                    echo "Trusted: yes" >> "$srcfile"
                    echo "Appended Trusted: yes to $srcfile"
                fi
            fi
        done
    fi
done
exit 0
