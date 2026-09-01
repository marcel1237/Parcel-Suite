# PlayOS Noble Graphics Core sem desktops

Perfil `live-build` amd64 que implementa a composição descrita em
`../../PLAYOS_GRAPHICS_CORE_COMPLETO_SEM_DESKTOPS.md`.

Inclui Ubuntu Noble, kernel genérico Ubuntu, `live-boot`, DRM/Mesa/Vulkan,
Xorg, Wayland/Xwayland/Labwc, LightDM, PipeWire/WirePlumber, rede, energia,
armazenamento, input, fontes e padrões XDG. Não inclui GNOME, KDE Plasma,
XFCE nem instalador.

As interfaces disponíveis são deliberadamente mínimas:

- `PlayOS Core Wayland (Labwc)`: Labwc, `foot`, `wofi` e notificações `mako`;
- `PlayOS Core X11 (Technical)`: Xorg e um único `xterm`, sem window manager.

Isso é uma distribuição Live com componentes kernel e userspace separados;
X11 e Wayland não são incorporados ao binário do kernel.

## Pré-requisitos no host

```sh
sudo apt update
sudo apt install live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin syslinux-utils
```

`syslinux-utils` fornece `isohybrid`. A ausência dele faz o `lb build` terminar
com código 127 depois de montar o conteúdo ISO. A versão antiga do `live-build`
também pode gerar um `binary.sh` incompatível com o GRUB atual; nesse caso,
use o finalizador `tools/finalize-grub-iso.sh`, que chama `grub-mkrescue`.

## Staging sem espaços

Confirme que não há build ou mount ativo antes de substituir o staging:

```sh
cp -a \
  "/home/marcel/Parcel-Suite/Parcel Suite/Parcel Play OS/live-build/playos-graphics-core-noble-no-desktop" \
  /home/marcel/playos-graphics-core-noble-no-desktop
cd /home/marcel/playos-graphics-core-noble-no-desktop
sudo lb clean --purge
sudo lb config
```

## Build

```sh
sudo systemd-run \
  --unit=playos-graphics-core-build \
  --working-directory=/home/marcel/playos-graphics-core-noble-no-desktop \
  --property=StandardOutput=append:/home/marcel/Documentos/log-build-iso-graphics-core.txt \
  --property=StandardError=append:/home/marcel/Documentos/log-build-iso-graphics-core.txt \
  /usr/bin/lb build
```

Não inicie um segundo build enquanto o serviço estiver ativo. Consulte:

```sh
sudo systemctl status playos-graphics-core-build --no-pager
tail -f /home/marcel/Documentos/log-build-iso-graphics-core.txt
```

Output pretendido: `playos-noble-graphics-core-amd64.iso`.

## Gates

1. build com código zero e manifesto auditado;
2. ausência comprovada de GNOME, KDE, XFCE e instaladores;
3. estrutura de boot BIOS e UEFI;
4. boot em VM até LightDM;
5. autologin Labwc, terminal `foot`, menu `wofi` e Xwayland;
6. sessão X11 técnica com `xterm`;
7. DRM/Mesa/Vulkan, input, fontes, rede, áudio e discos;
8. teste em hardware representativo.

Build bem-sucedido não comprova boot nem funcionamento em hardware.
