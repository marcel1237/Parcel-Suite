#!/bin/bash
# Força o instalador e o sistema a reconhecerem a nova distro
echo ">> [Distro] Definindo metadados de distribuição..."
mkdir -p /etc/default
echo 'DISTRO_NAME="PlayOS"' > /etc/default/distro
echo 'DISTRIB_ID=PlayOS' >> /etc/default/distro

# Forçar o Gnome a usar o wallpaper injetado em todos os modos
if [ -d "/usr/share/glib-2.0/schemas" ]; then
    cat <<G_EOF > /usr/share/glib-2.0/schemas/10_playos-branding.gschema.override
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/playos/default.jpg'
picture-uri-dark='file:///usr/share/backgrounds/playos/default.jpg'

[org.gnome.desktop.screensaver]
picture-uri='file:///usr/share/backgrounds/playos/default.jpg'
G_EOF
    glib-compile-schemas /usr/share/glib-2.0/schemas/
fi
