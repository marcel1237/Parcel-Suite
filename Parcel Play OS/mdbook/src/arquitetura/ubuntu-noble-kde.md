# Ubuntu Noble + KDE Full

## Composição

A composição escolhida usa Ubuntu Noble como userspace e inclui:

- `kde-full`;
- Plasma X11 e Plasma Wayland;
- KWin X11 e KWin Wayland;
- SDDM;
- Mesa e Vulkan;
- NetworkManager;
- PipeWire e WirePlumber;
- `live-boot`, SquashFS e OverlayFS;
- kernel genérico Ubuntu Noble.

## Decisão de arquitetura

O modelo Live é inspirado no comportamento do KNOPPIX, mas não copia seu
rootfs, `cloop`, AUFS ou scripts privados. A composição usa mecanismos nativos
do kernel e do `live-build`.

## Estado

O build estrutural foi concluído. Boot, sessão gráfica, áudio, rede, Vulkan e
integração do kernel PlayOS ainda são `unknown`.
