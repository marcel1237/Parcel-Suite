#!/bin/bash
# master-build-playos.sh - Script Mestre de Construção da ISO PlayOS
# v1.1.0 - Orquestração Total (RootFS, ISO, Branding e Terminal)
# Este script orquestra a reconstrução do sistema e a geração da ISO final.

set -e

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SCRIPTS_DIR="$PROJECT_DIR/scripts"
ASSETS_DIR="$PROJECT_DIR/assets"

echo "============================================================"
echo "          INICIANDO CONSTRUÇÃO TOTAL DO PLAYOS v1.3.0       "
echo "============================================================"

# 1. Validação de Pré-requisitos
echo ">> [1/4] Validando ambiente e ativos..."

if ! command -v xorriso >/dev/null || ! command -v mksquashfs >/dev/null; then
    echo "ERRO: Ferramentas 'xorriso' ou 'squashfs-tools' não encontradas."
    echo "Instale-as com: sudo apt install xorriso squashfs-tools"
    exit 1
fi

if [ ! -f "$ASSETS_DIR/playos-wallpaper.png" ] || [ ! -f "$ASSETS_DIR/logo.svg" ]; then
    echo "AVISO: Arquivos em 'assets/' incompletos."
    echo "Necessário: playos-wallpaper.png, logo.svg e logo.png para branding total."
    sleep 1
fi

# 2. Reconstrução do RootFS (Branding Interno e Terminal Neon)
echo ">> [2/4] Executando reconstrução do RootFS Live (Exige Sudo)..."
bash "$SCRIPTS_DIR/rebuild-live-rootfs.sh"

# 3. Geração da ISO (Boot Híbrido e Branding Externo)
echo ">> [3/4] Gerando imagem ISO final (v1.1.2 logic)..."
bash "$SCRIPTS_DIR/build-playos-iso.sh"

# 4. Finalização
echo "============================================================"
echo "          SUCESSO: PLAYOS v1.3.0 ESTÁ PRONTO!               "
echo "============================================================"
echo "ISO: build/resolute-mvp/output/playos-26.04-amd64.iso"
echo "Log: O Terminal Neon e Banner ASCII ativados por padrão."
echo "============================================================"
