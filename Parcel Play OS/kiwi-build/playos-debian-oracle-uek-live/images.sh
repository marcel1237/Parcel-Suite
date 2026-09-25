#!/bin/bash
# KIWI NG Pre-Archive Image Script for PlayOS Debian + Oracle UEK
set -e

echo "=== PlayOS KIWI NG Images Hook ==="

# Perform final cleanup before image packaging
rm -rf /tmp/* /var/tmp/*
rm -f /etc/ssh/ssh_host_*

echo "PlayOS KIWI NG Image Preparation Completed"
exit 0
