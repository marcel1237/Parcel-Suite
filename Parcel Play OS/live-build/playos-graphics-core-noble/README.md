# PlayOS Graphics Core Noble Live ISO

Perfil reproduzível para uma Live ISO Ubuntu Noble amd64 com XFCE 4.18 como
desktop X11, sem GNOME ou KDE Plasma. Consome o Graphics Core neutro e inclui
kernel oficial Noble, X11/XFCE, Wayland/Labwc técnico, Xwayland, Mesa/Vulkan,
input, fontes, rede, discos e PipeWire.

## Build isolado recomendado

```bash
lxc launch ubuntu:24.04 playos-noble-graphics-builder
lxc file push -r live-build/playos-graphics-core-noble \
  playos-noble-graphics-builder/root/
lxc exec playos-noble-graphics-builder -- apt-get update
lxc exec playos-noble-graphics-builder -- \
  apt-get install -y live-build debootstrap squashfs-tools xorriso
lxc exec playos-noble-graphics-builder -- bash -lc \
  'cd /root/playos-graphics-core-noble && lb clean --purge && lb config && lb build'
```

O output canônico é `playos-noble-xfce-calamares-amd64.iso`. Ele deve ser
copiado para `build/playos-graphics-core-noble/output/` junto do manifesto e
do checksum SHA-256.

## Estado verificado em 2026-08-28

- `implementation`: perfil, sistema raiz e finalizador GRUB2 reproduzível;
- `result`: ISO de 1.755.160.576 bytes e SHA-256 verificado;
- `result`: manifesto, SquashFS e estruturas estáticas BIOS/UEFI auditados;
- `result`: XFCE, Calamares e pilha gráfica presentes; GNOME, KDE e Openbox
  ausentes do manifesto;
- `unknown`: boot BIOS/UEFI, sessões X11/Wayland e hardware ainda não foram
  testados.

Este perfil inclui uma integração candidata do Calamares, sem GNOME ou KDE. O
XFCE pertence somente à composição da Live, não ao núcleo gráfico. O instalador
ainda não foi validado em runtime. Persistência, Secure
Boot validado e wallpaper/branding final continuam fora deste build. Ele usa o
kernel oficial Ubuntu Noble; integrar um kernel PlayOS customizado exige um
conjunto coerente de kernel, módulos, initramfs e pacotes.

O histórico, a composição e os gates destrutivos em VM estão em
`../../LIVE_ISO_NOBLE_GRAPHICS_CORE_CALAMARES_2026-08-27.md`.

## Finalização GRUB2 no `live-build` antigo

A versão `3.0~a57` usada na VM chama `grub-mkimage` sem `-p /boot/grub` e
pressupõe que `isohybrid` esteja disponível. Se `lb binary` concluir a árvore
binária e falhar nessa etapa, instale `grub-pc-bin`, `grub-efi-amd64-bin` e
`xorriso` e execute, na raiz do perfil:

```sh
sudo ./tools/finalize-grub-iso.sh
```

O script aceita `binary/` ou `chroot/binary/` e usa
`grub-mkrescue`/xorriso para produzir boot BIOS e UEFI. Isso não comprova boot;
a ISO ainda precisa dos testes em VM descritos na documentação.
