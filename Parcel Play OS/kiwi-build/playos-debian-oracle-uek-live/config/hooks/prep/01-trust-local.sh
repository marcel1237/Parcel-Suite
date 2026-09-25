#!/bin/bash
# Prep hook to trust local unsigned UEK repository in KIWI NG deb822 sources
set -e
SOURCE_FILE="/var/cache/kiwi/apt-get/sources.list.d/playos-oracle-uek.sources"
if [ -f "$SOURCE_FILE" ]; then
    if ! grep -q "Trusted: yes" "$SOURCE_FILE"; then
        echo "Trusted: yes" >> "$SOURCE_FILE"
        echo "Added Trusted: yes to $SOURCE_FILE"
    fi
fi
exit 0
