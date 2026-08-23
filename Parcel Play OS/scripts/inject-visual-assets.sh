#!/bin/bash
# inject-visual-assets.sh - v1.2.0
# Substituição ULTRA-agressiva de ativos visuais Ubuntu/Resolute -> PlayOS

set -e

TARGET_DIR=${1:-""} 
ASSETS_DIR="assets"

echo ">> [Assets] Iniciando substituição de ativos visuais em $TARGET_DIR..."

# 1. Substituir Logotipos do Plymouth (Boot Splash)
PLYMOUTH_THEME="$TARGET_DIR/usr/share/plymouth/themes/ubuntu-logo"
if [ -d "$PLYMOUTH_THEME" ] && [ -f "$ASSETS_DIR/logo.png" ]; then
    echo ">> [Splash] Trocando logo do Plymouth..."
    cp "$ASSETS_DIR/logo.png" "$PLYMOUTH_THEME/ubuntu-logo.png"
    cp "$ASSETS_DIR/logo.png" "$PLYMOUTH_THEME/logo.png"
fi

# 2. Substituir Papéis de Parede Padrão (Limpeza em massa)
BACKGROUNDS_DIR="$TARGET_DIR/usr/share/backgrounds"
if [ -d "$BACKGROUNDS_DIR" ] && [ -f "$ASSETS_DIR/wallpaper.jpg" ]; then
    echo ">> [Wallpaper] Sobrescrevendo todos os planos de fundo Ubuntu/Raccoon..."
    mkdir -p "$BACKGROUNDS_DIR/playos"
    cp "$ASSETS_DIR/wallpaper.jpg" "$BACKGROUNDS_DIR/playos/default.jpg"
    
    # Sobrescrever arquivos específicos identificados na auditoria
    # -name "*ubuntu*" -o -name "*raccoon*" -o -name "warty*"
    find "$BACKGROUNDS_DIR" -type f \( -name "*ubuntu*" -o -name "*raccoon*" -o -name "warty*" \) -exec cp "$ASSETS_DIR/wallpaper.jpg" {} \;
    
    # Garantir o link simbólico histórico
    rm -f "$BACKGROUNDS_DIR/warty-final-ubuntu.png"
    cp "$ASSETS_DIR/wallpaper.jpg" "$BACKGROUNDS_DIR/warty-final-ubuntu.png"
fi

# 3. Ícones de Distribuidor (Menu e Barra de Tarefas)
ICONS_DIR="$TARGET_DIR/usr/share/icons/hicolor"
if [ -f "$ASSETS_DIR/logo.svg" ]; then
    echo ">> [Icons] Trocando ícones de distribuidor em hicolor..."
    find "$ICONS_DIR" -name "distributor-logo-ubuntu*" -exec cp "$ASSETS_DIR/logo.svg" {} \;
    
    # Tentar atingir outros temas se existirem (Yaru)
    YARU_ICONS="$TARGET_DIR/usr/share/icons/Yaru"
    if [ -d "$YARU_ICONS" ]; then
        echo ">> [Icons] Trocando ícones no tema Yaru..."
        find "$YARU_ICONS" -name "distributor-logo-ubuntu*" -exec cp "$ASSETS_DIR/logo.svg" {} \;
    fi
fi

# 4. Texto do Painel de Controle (GNOME)
GLIB_SCHEMAS="$TARGET_DIR/usr/share/glib-2.0/schemas"
if [ -d "$GLIB_SCHEMAS" ]; then
    echo ">> [UI] Injetando overrides de GSettings para PlayOS..."
    cat <<G_EOF > "$GLIB_SCHEMAS/99_playos-branding.gschema.override"
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/playos/default.jpg'
picture-uri-dark='file:///usr/share/backgrounds/playos/default.jpg'

[org.gnome.desktop.screensaver]
picture-uri='file:///usr/share/backgrounds/playos/default.jpg'
G_EOF
fi

echo ">> [Assets] Ativos visuais PlayOS injetados com sucesso."
