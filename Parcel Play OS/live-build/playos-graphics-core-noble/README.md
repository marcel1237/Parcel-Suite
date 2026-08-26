# PlayOS Graphics Core Noble Live ISO

Perfil reproduzível para uma Live ISO Ubuntu Noble amd64 sem GNOME, KDE ou
XFCE. Inclui kernel oficial Noble, X11/Openbox técnico, Wayland/Labwc,
Xwayland, Mesa/Vulkan, input, fontes, rede, discos e PipeWire.

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

O output esperado no container é `live-image-amd64.hybrid.iso`. Ele deve ser
copiado para `build/playos-graphics-core-noble/output/` com nome canônico e
checksum SHA-256.

Estado atual: perfil preparado; resultados de build e boot são registrados
separadamente.
