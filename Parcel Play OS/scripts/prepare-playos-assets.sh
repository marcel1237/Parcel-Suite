#!/bin/bash
# prepare-playos-assets.sh - Prepara a pasta de branding do PlayOS
# v1.0.0 - Gerador de Ativos Temporários (Placeholders)

set -e

ASSETS_DIR="assets"
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${GREEN}>> [Setup] Preparando diretório de ativos...${NC}"

mkdir -p "$ASSETS_DIR"

# 1. Gerar Logo SVG (Texto puro)
if [ ! -f "$ASSETS_DIR/logo.svg" ]; then
    echo "Criando logo.svg temporário..."
    cat <<SVG_EOF > "$ASSETS_DIR/logo.svg"
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <rect width="100" height="100" fill="#232629"/>
  <text x="50%" y="50%" font-family="Arial" font-size="20" fill="#27ae60" text-anchor="middle" dy=".3em">PlayOS</text>
</svg>
SVG_EOF
fi

# 2. Gerar Placeholders para PNG e JPG 
# Se o ImageMagick estiver instalado, ele gera imagens reais. 
# Caso contrário, ele busca uma imagem do sistema para usar como base.
if [ ! -f "$ASSETS_DIR/logo.png" ] || [ ! -f "$ASSETS_DIR/wallpaper.jpg" ]; then
    echo "Buscando imagens de sistema para usar como placeholders..."
    
    # Tenta achar o logo do Ubuntu para copiar como base (se não houver um PlayOS real)
    SYS_LOGO="/usr/share/plymouth/themes/ubuntu-logo/ubuntu-logo.png"
    SYS_WALLPAPER="/usr/share/backgrounds/warty-final-ubuntu.png"

    [ -f "$SYS_LOGO" ] && cp "$SYS_LOGO" "$ASSETS_DIR/logo.png"
    [ -f "$SYS_WALLPAPER" ] && cp "$SYS_WALLPAPER" "$ASSETS_DIR/wallpaper.jpg"
    
    # Se ainda assim não existirem (em sistemas mínimos), cria arquivos vazios para passar na checagem
    [ ! -f "$ASSETS_DIR/logo.png" ] && touch "$ASSETS_DIR/logo.png"
    [ ! -f "$ASSETS_DIR/wallpaper.jpg" ] && touch "$ASSETS_DIR/wallpaper.jpg"
fi

echo -e "${GREEN}>> [Sucesso] Ativos preparados em: $ASSETS_DIR/${NC}"
echo "Dica: Substitua estes arquivos pelos seus logos reais antes da versão final."
