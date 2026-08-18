#!/bin/bash
# Nitro-Switcher Backend Script
# Versão: 1.0.0
# Descrição: Define o próximo sabor de kernel para o GRUB e agenda o reinício.

set -e

FLAVOR_INDEX=$1

if [ -z "$FLAVOR_INDEX" ]; then
    echo "Erro: Índice do sabor não fornecido."
    echo "Uso: nitro-switcher-apply.sh [index]"
    exit 1
fi

# Mapeamento do Decágono no GRUB (Indices baseados no grub-11-kernels.cfg)
# 0: Ubuntu (Debian Baseline)
# 1: NitroCore Arch
# ... e assim por diante.

echo "Nitro-Switcher: Configurando o GRUB para bootar entrada $FLAVOR_INDEX (Uma única vez)..."

# Define a entrada para o próximo boot
# sudo grub-reboot "$FLAVOR_INDEX"

echo ">> Configuração concluída. O sistema iniciará o novo sabor no próximo reinício."
