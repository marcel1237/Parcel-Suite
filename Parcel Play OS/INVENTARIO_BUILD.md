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

## O que é a pasta `build/`

`build/` é o espaço de trabalho de compilação, empacotamento e preservação de
resultados do PlayOS. Ela não é uma árvore-fonte única e não representa uma
única distribuição. Existem várias linhas de trabalho simultâneas:

1. kernels Noble e Linux 7.1.8;
2. Live ISOs Debian Trixie com kernel Noble;
3. Graphics Core Noble com XFCE e Calamares;
4. usuários nativos Stage0, Stage1 e Stage2;
5. Ubuntu Noble + KDE Full;
6. protótipos históricos Resolute e branding;
7. logs, manuais, caches, rootfs e auditorias de armazenamento.

Por isso, dois diretórios com nomes parecidos podem usar userspaces, kernels,
instaladores e níveis de validação diferentes. Uma ISO Debian Trixie KDE não é
a mesma baseline que a ISO Ubuntu Noble KDE Full, e um kernel em `output/` não
é automaticamente o kernel usado por todas as ISOs.

## Como interpretar os tipos de conteúdo

Uma pasta de build normalmente passa por estas etapas:

```text
fonte/download
    -> staging/rootfs
    -> kernel ou filesystem comprimido
    -> ISO/tarball
    -> checksum e manifesto
    -> boot/runtime
```

Os arquivos de `build/` podem registrar qualquer uma dessas etapas. Um
`*.packages` é um manifesto, não uma prova de que todos os pacotes funcionam.
Um `*.contents` descreve o conteúdo da mídia, não comprova boot. Um checksum
confirma integridade da cópia, não funcionalidade. Um `build.log` confirma o
que o processo reportou, mas não substitui um teste de execução.

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

## Mapa de decisão: qual diretório consultar

| Pergunta | Diretório principal |
|---|---|
| Onde está a ISO Ubuntu Noble + KDE Full? | `playos-ubuntu-noble-kde-full-knoppix-style/` |
| Onde estão as ISOs Debian com kernel Noble? | `playos-debian-trixie-*` |
| Onde está a Live XFCE com Calamares? | `playos-graphics-core-noble/` |
| Onde estão os kernels compilados? | `playos-noble/`, `playos-noble-generic/`, `playos-7.1.8/` |
| Onde está o Native Userspace inicial? | `playos-native-stage0/`, `playos-native-stage1/` |
| Onde estão os logs do Graphics Stage2? | `playos-native-stage2-graphics/` |
| Onde estão rootfs e caches históricos? | `work/` e `resolute-mvp/work/` |
| Onde estão os manuais de ISO? | `manuals/` |

## Explicação dos arquivos comuns

### ISOs

Arquivos `*.iso` são imagens de mídia. O nome pode conter `hybrid` por
convenção do pipeline, mas a propriedade híbrida precisa ser confirmada por
ferramentas de imagem e por boot BIOS/UEFI real.

### Checksums

Arquivos `*.sha256` e `SHA256SUMS` registram hashes. Eles são usados para:

- detectar cópia incompleta;
- comparar o artefato da VM com a cópia no host;
- preservar uma identidade do arquivo;
- impedir que uma ISO seja substituída silenciosamente.

O checksum não informa se a ISO inicializa ou se o desktop funciona.

### Manifestos

- `*.packages`: pacotes instalados ou selecionados;
- `*.contents`: arquivos e caminhos presentes na mídia;
- `minimal.standard.live.manifest`: seleção de pacotes de uma composição Live;
- `filesystem.packages`: manifesto do filesystem Live.

Manifestos são evidência de composição estática. Não são evidência de
compatibilidade universal.

### Kernels

- `vmlinuz-*`: imagem comprimida do kernel;
- `initramfs-*`: initramfs associado a uma versão;
- `System.map-*`: mapa de símbolos;
- `config-*`: configuração usada para compilar;
- `SHA256SUMS`: hashes dos artefatos do kernel.

