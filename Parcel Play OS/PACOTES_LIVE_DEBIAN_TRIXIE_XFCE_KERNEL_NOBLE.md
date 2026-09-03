# Pacotes da Live PlayOS Debian Trixie + XFCE + kernel Noble

- ID: `PLAYOS-LIVE-DEBIAN-XFCE-NOBLE-PACKAGES`
- Tipo: `implementation`
- Estado: perfil de build configurado; ISO final ainda não validada
- Confiança: alta para pacotes diretos; dependências transitivas ainda não determinadas
- Data: 2026-09-03
- Fonte canônica: `live-build/playos-debian-trixie-xfce-noble-kernel/config/package-lists/playos-xfce.list.chroot`

Este arquivo registra os **67 pacotes solicitados diretamente** pelo perfil
atual da Live. Ele não é ainda o manifesto de todos os pacotes instalados: o
`live-build` resolve muitas dependências adicionais. A lista completa e
versionada do sistema final somente poderá ser registrada após uma compilação
bem-sucedida da ISO.

## Infraestrutura Debian Live

```text
live-boot
live-config
live-config-systemd
live-tools
systemd-sysv
sudo
locales
keyboard-configuration
console-setup
```

## Kernel Ubuntu Noble local

Estes três pacotes não vêm dos repositórios Debian. Os arquivos `.deb` locais,
do mesmo ABI, são importados em `config/packages.chroot/`.

```text
linux-image-6.8.0-138-generic
linux-modules-6.8.0-138-generic
linux-modules-extra-6.8.0-138-generic
```

## XFCE, X11 e gerenciador de sessão

```text
xorg
xfce4
xfce4-goodies
xfce4-terminal
xfce4-power-manager
lightdm
lightdm-gtk-greeter
```

## Serviços e integração do desktop

```text
dbus-user-session
polkitd
pkexec
lxpolkit
network-manager
network-manager-gnome
upower
udisks2
gvfs
gvfs-backends
thunar-volman
xdg-utils
xdg-user-dirs
desktop-file-utils
shared-mime-info
```

## Gráficos, Vulkan, entrada, fontes e áudio

```text
libgl1-mesa-dri
mesa-vulkan-drivers
mesa-utils
vulkan-tools
xserver-xorg-input-libinput
fonts-dejavu-core
fonts-noto-core
alsa-utils
pipewire
pipewire-audio
pipewire-pulse
wireplumber
pavucontrol
```

## Firmware e microcode Debian

```text
firmware-linux-free
firmware-misc-nonfree
firmware-amd-graphics
intel-microcode
amd64-microcode
```

## Armazenamento, diagnóstico e utilitários

```text
parted
btrfs-progs
dosfstools
e2fsprogs
rsync
squashfs-tools
pciutils
usbutils
procps
kmod
curl
ca-certificates
less
nano
file
```

## Ferramentas do ambiente de construção

Estes pacotes preparam o ambiente que executa o `live-build`; eles não são,
por isso só, conteúdo garantido da Live:

```text
live-build
debootstrap
squashfs-tools
xorriso
grub-pc-bin
grub-efi-amd64-bin
dosfstools
mtools
isolinux
syslinux-common
syslinux-utils
rsync
```

## Pacotes deliberadamente ausentes

O perfil atual não solicita Calamares, Anaconda, Subiquity, Curtin, Casper nem
metapacotes de kernel Debian. A ausência definitiva deverá ser confirmada no
manifesto da ISO concluída.

## Como conferir a lista ativa

```sh
awk 'NF && $1 !~ /^#/' \
  live-build/playos-debian-trixie-xfce-noble-kernel/config/package-lists/playos-xfce.list.chroot
```

## Próximo gate

Concluir a ISO e arquivar o manifesto produzido pelo `live-build`, contendo
todos os pacotes instalados e suas versões. Esse resultado substituirá a parte
atualmente classificada como `unknown` sobre dependências transitivas.
