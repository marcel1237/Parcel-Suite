# Estado atual do projeto

## Baselines

- FreeBSD: 15.1-RELEASE-p2, em fonte externa somente leitura.
- Ubuntu local historicamente chamado Resolute: identidade técnica Noble Linux
  6.8.4, não a fonte oficial Ubuntu Resolute 7.0.
- Linux vanilla: 7.1.8.
- Userspace escolhido para a composição KDE Full mais recente: Ubuntu Noble.

## Resultado mais recente

Uma ISO Ubuntu Noble + KDE Full foi construída em VM isolada e copiada para:

```text
build/playos-ubuntu-noble-kde-full-knoppix-style/
```

SHA-256:

```text
03863ec2c98d10cce3d33c3112bcb71f5a1b7fc2410c5170e780e42da50c5075
```

O artefato possui estrutura ISO 9660 e catálogo El Torito GRUB2 confirmados.
O modo híbrido USB/BIOS ainda não foi comprovado, e os gates de runtime KDE
continuam pendentes.

## Pendências principais

- boot BIOS e UEFI;
- montagem Live e OverlayFS;
- SDDM;
- Plasma X11;
- Plasma Wayland e Xwayland;
- Mesa/Vulkan;
- áudio, input e rede;
- logout e shutdown;
- integração do kernel PlayOS.
