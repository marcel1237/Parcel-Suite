# ISO Ubuntu Noble + KDE Full

## Artefato

```text
build/playos-ubuntu-noble-kde-full-knoppix-style/
```

O arquivo final tem aproximadamente 6,1 GiB e checksum SHA-256 registrado no
diretório do artefato. A imagem contém kernel Ubuntu genérico, não um kernel
PlayOS customizado validado em runtime.

## Evidência

- SquashFS gerado;
- ISO 9660 com Rock Ridge/Joliet;
- catálogo El Torito e entrada GRUB2;
- checksum calculado e conferido;
- build executado em VM isolada.

## Limitações

O `isohybrid` não confirmou uma imagem híbrida GRUB2 com assinatura isolinux.
BIOS, UEFI, SDDM, Plasma X11, Plasma Wayland, Xwayland, Vulkan, input, áudio,
rede e shutdown permanecem gates de runtime.

