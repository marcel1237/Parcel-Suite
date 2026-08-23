#!/bin/bash
# ==============================================================================
# PlayOS Ultimate Builder - v1.0.0
# Orquestrador Monolítico de Branding, Transformação e Geração de ISO
# ==============================================================================
# Descrição: Este script realiza a metamorfose completa do Ubuntu para PlayOS,
# abrangendo metadados da ISO, menu de boot, RootFS interno (wallpapers, nomes),
# identidade de terminal (Neon/ASCII) e repacotamento final.
# ==============================================================================

set -e

# --- Configurações de Caminhos ---
PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ISO_TREE="$PROJECT_DIR/build/resolute-mvp/work/iso-tree"
WORK_DIR="$PROJECT_DIR/build/work"
ROOTFS="$WORK_DIR/rootfs"
ASSETS="$PROJECT_DIR/assets"
OUTPUT_DIR="$PROJECT_DIR/build/resolute-mvp/output"
ORIGINAL_ISO="$PROJECT_DIR/build/resolute-mvp/download/resolute-desktop-amd64.iso"
OUTPUT_ISO="$OUTPUT_DIR/playos-26.04-amd64.iso"
GRUB_SOURCE="$PROJECT_DIR/config/boot/grub-playos.cfg"

# --- Cores para o Log ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}============================================================"
echo -e "          PLAYOS ULTIMATE BUILDER - INICIANDO               "
echo -e "============================================================${NC}"

# 1. Validação de Dependências e Ativos
echo -e "\n${YELLOW}>> [1/6] Validando ambiente e ativos...${NC}"

if ! command -v xorriso >/dev/null || ! command -v mksquashfs >/dev/null || ! command -v unsquashfs >/dev/null; then
    echo -e "${RED}ERRO: Ferramentas 'xorriso' ou 'squashfs-tools' não encontradas.${NC}"
    echo "Execute: sudo apt install xorriso squashfs-tools"
    exit 1
fi

if [ ! -f "$ASSETS/wallpaper.jpg" ] || [ ! -f "$ASSETS/logo.svg" ] || [ ! -f "$ASSETS/logo.png" ]; then
    echo -e "${RED}ERRO: Ativos vitais ausentes em 'assets/'.${NC}"
    echo "Certifique-se de que wallpaper.jpg, logo.svg e logo.png estão presentes."
    exit 1
fi

if [ ! -f "$ORIGINAL_ISO" ]; then
    echo -e "${RED}ERRO: ISO original não encontrada em $ORIGINAL_ISO${NC}"
    exit 1
fi

# 2. Transformação do RootFS Interno (SquashFS)
echo -e "\n${YELLOW}>> [2/6] Iniciando Metamorfose do RootFS (Exige Sudo)...${NC}"

