# PlayOS Native Userspace

Fonte canônica: [`../../PLAYOS_USERSPACE_SLACKLIKE_KNOPPIX_LIVE_KDE_FULL.md`](../../PLAYOS_USERSPACE_SLACKLIKE_KNOPPIX_LIVE_KDE_FULL.md).

Esta árvore contém somente especificações e manifestos iniciais. Ainda não há
rootfs nativo compilado.

## Layout

```text
collections/   conjuntos de pacotes do produto
packages/      receitas de build por componente
pkgtools/      gerenciador de pacotes PlayOS
rootfs/        overlays próprios e scripts de init
live/          initramfs e composição da mídia
locks/         versões e checksums aprovados
```

Não adicionar pacotes `.deb`, `.txz` Slackware ou binários sem proveniência.

## Estado executável

`pkgtools/` já implementa build, instalação e remoção do formato `.pxz` v1. O
smoke test cria um pacote, instala em uma raiz temporária, executa seu payload e
remove o pacote. `packages/playos-base-files/` gera o primeiro pacote real com
identidade, `inittab` e scripts `rc.d` do PlayOS.

Isso ainda não é um rootfs inicializável: shell, libc, coreutils, util-linux,
sysvinit, eudev e suas dependências precisam ser compilados e empacotados.