Kernel, initramfs e módulos precisam ser da mesma ABI para uma integração
coerente. A simples presença de um `vmlinuz` em `build/` não demonstra que uma
ISO específica o utiliza.

### Rootfs, tarballs e staging

- `rootfs/`: raiz de filesystem em construção;
- `work/`: árvore de trabalho descompactada;
- `source/` e `sources/`: fontes e arquivos auxiliares;
- `download/` e `downloads/`: arquivos baixados;
- `output/`: resultados promovidos pelo pipeline;
- `cache/`: conteúdo reutilizável, quando presente.

Esses diretórios podem conter arquivos temporários, permissões de root,
links simbólicos e dados que não devem ser copiados diretamente para uma
distribuição.

### Logs

Logs preservam a sequência operacional. Os mais importantes são:

- `build.log`: execução principal de compilação;
- `bootstrap.log`: criação inicial de um userspace;
- `*.first-attempt.log`: tentativa anterior, normalmente útil para diagnóstico;
- `*-build.log`: execução de uma ISO específica;
- `*-checksum.log`: conferência de integridade;
- `query-smoke.log`: teste da base de conhecimento;
- `validate-knowledge.log`: validação de catálogos e documentos;
- `git-diff-check.log`: verificação de whitespace no Git.

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

## Relação entre kernels e ISOs

Há três relações diferentes no conteúdo atual:

1. **Kernel produzido separadamente:** os diretórios
   `playos-noble*` e `playos-7.1.8` guardam imagens de kernel que podem ser
   usadas por outros pipelines, mas não são automaticamente incorporadas às
   ISOs.
2. **Kernel selecionado pelo live-build:** as ISOs Debian Trixie foram
   compostas com um kernel Noble conforme seus próprios perfis e manifestos.
3. **Kernel empacotado durante a composição Ubuntu Noble KDE:** a ISO mais
   recente contém o kernel Ubuntu Noble `6.8.0-139-generic`, registrado no
   manifesto da execução, e não os artefatos `vmlinuz-*` dos diretórios de
   kernel separados.

Essa distinção evita afirmar que a ISO KDE já executa o kernel PlayOS. A
integração do kernel PlayOS é um gate posterior.

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

### Fluxo dos estágios nativos

O fluxo Native Userspace é progressivo:

```text
Stage0 -> Stage1 -> Stage1 ISO -> Stage2 Graphics
```

- **Stage0:** base inicial, ferramentas mínimas, BusyBox, rootfs e ISO;
- **Stage1:** userspace mais completo, Buildroot e rootfs tar;
- **Stage1 ISO:** empacotamento do tar/rootfs em mídia inicializável;
- **Stage2 Graphics:** tentativa de adicionar a pilha gráfica e Qt.

Um estágio posterior não invalida os artefatos anteriores. Ao mesmo tempo, um
log de Stage2 não transforma Stage1 em desktop gráfico funcional.

## Live Debian com kernel Noble

Os três diretórios abaixo preservam resultados de composições Live com
userspace Debian Trixie e kernel Ubuntu Noble:

- `playos-debian-trixie-xfce-noble/`;
- `playos-debian-trixie-gnome-noble/`;
- `playos-debian-trixie-kde-full-noble/`.

Cada um possui um subdiretório `output/` com ISO, checksum e outros arquivos
produzidos pelo `live-build`. Os resultados são distintos da composição mais
recente Ubuntu Noble + KDE Full e não devem ser tratados como a mesma baseline.

### Diferenças entre as variantes Debian

- **XFCE:** desktop menor, usado para validar uma Live gráfica de menor custo;
- **GNOME:** desktop GNOME/GDM ou composição equivalente registrada no
  manifesto;
- **KDE Full:** composição KDE mais pesada, com SDDM e pacotes KDE integrados
  ao userspace Debian Trixie.