# Extração
sudo mkdir -p "$ROOTFS"
echo "Extraindo sistema de arquivos base..."
sudo rm -rf "$ROOTFS"/*
sudo unsquashfs -f -d "$ROOTFS" "$ISO_TREE/casper/minimal.squashfs"

# Branding de Texto Interno
echo "Aplicando nomes e identificadores internos..."
sudo chroot "$ROOTFS" /bin/bash <<CHROOT_EOF
    # os-release
    cat <<OS_EOF > /etc/os-release
NAME="PlayOS"
VERSION="26.04 LTS (Resolute Raccoon)"
ID=playos
ID_LIKE="ubuntu debian"
PRETTY_NAME="PlayOS 26.04"
VERSION_ID="26.04"
HOME_URL="https://github.com/marcel1237"
SUPPORT_URL="https://github.com/marcel1237"
VERSION_CODENAME=playos
UBUNTU_CODENAME=resolute
LOGO=playos-logo
OS_EOF

    # lsb-release
    cat <<LSB_EOF > /etc/lsb-release
DISTRIB_ID=PlayOS
DISTRIB_RELEASE=26.04
DISTRIB_CODENAME=playos
DISTRIB_DESCRIPTION="PlayOS 26.04"
LSB_EOF

    # hostname & issue
    echo "playos" > /etc/hostname
    echo "PlayOS 26.04 \n \l" > /etc/issue

    # Terminal Neon Prompt
    BASHRC="/etc/bash.bashrc"
    sed -i '/PlayOS Neon Prompt/,\$d' "\$BASHRC"
    cat <<B_EOF >> "\$BASHRC"
# PlayOS Neon Prompt
if [ "\$color_prompt" = yes ]; then
    PS1='\[\e[1;32m\]nitro\[\e[0m\]@\[\e[1;36m\]playos\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
else
    PS1='nitro@playos:\w\$ '
fi
B_EOF

    # Banner MOTD (ASCII Art)
    MOTD_FILE="/etc/update-motd.d/00-playos-banner"
    [ -f "/etc/update-motd.d/10-help-text" ] && chmod -x "/etc/update-motd.d/10-help-text"
    cat <<'M_EOF' > "\$MOTD_FILE"
#!/bin/sh
printf "\033[1;32m"
cat <<'ART'
  _____  _              ____   _____
 |  __ \| |            / __ \ / ____|
 | |__) | | __ _ _   _| |  | | (___
 |  ___/| |/ _` | | | | |  | |\___ \
 | |    | | (_| | |_| | |__| |____) |
 |_|    |_|\__,_|\__, |\____/|_____/
                  __/ |
                 |___/
ART
printf "\033[0m"
printf "\033[1;36m   NitroCore Engine | PlayOS 26.04 Resolute\033[0m\n\n"
M_EOF
    chmod +x "\$MOTD_FILE"
CHROOT_EOF

# Branding Visual Interno (Wallpaper/Logos)
echo "Injetando papéis de parede e logotipos..."
sudo mkdir -p "$ROOTFS/usr/share/backgrounds/playos"
sudo cp "$ASSETS/wallpaper.jpg" "$ROOTFS/usr/share/backgrounds/playos/default.jpg"

# Sobrescrever wallpapers teimosos do Ubuntu
sudo find "$ROOTFS/usr/share/backgrounds" -type f \( -name "*ubuntu*" -o -name "*raccoon*" -o -name "warty*" \) -exec cp "$ASSETS/wallpaper.jpg" {} \;

# Ícones de sistema
sudo find "$ROOTFS/usr/share/icons/hicolor" -name "distributor-logo-ubuntu*" -exec cp "$ASSETS/logo.svg" {} \;

# GSettings Override para garantir o Wallpaper no boot
sudo mkdir -p "$ROOTFS/usr/share/glib-2.0/schemas"
sudo cat <<G_EOF > "$ROOTFS/usr/share/glib-2.0/schemas/99_playos-branding.gschema.override"
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/playos/default.jpg'
picture-uri-dark='file:///usr/share/backgrounds/playos/default.jpg'
[org.gnome.desktop.screensaver]
picture-uri='file:///usr/share/backgrounds/playos/default.jpg'
G_EOF
sudo chroot "$ROOTFS" glib-compile-schemas /usr/share/glib-2.0/schemas/

# 3. Compactação do novo RootFS
echo -e "\n${YELLOW}>> [3/6] Repacotando RootFS (ZSTD Compression)...${NC}"
sudo rm -f "$ISO_TREE/casper/minimal.squashfs"
sudo mksquashfs "$ROOTFS" "$ISO_TREE/casper/minimal.squashfs" -comp zstd -b 1M -noappend

# 4. Ajustes na Árvore ISO (Branding Externo)
echo -e "\n${YELLOW}>> [4/6] Limpando metadados externos da ISO...${NC}"
chmod -R u+w "$ISO_TREE"

# Atualizar menu GRUB
if [ -f "$GRUB_SOURCE" ]; then
    cp "$GRUB_SOURCE" "$ISO_TREE/boot/grub/grub.cfg"
    cp "$GRUB_SOURCE" "$ISO_TREE/boot/grub/loopback.cfg"
fi

# Subiquity Install Sources
sed -i 's/Ubuntu Desktop/PlayOS Desktop/g' "$ISO_TREE/casper/install-sources.yaml"

# .disk/info e Release files
echo "PlayOS 26.04 LTS \"Resolute Raccoon\" - Release amd64" > "$ISO_TREE/.disk/info"
sed -i 's/Origin: Ubuntu/Origin: PlayOS/g; s/Label: Ubuntu/Label: PlayOS/g' "$ISO_TREE/dists/resolute/Release"

# Symlink PlayOS
rm -f "$ISO_TREE/ubuntu"
ln -sf . "$ISO_TREE/playos"

# 5. Geração da Imagem ISO Final
echo -e "\n${YELLOW}>> [5/6] Gerando arquivo .iso (Replay Boot Mode)...${NC}"
mkdir -p "$OUTPUT_DIR"

xorriso -as mkisofs \
    -r -V "PLAYOS_2604" \
    -J -joliet-long -l \
    -b boot/grub/i386-pc/eltorito.img \
    -c boot.catalog \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --grub2-boot-info \
    --grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:"$ORIGINAL_ISO" \
    --protective-msdos-label \
    -partition_cyl_align off \
    -partition_offset 16 \
    --mbr-force-bootable \
    -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:12254148d-12264443d::"$ORIGINAL_ISO" \
    -appended_part_as_gpt \
    -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
    -eltorito-alt-boot \
    -e '--interval:appended_partition_2:all::' \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -o "$OUTPUT_ISO" "$ISO_TREE"

# 6. Finalização e Checksum
echo -e "\n${YELLOW}>> [6/6] Calculando integridade...${NC}"
sha256sum "$OUTPUT_ISO" > "$OUTPUT_ISO.sha256"

echo -e "\n${GREEN}============================================================"
echo -e "          CONSTRUÇÃO CONCLUÍDA COM SUCESSO!                 "
echo -e "============================================================"
echo -e " ISO: $OUTPUT_ISO"
echo -e "============================================================${NC}"
