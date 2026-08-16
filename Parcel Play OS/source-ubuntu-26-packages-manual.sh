#!/usr/bin/env bash

set -u
set -o pipefail

ROOT="$HOME/ubuntu26-source"

echo "======================================================"
echo " Ubuntu 26.04 Resolute - Source Tree"
echo "======================================================"

# ------------------------------------------------------
# Dependências
# ------------------------------------------------------

sudo apt update
sudo apt install -y \
    git \
    dpkg-dev \
    devscripts \
    build-essential \
    ca-certificates

# ------------------------------------------------------
# deb-src Resolute
# ------------------------------------------------------

sudo tee /etc/apt/sources.list.d/resolute-src.sources >/dev/null <<'EOF'
Types: deb-src
URIs: http://archive.ubuntu.com/ubuntu/
Suites: resolute resolute-updates resolute-backports
Components: main restricted universe multiverse

Types: deb-src
URIs: http://security.ubuntu.com/ubuntu/
Suites: resolute-security
Components: main restricted universe multiverse
EOF

sudo apt update

# ------------------------------------------------------
# Diretórios
# ------------------------------------------------------

mkdir -p \
    "$ROOT/kernel" \
    "$ROOT/packages" \
    "$ROOT/build"

# ------------------------------------------------------
# Kernel Ubuntu 26 Resolute
# ------------------------------------------------------

if [ ! -d "$ROOT/kernel/linux-resolute/.git" ]; then

    echo
    echo "=== Linux Kernel Resolute ==="

    git clone --depth 1 \
        https://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/resolute \
        "$ROOT/kernel/linux-resolute"
fi

# ------------------------------------------------------
# Descobrir os pacotes que formam o Ubuntu
# ------------------------------------------------------

echo
echo "=== Descobrindo componentes do Ubuntu 26 ==="

apt-cache depends \
    --recurse \
    --no-suggests \
    --no-conflicts \
    --no-breaks \
    --no-replaces \
    --no-enhances \
    ubuntu-minimal \
    ubuntu-standard \
    ubuntu-desktop-minimal \
    ubuntu-desktop \
    linux-generic \
    linux-meta \
    build-essential \
    2>/dev/null |
sed -nE '
/^[a-zA-Z0-9][a-zA-Z0-9+.-]*(:[a-zA-Z0-9]+)?$/ {
    s/:.*$//
    p
}

/^[[:space:]]*(Pre)?Depends:/ {
    s/^[[:space:]]*(Pre)?Depends:[[:space:]]*//
    s/[<>]//g
    s/:.*$//
    s/[[:space:]].*$//
    p
}

/^[[:space:]]*Recommends:/ {
    s/^[[:space:]]*Recommends:[[:space:]]*//
    s/[<>]//g
    s/:.*$//
    s/[[:space:]].*$//
    p
}
' |
grep -E '^[a-zA-Z0-9][a-zA-Z0-9+.-]*$' |
sort -u > "$ROOT/binary-packages.txt"

echo
echo "Binary packages:"
wc -l "$ROOT/binary-packages.txt"

# ------------------------------------------------------
# Binary -> Source
# ------------------------------------------------------

echo
echo "=== Convertendo para source packages ==="

> "$ROOT/source-packages.txt"

while read -r pkg
do
    src=$(
        apt-cache show "$pkg" 2>/dev/null |
        sed -n 's/^Source: \([^ (]*\).*/\1/p' |
        head -n1
    )

    if [ -z "$src" ]; then
        src="$pkg"
    fi

    if apt-cache showsrc "$src" >/dev/null 2>&1; then
        echo "$src"
    fi

done < "$ROOT/binary-packages.txt" |
sort -u > "$ROOT/source-packages.txt"

echo
echo "Source packages:"
wc -l "$ROOT/source-packages.txt"

# ------------------------------------------------------
# Função para baixar um source
# ------------------------------------------------------

get_source()
{
    SRC="$1"

    DEST="$ROOT/packages/$SRC"
    URL="https://git.launchpad.net/ubuntu/+source/$SRC"

    if [ -d "$DEST/.git" ]; then
        echo "[OK] $SRC"
        return
    fi

    if [ -d "$DEST" ] &&
       find "$DEST" -mindepth 1 -maxdepth 1 | grep -q .
    then
        echo "[OK] $SRC"
        return
    fi

    echo
    echo "======================================================"
    echo " $SRC"
    echo "======================================================"

    BRANCH=""

    for B in \
        ubuntu/resolute \
        ubuntu/resolute-devel \
        resolute
    do

        if git ls-remote \
            --exit-code \
            --heads \
            "$URL" \
            "refs/heads/$B" \
            >/dev/null 2>&1
        then
            BRANCH="$B"
            break
        fi

    done

    # --------------------------------------------------
    # Git Resolute
    # --------------------------------------------------

    if [ -n "$BRANCH" ]; then

        echo "Git branch: $BRANCH"

        if git clone \
            --depth 1 \
            --single-branch \
            --branch "$BRANCH" \
            "$URL" \
            "$DEST"
        then
            return
        fi
    fi

    # --------------------------------------------------
    # Fallback: Ubuntu source package
    # --------------------------------------------------

    echo "Usando apt-get source..."

    mkdir -p "$DEST"

    (
        cd "$DEST" || exit
        apt-get source "$SRC"
    )
}

