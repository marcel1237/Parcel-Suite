#!/bin/bash
# Apply Internal Branding: Ubuntu -> PlayOS
# Este script deve ser executado dentro do rootfs (chroot) ou via OverlayFS.

set -e

echo ">> Aplicando branding interno PlayOS..."

# 1. /etc/os-release
if [ -f /etc/os-release ]; then
    sed -i 's/NAME="Ubuntu"/NAME="PlayOS"/g' /etc/os-release
    sed -i 's/PRETTY_NAME="Ubuntu 26.04/PRETTY_NAME="PlayOS 26.04/g' /etc/os-release
    sed -i 's/ID=ubuntu/ID=playos/g' /etc/os-release
    sed -i 's/ID_LIKE=debian/ID_LIKE="ubuntu debian"/g' /etc/os-release
fi

# 2. /etc/lsb-release
if [ -f /etc/lsb-release ]; then
    sed -i 's/DISTRIB_ID=Ubuntu/DISTRIB_ID=PlayOS/g' /etc/lsb-release
    sed -i 's/DISTRIB_DESCRIPTION="Ubuntu/DISTRIB_DESCRIPTION="PlayOS/g' /etc/lsb-release
fi

# 3. /etc/hostname
echo "playos" > /etc/hostname

# 4. /etc/issue
if [ -f /etc/issue ]; then
    echo "PlayOS 26.04 \n \l" > /etc/issue
fi

# 5. Configuração do APT (Manter repositórios Ubuntu, mas com nome PlayOS)
echo "Aviso: Repositórios Ubuntu mantidos para compatibilidade binária."

echo ">> Branding interno aplicado com sucesso."
