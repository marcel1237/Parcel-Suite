# Live ISO PlayOS — wallpaper 2K e política de saída única

- ID: `PLAYOS-LIVE-ISO-OUTPUT-001`
- tipo: relatório de implementação e operação
- data: 2026-08-25
- estado: ISO gerada; validação estática parcial; falha de wallpaper confirmada

> **Retificação de 2026-08-25:** a validação original examinou somente
> `minimal.squashfs`. A sessão Live usa camadas superiores com outro banco
> GSettings, que prevalece sobre o banco alterado. Consulte
> `RELATORIO_ORIGEM_ISO_KERNEL_WALLPAPER_2026-08-25.md` para a auditoria
> consolidada e o procedimento correto de reconstrução.

## Artefato canônico

O único ISO de saída mantido em `build/` é:

```text
build/resolute-mvp/output/playos-26.04-wallpaper-2k-amd64.iso
```

- tamanho: `6.365.249.536` bytes;
- SHA-256: `c6bd739db2a2eca9711e57a53fb2ac87afa3b1559bdbefb092e4679ca54c607b`;
- Volume ID: `PLAYOS_2604`;
- checksum relativo: `playos-26.04-wallpaper-2k-amd64.iso.sha256`.

## Wallpaper criado

O wallpaper original está em:

```text
assets/playos-wallpaper.png
```

- formato: PNG RGB;
- resolução: `2560 × 1440` (QHD/2K, 16:9);
- tamanho: `2.978.123` bytes;
- SHA-256: `d678f3f1c5cef41d09189b1fcb897aeaed3d381c1aeb06947b70efd5c8194ef8`.

A arte foi gerada para o PlayOS com fundo preto/grafite, iluminação verde e
ciano, símbolo orbital original deslocado para a direita e espaço negativo
para ícones. Não contém texto, watermark ou marcas de terceiros.

## Integração no sistema Live

O arquivo foi instalado dentro do SquashFS em:

```text
/usr/share/backgrounds/playos/default.png
```

Foi criado e compilado um override GSettings para:

- `org.gnome.desktop.background picture-uri`;
- `org.gnome.desktop.background picture-uri-dark`;
- `org.gnome.desktop.screensaver picture-uri`.

Todos apontam para `file:///usr/share/backgrounds/playos/default.png`.
Os scripts de branding e rebuild foram alinhados para usar somente
`assets/playos-wallpaper.png`; referências antigas a `wallpaper.jpg`,
`default.jpg` e `default-dark.jpg` foram removidas.

## Procedimento usado

1. O SquashFS PlayOS anterior foi extraído em staging com `fakeroot` e
   `unsquashfs`, preservando IDs Unix simulados sem instalar nada no host.
2. O wallpaper 2K foi instalado com modo `0644`.
3. O override GNOME foi criado e `glib-compile-schemas` foi executado.
4. O rootfs foi recomposto com `mksquashfs`, Zstandard e bloco de 1 MiB.
5. Uma nova ISO foi criada com `xorriso`, substituindo somente
   `/casper/minimal.squashfs`.
6. `-boot_image any replay` preservou os metadados de boot da ISO anterior.
7. O staging temporário foi removido depois da validação, recuperando cerca
   de 9 GB.

## Validações realizadas

- checksum da ISO: aprovado;
- hash do wallpaper extraído do SquashFS: idêntico ao ativo fonte;
- wallpaper interno: `2.978.123` bytes, proprietário `root:root`, modo `0644`;
- GSettings compilado contém o caminho PlayOS;
- SquashFS: válido, Zstandard, bloco de 1 MiB;
- boot El Torito BIOS: presente;
- boot El Torito UEFI: presente;
- MBR protetivo e GPT: presentes;
- Volume ID PlayOS: presente.

QEMU não está instalado; portanto boot visual, sessão Live e instalação
continuam pendentes.

## Arquivos ISO removidos

Para evitar múltiplos outputs, foram excluídos:

```text
build/resolute-mvp/output/parcel-play-11-menu-prototype-amd64.iso
build/resolute-mvp/output/playos-26.04-amd64.iso
build/resolute-mvp/output/playos-26.04-amd64.iso.sha256
build/resolute-mvp/download/resolute-desktop-amd64.iso
```

O protótipo e a ISO PlayOS anterior podem ser recriados. A ISO oficial de
entrada precisará ser baixada e validada novamente se uma reconstrução
integral for solicitada.

Dois pequenos ISOs do Memtest86 dentro do rootfs extraído foram preservados:
eles são componentes internos do sistema Live, não outputs do projeto.

## Política de saída única
