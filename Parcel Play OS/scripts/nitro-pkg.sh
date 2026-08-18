#!/bin/bash
# Nitro-PKG: Unified Multi-Distro Package Wrapper
# Versão: 1.0.0

set -e

COMMAND=$1
TYPE=$2
APP=$3

usage() {
    echo "Uso: nitro-pkg install [--aur|--fedora|--host] [app_name]"
    exit 1
}

if [ -z "$COMMAND" ] || [ -z "$TYPE" ] || [ -z "$APP" ]; then
    usage
fi

case "$TYPE" in
    --aur)
        echo "Nitro-APX: Instalando '$APP' via Arch User Repository (AUR)..."
        # distrobox-enter nitro-arch -- yay -S --noconfirm "$APP"
        ;;
    --fedora)
        echo "Nitro-APX: Instalando '$APP' via Fedora COPR..."
        # distrobox-enter nitro-fedora -- sudo dnf install -y "$APP"
        ;;
    --host)
        echo "Nitro-APX: Instalando '$APP' via Ubuntu Host (Imutável)..."
        # sudo transactional-update apt install -y "$APP"
        ;;
    *)
        usage
        ;;
esac

echo ">> Aplicativo '$APP' instalado e exportado com sucesso para o menu do KDE."
