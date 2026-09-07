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

O preflight exige 30 GiB livres. A saída padrão é
`live-image-amd64.hybrid.iso`. O build ainda não foi executado.

## Parâmetros Live inspirados no KNOPPIX

O boot normal usa `boot=live components`. Para testes manuais no menu GRUB:

- `toram`: copia o filesystem comprimido para RAM;
- `verify-checksums`: verifica `md5sum.txt` da mídia;
- `persistence`: habilita persistência quando uma mídia compatível for criada.

Persistência e Secure Boot não fazem parte do primeiro build e exigem gates
separados.
