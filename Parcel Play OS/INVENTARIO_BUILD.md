# Inventário da pasta `build/`

- **Tipo:** inventário operacional
- **Estado:** `result` para artefatos encontrados; `unknown` para capacidade de
  runtime não demonstrada apenas pela presença dos arquivos
- **Data do inventário:** 2026-09-18
- **Local:** `build/`
- **Tamanho aproximado observado:** 28 GiB

Este documento registra o conteúdo existente na pasta `build/` no momento do
inventário. A presença de uma ISO, kernel, log ou diretório de staging não
prova, sozinha, boot, funcionamento gráfico, compatibilidade de hardware ou
prontidão para distribuição.

## Regras de leitura

- `result`: artefato ou medição efetivamente encontrado no disco.
- `implementation`: saída de uma implementação ou pipeline do PlayOS.
- `staging`: diretório intermediário, rootfs, cache ou área de trabalho.
- `source-cache`: fonte baixada ou material usado para compilação.
- `log`: registro de execução, validação ou auditoria.
- `unknown`: o inventário não comprova o comportamento em runtime.
- Os tamanhos são os reportados pelo sistema de arquivos e podem incluir
  arquivos temporários, caches e árvores descompactadas.
- `build/work` contém uma árvore rootfs extensa; sua documentação interna e
  arquivos de pacotes não são tratados como documentação autoral do PlayOS.

## Resumo por diretório

| Diretório | Tamanho aproximado | Conteúdo principal | Estado |
|---|---:|---|---|
| `playos-ubuntu-noble-kde-full-knoppix-style/` | 6,1 GiB | ISO Ubuntu Noble + KDE Full e checksum | `result` |
| `work/` | 6,1 GiB | rootfs de trabalho e staging de composição | `staging` |
| `resolute-mvp/` | 6,0 GiB | árvore de trabalho, downloads e ISO Resolute/branding | `staging`/`result` |
| `playos-debian-trixie-kde-full-noble/` | 3,5 GiB | Live Debian Trixie KDE Full com kernel Noble | `result` |
| `playos-debian-trixie-gnome-noble/` | 1,9 GiB | Live Debian Trixie GNOME com kernel Noble | `result` |
| `playos-graphics-core-noble/` | 1,7 GiB | Live Graphics Core Noble/XFCE/Calamares e candidato Gemini | `result`/`staging` |
| `playos-debian-trixie-xfce-noble/` | 1,3 GiB | Live Debian Trixie XFCE com kernel Noble | `result` |
| `playos-noble-generic/` | 309 MiB | kernel Noble Generic, mapa e artefatos associados | `result` |
| `playos-native-stage1-iso/` | 302 MiB | ISO do Native Stage1 | `result` |
| `playos-native-stage0/` | 182 MiB | ISO, rootfs, fontes, initramfs e logs do Stage0 | `result`/`staging` |
| `playos-native-stage1/` | 94 MiB | rootfs tar, Buildroot, downloads e log de build | `result`/`source-cache` |
| `playos-7.1.8/` | 74 MiB | kernel Linux 7.1.8 PlayOS e `System.map` | `result` |
| `playos-noble/` | 67 MiB | kernel Noble lab e `System.map` | `result` |
| `playos-native-stage2-graphics/` | 5,9 MiB | logs e saída do build gráfico Stage2 | `log`/`staging` |
| `manuals/` | 16 KiB | manuais de criação, branding e reconstrução de ISO | `documentation` |
| `resolute-mvp/gnupg/` | incluído em `resolute-mvp` | material de verificação de assinaturas | `staging` |
| `iso-anaconda-xfce/` | 8 KiB | diretório de saída sem ISO final identificada | `staging` |

O tamanho total de `build/` inclui a soma das árvores acima, inclusive
arquivos descompactados e caches que não são distribuídos.

## ISOs encontradas

