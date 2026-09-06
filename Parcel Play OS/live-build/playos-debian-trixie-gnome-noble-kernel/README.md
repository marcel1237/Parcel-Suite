# PlayOS Debian 13 GNOME com kernel Ubuntu Noble

Receita para uma Live amd64 baseada no pipeline Debian Live:

```text
Debian 13 trixie userspace
  + live-boot/live-config + SquashFS/OverlayFS
  + GNOME/GDM3 Debian
  + kernel e módulos Ubuntu Noble locais
  - Calamares/Subiquity/Curtin/Casper
```

O kernel não transforma o userspace em Ubuntu. `/etc/os-release`, libc,
systemd, GNOME, Mesa, PipeWire, rede, firmware, bootloader e aplicações vêm dos
repositórios Debian Trixie. Somente imagem e módulos do kernel são artefatos
Ubuntu Noble locais.

## Relação com a Live XFCE validada

Este perfil deriva de `playos-debian-trixie-xfce-noble-kernel` e altera somente
a camada de desktop:

```text
remove: xfce4, xfce4-goodies, xfce4-terminal, xfce4-power-manager,
        lightdm, lightdm-gtk-greeter, lxpolkit, thunar-volman
adiciona: gnome-core, gdm3, gnome-terminal, gnome-software
```

Base Debian, mecanismo Live, kernel Noble 6.8.0-138, firmware, gráficos,
Vulkan, áudio, rede e política sem instalador são preservados. Dependências
transitivas são recalculadas pelo APT Debian; não há mistura de repositórios.

## Perfil

- `auto/config`: Debian Trixie, amd64, ISO híbrida, GRUB BIOS/UEFI;
- `config/package-lists/playos-gnome.list.chroot`: pacotes diretos;
- `config/packages.chroot/`: imagem, módulos e módulos-extra Noble;
- `config/includes.chroot/etc/gdm3/daemon.conf`: autologin do usuário Live;
- `config/hooks/live/010-playos-gnome.hook.chroot`: ativa GDM3 e rede;
- `config/hooks/live/900-playos-audit.hook.chroot`: bloqueia instaladores e
  kernel Debian e registra os componentes críticos;
- `tools/preflight.sh`: verifica ferramentas, pacotes e checksums;
- `tools/build.sh`: limpa o staging, configura, compila e gera SHA-256.

## Builder

Use Debian 13 Trixie com `live-build` atual. O pacote `live-build 3.0~a57` do
host Ubuntu é rejeitado pelo preflight.

Ferramentas:

```text
live-build debootstrap squashfs-tools xorriso
grub-pc-bin grub-efi-amd64-bin dosfstools mtools
isolinux syslinux-common syslinux-utils rsync
```

## Construção

Dentro de um builder Debian com device nodes reais e caminho sem espaços:

```sh
cd /root/playos-debian-trixie-gnome-noble-kernel
./tools/preflight.sh
./tools/build.sh
```

Não execute simultaneamente com outro `lb build` no mesmo staging. O build
precisa de privilégios dentro da VM, mas não instala kernel ou bootloader no
host.

## Gates

Após a compilação:

```sh
sha256sum -c live-image-amd64.hybrid.iso.sha256
xorriso -indev live-image-amd64.hybrid.iso -report_el_torito plain
```

Na sessão Live, confirmar:

```sh
cat /etc/os-release
uname -r
findmnt -t squashfs,overlay
systemctl is-active gdm3 NetworkManager
gnome-shell --version
dpkg-query -W calamares calamares-settings-debian 2>&1
```

Build bem-sucedido não comprova desktop, áudio, Vulkan ou hardware. Esses
resultados exigem teste de boot e runtime separados.
