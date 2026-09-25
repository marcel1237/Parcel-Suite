#!/bin/bash
# Prep hook to configure apt to allow unauthenticated repositories in chroot
set -e
if [ -d etc/apt/apt.conf.d ]; then
    echo 'Acquire::AllowInsecureRepositories "true";' > etc/apt/apt.conf.d/99unauthenticated
    echo 'Acquire::AllowWeakRepositories "true";' >> etc/apt/apt.conf.d/99unauthenticated
    echo 'APT::Get::AllowUnauthenticated "true";' >> etc/apt/apt.conf.d/99unauthenticated
    echo "Configured chroot etc/apt/apt.conf.d/99unauthenticated"
fi
exit 0
