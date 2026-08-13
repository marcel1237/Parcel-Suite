#!/bin/bash
# Etapa 3: Estrutura Óssea (Base System Layout)
# Criação da hierarquia de diretórios FHS 3.0

set -e

DEST_DIR="${BUILD_DIR}/rootfs"

echo "Criando estrutura de diretórios em: $DEST_DIR"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR"

# Criar diretórios padrão do FHS
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin usr/local/bin usr/local/lib
mkdir -p var/log var/mail var/spool var/tmp

# Permissões específicas
chmod 1777 tmp var/tmp

echo "Estrutura FHS 3.0 criada com sucesso."

# Placeholders para Instalação de Desktop (Etapa 7)
# Note: Estas ações são executadas via chroot no ambiente build-env
# if [ "$SELECTED_SESSION" == "full" ]; then
#    apt install -y kde-full sddm
# else
#    apt install -y ubuntu-desktop gdm3
# fi