Todas são experiências separadas da decisão posterior de usar Ubuntu Noble
como userspace do KDE Full. Os nomes `*-noble` nesses diretórios indicam o
kernel Noble ou a composição do projeto; não significam userspace Ubuntu Noble.

## Graphics Core Noble

`playos-graphics-core-noble/` contém:

- `output/`: ISO Noble XFCE/Calamares e checksum;
- `candidate-gemini/`: candidato e checksum registrado;
- artefatos auxiliares da composição do Graphics Core.

O diretório registra uma composição Live diferente do perfil Ubuntu Noble KDE
Full. A presença de Calamares também diferencia esse resultado do perfil KDE
Full sem instalador.

O Graphics Core é uma camada de composição gráfica e não deve ser confundido
com um desktop KDE completo. A variante encontrada combina uma Live Noble com
XFCE e Calamares; o perfil Ubuntu Noble KDE Full deliberadamente não inclui
Calamares, Subiquity ou Casper.

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

Esse diretório é histórico e precisa ser lido com a identidade técnica
registrada no projeto: a pasta local chamada Resolute não deve ser tomada
automaticamente como fonte Ubuntu Resolute oficial. A versão real do kernel,
dos pacotes e da distribuição deve ser confirmada nos manifestos e logs de cada
execução.

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

### O que essa ISO representa

Essa é a composição mais recente do trabalho descrito nesta documentação:

- userspace Ubuntu Noble;
- `kde-full`;
- Plasma X11 e Wayland;
- KWin, SDDM, Mesa/Vulkan, PipeWire e NetworkManager;
- Live baseada em SquashFS e OverlayFS;
- kernel genérico Ubuntu Noble;
- sem instalador.

Ela é uma **ISO intermediária estruturalmente construída**, não uma release
validada. O próximo passo é inicializá-la com uma VM que ofereça console gráfico
e separar os resultados de boot, login, renderização, áudio, rede e shutdown.

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

## O que pode ser removido e o que deve ser preservado

Sem uma decisão explícita, preserve:

- todas as ISOs e seus checksums;
- kernels, initramfs, configurações e `System.map`;
- logs de build e validação;
- manifestos `*.packages` e `*.contents`;
- rootfs e tarballs de estágios Native;
- fontes baixadas que tenham checksum e sejam necessárias à reprodução.

Itens candidatos a limpeza, depois de conferência:

- caches duplicados;
- árvores de trabalho recriáveis;
- logs de tentativas antigas já incorporados em relatório;
- arquivos temporários sem checksum ou sem referência no pipeline.

Não remova por padrão `build/work`, `resolute-mvp/work` ou rootfs de estágios:
eles podem conter a única cópia local de uma composição ainda não promovida
para um artefato final.

## Como auditar a pasta novamente

Comandos de leitura recomendados:

```sh
du -h -d 2 build | sort -h
find build -maxdepth 3 -type f -printf '%p\t%s bytes\n' | sort
find build -type f -name '*.sha256' -exec sh -c 'echo === "$1"; cat "$1"' sh {} \;
find build -type f \( -name '*.iso' -o -name 'vmlinuz*' -o -name 'initrd*' \)
```

Para conferir uma ISO cujo checksum está no mesmo diretório:

```sh
cd build/<projeto>/output
sha256sum -c <arquivo>.sha256
```

O comando deve ser executado no diretório esperado pelo arquivo de checksum,
porque alguns registros usam `./nome.iso` e outros usam somente `nome.iso`.

## Limites deste documento

Este arquivo explica o estado observado em `build/` e relaciona os artefatos
com seus pipelines conhecidos. Ele não reconstrói automaticamente o histórico
completo de cada build, não reexecuta os pipelines e não prova boot. Para uma
conclusão de runtime, são necessários logs de inicialização, console da VM,
manifesto da sessão e testes reproduzíveis.

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
