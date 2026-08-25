#!/bin/bash
# Apply Internal Branding: Ubuntu -> PlayOS
# v1.4.0 - Suporte Total a Branding (os-release, wallpaper, terminal, MOTD)
# Este script deve ser executado dentro do rootfs (chroot) ou via OverlayFS.

set -e

echo ">> [Identity] Aplicando branding interno PlayOS v1.4.0..."

# 1. /etc/os-release (Reforço para o Instalador)
if [ -f /etc/os-release ]; then
    cat <<OS_EOF > /etc/os-release
NAME="PlayOS"
VERSION="26.04 LTS (Resolute Raccoon)"
ID=playos
ID_LIKE="ubuntu debian"
PRETTY_NAME="PlayOS 26.04"
VERSION_ID="26.04"
HOME_URL="https://github.com/marcel1237"
SUPPORT_URL="https://github.com/marcel1237"
BUG_REPORT_URL="https://github.com/marcel1237"
PRIVACY_POLICY_URL="https://github.com/marcel1237"
VERSION_CODENAME=playos
UBUNTU_CODENAME=resolute
LOGO=playos-logo
OS_EOF
fi

# 2. /etc/lsb-release
if [ -f /etc/lsb-release ]; then
    cat <<LSB_EOF > /etc/lsb-release
DISTRIB_ID=PlayOS
DISTRIB_RELEASE=26.04
DISTRIB_CODENAME=playos
DISTRIB_DESCRIPTION="PlayOS 26.04"
LSB_EOF
fi

# 3. /etc/hostname
echo "playos" > /etc/hostname

# 4. /etc/issue
if [ -f /etc/issue ]; then
    echo "PlayOS 26.04 \n \l" > /etc/issue
fi

# 5. Interface Gráfica (Wallpapers e Temas)
echo ">> [UI] Ajustando preferências visuais do sistema..."
mkdir -p /usr/share/glib-2.0/schemas/
cat <<G_EOF > /usr/share/glib-2.0/schemas/99_playos-settings.gschema.override
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/playos/default.png'
picture-uri-dark='file:///usr/share/backgrounds/playos/default.png'
primary-color='#232629'

[org.gnome.desktop.screensaver]
picture-uri='file:///usr/share/backgrounds/playos/default.png'

[org.gnome.shell.extensions.dash-to-dock]
background-opacity=0.4
G_EOF

if command -v glib-compile-schemas >/dev/null; then
    glib-compile-schemas /usr/share/glib-2.0/schemas/
fi

# 6. Terminal Neon (BASH Prompt)
echo ">> [Shell] Configurando Terminal Neon PlayOS..."
BASHRC="/etc/bash.bashrc"
if [ -f "$BASHRC" ]; then
    # Remover versões anteriores para evitar duplicidade
    sed -i '/PlayOS Neon Prompt/,$d' "$BASHRC"
    cat <<B_EOF >> "$BASHRC"

# PlayOS Neon Prompt
if [ "\$color_prompt" = yes ]; then
    PS1='\[\e[1;32m\]nitro\[\e[0m\]@\[\e[1;36m\]playos\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
else
    PS1='nitro@playos:\w\$ '
fi
B_EOF
fi

# 7. Banner MOTD (ASCII Art de Boas-vindas)
echo ">> [MOTD] Injetando Banner PlayOS no Login..."
MOTD_DIR="/etc/update-motd.d"
if [ -d "$MOTD_DIR" ]; then
    [ -f "$MOTD_DIR/10-help-text" ] && chmod -x "$MOTD_DIR/10-help-text"

    cat <<'M_EOF' > "$MOTD_DIR/00-playos-banner"
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
    chmod +x "$MOTD_DIR/00-playos-banner"
fi

# 8. Configuração do APT
echo "Aviso: Repositórios Ubuntu mantidos para compatibilidade binária."
echo ">> [Success] Branding interno v1.4.0 aplicado com sucesso."