| Caminho | Tamanho | SHA-256 registrado | Observação |
|---|---:|---|---|
| `playos-ubuntu-noble-kde-full-knoppix-style/playos-ubuntu-noble-kde-full-live.iso` | 6.458.335.232 bytes | `03863ec2c98d10cce3d33c3112bcb71f5a1b7fc2410c5170e780e42da50c5075` | Ubuntu Noble + `kde-full`; El Torito GRUB2 confirmado; híbrido USB/BIOS pendente |
| `playos-debian-trixie-kde-full-noble/output/live-image-amd64.hybrid.iso` | 3.755.513.856 bytes | `03e2482e91fdd98a3c4ada568f505ef050766c25fab023693385244057983635` | Debian Trixie KDE Full com kernel Noble |
| `playos-debian-trixie-gnome-noble/output/live-image-amd64.hybrid.iso` | 2.007.859.200 bytes | `3d37930ce1db4853a4eda72152b8f5e13f99a942e9e6840ace2a84a3214743eb` | Debian Trixie GNOME com kernel Noble |
| `playos-debian-trixie-xfce-noble/output/live-image-amd64.hybrid.iso` | 1.388.435.456 bytes | `ed798d40e58da7bc5a0da531a6947da6263766e1fc86ea6e179492475df1c50d` | Debian Trixie XFCE com kernel Noble |
| `playos-graphics-core-noble/output/playos-noble-xfce-calamares-amd64.iso` | 1.755.160.576 bytes | `4ce6c108ad9d455e80ad859ae61e9890f9aa8a5f14d7408d7e8bed8bf994c1b2` | Live Noble XFCE/Calamares |
| `playos-graphics-core-noble/candidate-gemini/playos-noble-xfce-calamares-amd64.iso` | não presente no inventário de arquivos | `4c00cfa34ce86a591866b279568558e4093b1e809877b1743cce68164bb81d13` | Existe checksum de candidato; o ISO correspondente não foi localizado |
| `resolute-mvp/output/playos-26.04-wallpaper-2k-amd64.iso` | não presente no inventário de arquivos | `c6bd739db2a2eca9711e57a53fb2ac87afa3b1559bdbefb092e4679ca54c607b` | Existe checksum; o ISO correspondente não foi localizado |
| `playos-native-stage1-iso/output/playos-native-stage1-noble-amd64.iso` | 316.071.936 bytes | `0368dd13c443673f3788d67aa46fff4593cae7bf06ff286a8fa198c023c65a1a` | Native Userspace Stage1 |
| `playos-native-stage0/output/playos-native-stage0-noble-amd64.iso` | 167.217.152 bytes | `c2cfafd4226007f3a5aa91662c9c061da6a73e4222fbc17fde599a3c212844be` | Native Userspace Stage0 |

Os arquivos `.sha256` usam formatos diferentes: alguns referenciam apenas o
nome local da ISO e outros incluem `./`. O hash deve ser verificado a partir do
diretório indicado no próprio arquivo.

## Kernels e artefatos de kernel

### `build/playos-noble-generic/`

Contém o resultado do kernel Noble Generic PlayOS, incluindo:

- `vmlinuz-6.8.4-playos-freebsd-generic`;
- `System.map-6.8.4-playos-freebsd-generic`;
- configuração e artefatos auxiliares do build, quando presentes.

Tamanho aproximado do diretório: 309 MiB.

### `build/playos-noble/`

Contém a variante Noble lab:

- `vmlinuz-6.8.4-playos-freebsd-lab1`;
- `System.map-6.8.4-playos-freebsd-lab1`;
- saídas auxiliares e registros associados.

Tamanho aproximado do diretório: 67 MiB.

### `build/playos-7.1.8/`

Contém o kernel Linux 7.1.8 PlayOS:

- `vmlinuz-7.1.8-playos-freebsd-lab1`;
- `System.map-7.1.8-playos-freebsd-lab1`;
- saídas auxiliares do build.

Tamanho aproximado do diretório: 74 MiB.

A existência desses arquivos demonstra que artefatos foram produzidos, mas não
comprova boot em hardware, regressão completa, compatibilidade universal ou
integração com todas as ISOs presentes.

## Native Userspace

### `playos-native-stage0/`

Diretórios:

- `source/`: material de fonte do estágio;
- `sources/`: fontes e checksums, incluindo BusyBox;
- `rootfs/`: área de rootfs;
- `kernel-root/`: área associada ao kernel;
- `initramfs/`: área de initramfs;
- `iso/`: área de composição ISO;
- `output/`: ISO Stage0 e checksum;
- `bootstrap.log`: log principal;
- `build.pid`: identificador preservado da execução;
- `git-diff-check.log`: saída de `git diff --check`;
- `iso-checksum.log`: validação de checksum;
- `pkgtools-smoke.log`: smoke test de ferramentas de pacotes;
- `query-smoke.log`: smoke test da base de conhecimento;
- `validate-knowledge.log`: execução do validador de conhecimento.

### `playos-native-stage1/`

Contém:

- `output/playos-native-stage1-rootfs.tar`;
- checksum do rootfs;
- `build.log`, com aproximadamente 41 MiB;
- `downloads/`, incluindo o checksum de `buildroot-2026.02.tar.xz`.

### `playos-native-stage1-iso/`

Contém a ISO `playos-native-stage1-noble-amd64.iso`, com aproximadamente
316 MiB, e seu checksum.

### `playos-native-stage2-graphics/`

Contém logs do estágio gráfico:

- `build.first-attempt.log`;
- `build.log`;
- `output/`, sem artefato final de ISO identificado no inventário.

