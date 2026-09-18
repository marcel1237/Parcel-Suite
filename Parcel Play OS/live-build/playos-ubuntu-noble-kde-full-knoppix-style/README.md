# PlayOS Ubuntu Noble KDE Full — arquitetura inspirada no KNOPPIX

Este perfil produz uma Live ISO amd64 sem instalador. A composição e identidade
são do PlayOS; a primeira geração usa pacotes binários e kernel dos arquivos
Ubuntu Noble como baseline de compatibilidade. O KNOPPIX é uma referência de
comportamento Live, não a fonte do root filesystem.

## Contrato

- PlayOS Userspace 1 com bootstrap binário Ubuntu Noble;
- kernel Ubuntu Noble `generic` resolvido no momento do build;
- `kde-full`, Plasma, SDDM, Wayland e X11 do arquivo Ubuntu Noble;
- SquashFS somente leitura e OverlayFS gravável em RAM;
- ISO híbrida para BIOS e UEFI;
- sem rootfs KNOPPIX/Debian e sem repositórios Debian diretos;
- sem Calamares, Casper, Subiquity ou outro instalador.

O KNOPPIX 9.1 usa Debian Bullseye, `cloop` e AUFS. Esses componentes não são
copiados. SquashFS, OverlayFS, udev/systemd e `live-boot` fornecem equivalentes
nativos suportados pelo kernel Noble.

## Construção

O staging não pode conter espaços no caminho se a versão instalada de
`live-build` apresentar esse problema. Copie este perfil para um caminho curto
fora do projeto e execute como root:

```sh
./tools/preflight.sh
lb config
lb build
```

O preflight exige 30 GiB livres. A execução de referência foi feita em uma VM
Ubuntu Noble isolada porque `lb build` exige root. O artefato produzido está em
`build/playos-ubuntu-noble-kde-full-knoppix-style/`; ele é uma ISO intermediária
de aproximadamente 6,1 GiB, com checksum registrado, mas ainda não passou por
boot/runtime KDE nem foi comprovado como híbrido USB/BIOS.

## Estado dos hooks

`config/hooks/010-playos-live.chroot` configura o target gráfico, SDDM,
NetworkManager e initramfs com OverlayFS/SquashFS. O hook
`config/hooks/900-playos-audit.chroot` verifica identidade Ubuntu Noble,
ausência de mirrors Debian, presença dos pacotes centrais e ausência de
instaladores, GNOME, XFCE e LightDM.

## Evidência do artefato

O kernel empacotado na execução foi `6.8.0-139-generic`. A ISO contém
SquashFS, initramfs, kernel, manifesto de pacotes e entrada El Torito GRUB2.
O checksum do artefato em `build/` é:

```text
03863ec2c98d10cce3d33c3112bcb71f5a1b7fc2410c5170e780e42da50c5075
```

O tamanho superior a 4 GiB exigiu ISO9660 nível 3. A imagem não deve ser
classificada como híbrida USB/BIOS até que uma ferramenta compatível com o
layout GRUB2 valide esse modo e um boot real seja executado.

## Parâmetros Live inspirados no KNOPPIX

O boot normal usa `boot=live components`. Para testes manuais no menu GRUB:

- `toram`: copia o filesystem comprimido para RAM;
- `verify-checksums`: verifica `md5sum.txt` da mídia;
- `persistence`: habilita persistência quando uma mídia compatível for criada.

Persistência e Secure Boot não fazem parte do primeiro build e exigem gates
separados.
