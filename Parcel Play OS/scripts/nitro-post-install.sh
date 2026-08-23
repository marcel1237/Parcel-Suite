#!/bin/bash
# nitro-post-install.sh - O cérebro da auto-transformação PlayOS
# Este script roda no final do processo de instalação (Late Commands).

set -e

# O instalador do Ubuntu monta o novo sistema em /target
TARGET="/target"

if [ ! -d "$TARGET" ]; then
    echo "Erro: /target não encontrado. Este script deve rodar no ambiente do instalador."
    exit 1
fi

echo ">> Iniciando Metamorfose PlayOS..."

# 1. Aplicar Branding de Texto (Nomes, OS-Release, Hostname)
# Usamos chroot para que o script apply-internal-branding.sh pense que está no sistema real
cp scripts/apply-internal-branding.sh "$TARGET/tmp/"
chroot "$TARGET" /bin/bash /tmp/apply-internal-branding.sh
rm "$TARGET/tmp/apply-internal-branding.sh"

# 2. Aplicar Branding Visual (Logos, Ícones)
bash scripts/inject-visual-assets.sh "$TARGET"

# 3. Registrar o sucesso no log do sistema instalado
echo "PlayOS metamorfose concluída em $(date)" >> "$TARGET/var/log/playos-install.log"

echo ">> O sistema instalado agora é oficialmente o PlayOS."