O Stage2 gráfico não deve ser classificado como concluído apenas pela presença
dos logs.

## Live Debian com kernel Noble

Os três diretórios abaixo preservam resultados de composições Live com
userspace Debian Trixie e kernel Ubuntu Noble:

- `playos-debian-trixie-xfce-noble/`;
- `playos-debian-trixie-gnome-noble/`;
- `playos-debian-trixie-kde-full-noble/`.

Cada um possui um subdiretório `output/` com ISO, checksum e outros arquivos
produzidos pelo `live-build`. Os resultados são distintos da composição mais
recente Ubuntu Noble + KDE Full e não devem ser tratados como a mesma baseline.

## Graphics Core Noble

`playos-graphics-core-noble/` contém:

- `output/`: ISO Noble XFCE/Calamares e checksum;
- `candidate-gemini/`: candidato e checksum registrado;
- artefatos auxiliares da composição do Graphics Core.

O diretório registra uma composição Live diferente do perfil Ubuntu Noble KDE
Full. A presença de Calamares também diferencia esse resultado do perfil KDE
Full sem instalador.

## Resolute MVP

`resolute-mvp/` é a maior área de trabalho histórica além da ISO KDE Full. Ela
contém:

- `download/`: downloads;
- `gnupg/`: material de verificação;
- `output/`: saída e checksum de ISO;
- `work/`: árvore de trabalho/rootfs e dados descompactados.

O tamanho aproximado de 6,0 GiB é dominado por `work/`. Esse diretório não é
uma ISO pronta por si só. O checksum presente sem o arquivo ISO correspondente
deve ser tratado como referência histórica ou artefato incompleto até nova
verificação.

## ISO Ubuntu Noble + KDE Full

`playos-ubuntu-noble-kde-full-knoppix-style/` contém atualmente apenas:

- `playos-ubuntu-noble-kde-full-live.iso`;
- `playos-ubuntu-noble-kde-full-live.iso.sha256`.

Esse diretório é a cópia final do artefato produzido na VM isolada de build.
O checksum documentado é:

```text
03863ec2c98d10cce3d33c3112bcb71f5a1b7fc2410c5170e780e42da50c5075
```

O artefato foi identificado como ISO 9660 bootável com catálogo El Torito
GRUB2. `isohybrid` rejeitou a imagem por ausência da assinatura `isolinux.bin`;
portanto, o nome `.iso` é seguro, mas a classificação como híbrida USB/BIOS
continua pendente.

## Manuais e registros auxiliares

### `build/manuals/`

- `ISO_CREATION_GUIDE.md`: guia de criação de ISO;
- `PLAYOS_ISO_MASTER_GUIDE.md`: guia mestre do pipeline de ISO;
- `RECONSTRUCAO_ROOTFS_BRANDING.md`: reconstrução de rootfs e branding.

### Registros LXC

- `lxc-cleanup.txt`;
- `lxc-storage-audit.txt`;
- `lxc-volume-delete.txt`.

Esses arquivos registram limpeza, auditoria de armazenamento e operações sobre
volumes LXC. Não são imagens nem fontes do sistema operacional.

## O que não foi encontrado

Na listagem de artefatos-chave do inventário não foram localizados:

- um ISO correspondente aos checksums do candidato Gemini e do Resolute MVP;
- um artefato final de ISO do `playos-native-stage2-graphics`;
- evidência de boot gráfico executado a partir da ISO Ubuntu Noble KDE Full;
- logs de SDDM, Plasma X11, Plasma Wayland, KWin, Xwayland, Mesa/Vulkan,
  PipeWire e NetworkManager provenientes de uma sessão inicializada dessa ISO.

Essas ausências não provam que os artefatos nunca existiram fora de `build/`;
significam somente que não foram encontrados no inventário atual.

## Política de preservação

- Não apagar `build/` recursivamente para liberar espaço sem inventariar e
  autorizar cada artefato.
- Não tratar `work/`, `rootfs/`, `download/` ou `cache` como resultados
  distribuíveis.
- Verificar checksums antes de copiar ou mover ISOs.
- Manter a ISO Ubuntu Noble KDE Full separada das ISOs Debian Trixie e das
  composições Native Userspace.
- Atualizar este documento quando novos artefatos forem adicionados, removidos
  ou substituídos.

## Próximo gate técnico

O próximo gate do artefato Ubuntu Noble + KDE Full é inicializá-lo em uma VM
com console gráfico e registrar, em relatórios separados:

1. boot BIOS e UEFI;
2. montagem Live, SquashFS e OverlayFS;
3. SDDM;
4. Plasma X11;
5. Plasma Wayland e Xwayland;
6. Mesa/Vulkan;
7. input, áudio e rede;
8. logout e shutdown;
9. comparação com o kernel PlayOS.

