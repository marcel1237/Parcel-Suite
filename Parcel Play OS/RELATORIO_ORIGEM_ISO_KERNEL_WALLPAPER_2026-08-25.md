# PlayOS — origem da ISO, compilação do kernel e auditoria do wallpaper

- data: 2026-08-25
- estado: auditoria estática concluída; rebuild limpo e teste de boot pendentes

## Resumo executivo

A ISO atual não foi compilada do código-fonte do Ubuntu ou do Linux. Ela foi
recomposta com `xorriso` a partir de uma árvore da mídia Ubuntu Resolute
previamente extraída e posteriormente modificada.

Os kernels PlayOS compilados foram usados para validar patches e configurações,
mas não foram integrados à ISO. A sessão Live continua usando o kernel Ubuntu
`7.0.0-29-generic`.

O wallpaper 2K está dentro de `minimal.squashfs`, mas não aparece porque o Live
usa camadas superiores com outro banco GSettings. Também permanece uma
configuração antiga apontando para uma imagem vazia.

## 1. Origem da `iso-tree`

`build/resolute-mvp/work/iso-tree/` foi originalmente extraída de:

```text
build/resolute-mvp/download/resolute-desktop-amd64.iso
```

Os metadados indicam Ubuntu Resolute Desktop amd64, compilação `20260811`. O
checksum registrado em `build/resolute-mvp/download/SHA256SUMS` é:

```text
15968c058698aee7bda65abf7ce77fec966c2d8477bf7490587981aa287dd450
```

A árvore nasceu em 2026-08-13 e recebeu branding, metadados PlayOS e um
SquashFS recompilado. Ela não é mais uma cópia limpa da mídia Ubuntu. A ISO
oficial foi removida; somente seu checksum permanece.

## 2. Origem da ISO atual

```text
resolute-desktop-amd64.iso
          ↓ extração original
build/resolute-mvp/work/iso-tree/
          ↓ alterações PlayOS e xorriso
build/resolute-mvp/output/playos-26.04-wallpaper-2k-amd64.iso
```

A saída foi gerada usando a `iso-tree` já modificada, não uma extração nova.
Partes do boot também dependiam de intervalos da ISO original. Sem essa entrada,
o builder monolítico não consegue repetir uma construção integral do zero.

## 3. Finalidade da compilação do código-fonte

As compilações de kernel são uma linha separada da construção da mídia. Foram
confirmados, entre outros:

```text
build/playos-7.1.8/output/vmlinuz-7.1.8-playos-freebsd-lab1
build/playos-noble/output/vmlinuz-6.8.4-playos-freebsd-lab1
build/playos-noble-generic/output/vmlinuz-6.8.4-playos-freebsd-generic
```

Esses builds serviram para:

1. verificar patches e identidade PlayOS;
2. validar configurações Linux 7.1.8 e Ubuntu Noble;
3. compilar módulos e estudos como NTSYNC e `mseal`;
4. testar propostas inspiradas no FreeBSD em staging isolado;
5. produzir kernel, configuração, `System.map`, módulos e initramfs;
6. evitar qualquer instalação no kernel do computador hospedeiro.

Eles não foram usados como fonte da ISO nem inseridos no Live CD.

## 4. Kernel efetivamente presente na mídia

A árvore contém `casper/vmlinuz` e o rootfs registra
`boot/vmlinuz-7.0.0-29-generic`. Os manifestos confirmam:

```text
linux-image-7.0.0-29-generic 7.0.0-29.29
linux-modules-7.0.0-29-generic 7.0.0-29.29
```

Logo, a ISO atual inicializa o kernel oficial Ubuntu Resolute
`7.0.0-29-generic`. Os builds PlayOS 6.8.4 e 7.1.8 permanecem fora da mídia.

## 5. Wallpaper e causa da falha

O ativo `assets/playos-wallpaper.png` é um PNG RGB 2560×1440, com 2.978.123
bytes e SHA-256:

```text
d678f3f1c5cef41d09189b1fcb897aeaed3d381c1aeb06947b70efd5c8194ef8
```

O `minimal.squashfs` incluído na ISO contém
`/usr/share/backgrounds/playos/default.png`, um override e um
`gschemas.compiled` mencionando o PlayOS. Isso comprova a presença do arquivo,
mas não o valor efetivo usado pelo desktop.

O rootfs do Resolute é composto por:

1. `minimal.squashfs`;
2. `minimal.standard.squashfs`;
3. `minimal.standard.live.squashfs`.

As camadas `standard` e `standard.live` possuem seus próprios
`gschemas.compiled`. A camada Live ainda referencia
`warty-final-ubuntu.png` e `ubuntu-wallpaper-d.png`. Ao prevalecer sobre a
camada mínima, ela oculta a configuração PlayOS.

Existe ainda `99_playos-settings.gschema.override`, apontando para
`/usr/share/backgrounds/playos/default-dark.jpg`; esse arquivo tem zero bytes.
Assim, há dois defeitos: o override foi compilado na camada errada e uma
configuração antiga aponta para uma imagem vazia.

## 6. Limitações dos builders atuais

`scripts/rebuild-live-rootfs.sh` e `scripts/ultimate-playos-builder.sh`:

- recompõem somente `minimal.squashfs`;
- não corrigem as camadas `standard` e `standard.live`;
- reutilizam uma árvore mutável;
- compilam schemas numa camada que não prevalece no Live;
- o rebuild simplificado chama `apply-distro-def.sh` três vezes;
- a limpeza de `rootfs/*` não remove entradas ocultas;
- aceitam `assets/logo.png`, embora ele esteja vazio;
- dependem da ISO oficial atualmente ausente.

QEMU também não está instalado. Portanto, não houve validação gráfica
automatizada, embora as ferramentas de SquashFS, GSettings e ISO estejam
disponíveis.

## 7. Procedimento correto para reconstruir do zero

1. Recuperar a ISO exata do checksum ou registrar formalmente uma nova base.
2. Validar checksum e, se disponível, assinatura.
3. extrair uma `iso-tree` nova em staging limpo;
4. não usar a ISO PlayOS atual como fonte da próxima geração;
5. aplicar o wallpaper nas camadas mínima, standard e Live;
6. remover overrides antigos e o `default-dark.jpg` vazio;
7. configurar modo claro, escuro e tela de bloqueio;
8. criar configuração de sistema dconf e executar `dconf update`;
9. recompilar schemas na camada que prevalece no Live;
10. atualizar manifestos, `.size` e checksums internos;
11. preservar e validar BIOS, UEFI, MBR e GPT;
12. iniciar a sessão Live e consultar:

```bash
gsettings get org.gnome.desktop.background picture-uri
gsettings get org.gnome.desktop.background picture-uri-dark
gsettings get org.gnome.desktop.screensaver picture-uri
```

## 8. Integração futura do PlayOS Kernel

Integrar o 7.1.8 exige kernel, módulos correspondentes, firmware aplicável,
initramfs compatível, manifestos, bootloader e rollback. O kernel Ubuntu 7.0
deve permanecer inicialmente como fallback. Kernel e wallpaper precisam ser
validados separadamente para distinguir falhas de boot e de desktop.

## 9. Conclusão