# ------------------------------------------------------
# Baixar os sources descobertos
# ------------------------------------------------------

TOTAL=$(wc -l < "$ROOT/source-packages.txt")
COUNT=0

while read -r SRC
do
    COUNT=$((COUNT + 1))

    echo
    echo "[$COUNT/$TOTAL] $SRC"

    get_source "$SRC"

done < "$ROOT/source-packages.txt"

# ------------------------------------------------------
# Componentes importantes adicionais
# ------------------------------------------------------

EXTRAS=(
    base-files
    glibc
    systemd
    dbus
    bash
    dash
    coreutils
    util-linux
    procps
    findutils
    grep
    sed
    gawk
    tar
    gzip
    xz-utils
    file

    apt
    dpkg
    snapd

    linux-firmware
    kmod
    pciutils
    usbutils
    dmidecode

    grub2
    initramfs-tools
    plymouth
    efibootmgr

    e2fsprogs
    dosfstools
    btrfs-progs
    xfsprogs
    lvm2
    mdadm
    cryptsetup
    parted

    network-manager
    iproute2
    iputils
    nftables
    ufw
    openssh
    curl
    wget
    bind9
    iw

    sudo
    pam
    openssl
    ca-certificates
    apparmor
    shadow

    mesa
    libdrm
    wayland
    wayland-protocols
    xorg
    xorg-server
    libinput

    pipewire
    wireplumber
    alsa-lib
    alsa-utils
    pulseaudio
    bluez

    glib2.0
    gtk+3.0
    gtk4
    cairo
    pango1.0
    gdk-pixbuf
    dconf

    gnome-shell
    mutter
    gdm3
    gnome-session
    ubuntu-session
    nautilus
    gnome-control-center
    gvfs
    udisks2
    upower
    accountsservice
    policykit-1
    xdg-desktop-portal
    xdg-desktop-portal-gnome

    fontconfig
    freetype
    console-setup
    tzdata

    gcc-defaults
    binutils
    make-dfsg
    cmake
    pkgconf
    autoconf
    automake-1.17
    libtool
    debhelper

    ubuntu-meta
    casper
    germinate
    debian-cd
)

echo
echo "======================================================"
echo " Complementando Source Tree"
echo "======================================================"

for SRC in "${EXTRAS[@]}"
do

    if apt-cache showsrc "$SRC" >/dev/null 2>&1; then
        get_source "$SRC"
    else
        echo "[SKIP] $SRC não encontrado no Resolute"
    fi

done

# ------------------------------------------------------
# Build / Release
# ------------------------------------------------------

clone_build()
{
    NAME="$1"
    URL="$2"

    DEST="$ROOT/build/$NAME"

    if [ ! -d "$DEST/.git" ]; then

        echo
        echo "=== BUILD: $NAME ==="

        git clone --depth 1 \
            "$URL" \
            "$DEST" || true
    fi
}

clone_build \
    livecd-rootfs \
    https://git.launchpad.net/livecd-rootfs

clone_build \
    ubuntu-cdimage \
    https://git.launchpad.net/ubuntu-cdimage

clone_build \
    snapd \
    https://github.com/canonical/snapd.git

clone_build \
    subiquity \
    https://github.com/canonical/subiquity.git

clone_build \
    curtin \
    https://github.com/canonical/curtin.git

clone_build \
    ubuntu-desktop-provision \
    https://github.com/canonical/ubuntu-desktop-provision.git

# ------------------------------------------------------
# Resultado
# ------------------------------------------------------

echo
echo
echo "======================================================"
echo " Ubuntu 26.04 Resolute Source Tree concluído"
echo "======================================================"

echo
echo "Diretório:"
echo
echo "$ROOT"

echo
echo "Binary packages:"
wc -l "$ROOT/binary-packages.txt"

echo
echo "Source packages:"
wc -l "$ROOT/source-packages.txt"

echo
echo "Git repositories:"
find "$ROOT" -type d -name .git | wc -l

echo
echo "Tamanho total:"
du -sh "$ROOT"

echo
echo "======================================================"
echo " PRONTO"
echo "======================================================"
