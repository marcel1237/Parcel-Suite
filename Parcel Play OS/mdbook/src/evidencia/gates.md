# Gates de validação

## Build

Confirma código de saída, manifesto, arquivos esperados e checksum.

## Estrutura

Confirma ISO 9660, catálogo El Torito, kernel, initramfs e SquashFS.

## Boot

Confirma que firmware, bootloader, kernel, initramfs, Live root e OverlayFS
chegam ao userspace.

## Runtime gráfico

Confirma SDDM, Plasma, KWin, X11, Wayland, Xwayland, Mesa, Vulkan, input,
áudio, rede, logout e shutdown.

## Hardware

Confirma o comportamento em hardware real ou em uma VM com dispositivos
representativos. A presença de drivers não substitui esse gate.
