# Live PlayOS Debian Trixie + XFCE + kernel Noble, sem Calamares

## Registro

- **ID:** `PLAYOS-LIVE-DEBIAN-XFCE-NOBLE-001`
- **Tipo:** `implementation` e `implementation-plan`
- **Estado:** perfil criado; kernel importado; primeiro build interrompido pelo
  ambiente de contêiner; ISO e runtime pendentes
- **Confiança:** alta para a composição e nomes Debian; runtime `unknown`
- **Data:** 2026-09-03
- **Suite:** Debian 13 `trixie`, fixada por codinome
- **Kernel:** Ubuntu Noble `6.8.0-138-generic`, três artefatos importados e
  verificados por SHA-256
- **Desktop:** XFCE/Xorg/LightDM Debian
- **Instalador:** nenhum

## Resultado da implementação

Foi criado o perfil versionável:

```text
live-build/playos-debian-trixie-xfce-noble-kernel/
```

Ele aplica ao PlayOS a arquitetura útil observada no Knoppix — raiz comprimida
somente leitura e escrita efêmera por camada de união — usando mecanismos
Debian atuais: SquashFS, OverlayFS, `live-boot`, `live-config` e `live-build`.
Não copia `cloop`, AUFS nem scripts Knoppix.

## Como o manifesto foi usado

A fonte `Live cd Xfce-calamares filesystem.packages` possui 1.110 entradas.
Foi criada uma referência derivada com 1.109 entradas, retirando somente:

```text
calamares  3.3.5-0ubuntu4
```

Não foram apagadas por aproximação bibliotecas compartilhadas, ferramentas de
disco, SquashFS, GRUB ou componentes gráficos. O arquivo resultante continua
sendo um inventário Ubuntu histórico, não entrada válida para APT Debian.

Na receita operacional, a seleção parte das funções confirmadas pelo manifesto
e usa nomes Debian Trixie. Dependências exclusivas do Calamares, como a cadeia
Qt/KPMcore que o APT havia resolvido, deixam de entrar automaticamente. Se
outro componente exigir alguma biblioteca compartilhada, ela permanece.

### Por que não apagar manualmente todas as bibliotecas do Calamares

`Live cd Xfce-calamares filesystem.packages` é um manifesto do sistema Ubuntu
já instalado. Ele informa nome e versão, mas não registra qual pacote causou a
instalação de cada dependência. Uma biblioteca Qt, ferramenta de partição ou
componente do GRUB pode ter sido usado pelo Calamares e também por outro
componente da Live.

Assim, “retirar os pacotes do Calamares” foi implementado em duas camadas:

1. na cópia histórica, remover literalmente somente a entrada `calamares`, a
   única atribuição direta comprovada pelo manifesto;
2. na receita Debian, não solicitar Calamares nem seus settings e deixar o APT
   recalcular as dependências a partir das funções que a nova Live realmente
   precisa.

Esse método elimina dependências exclusivas automaticamente e preserva toda
biblioteca compartilhada ainda necessária. Remover Qt/KPMcore em massa apenas
pelo nome seria uma inferência insegura. O hook final proíbe Calamares e seus
settings e torna qualquer reaparecimento um erro de build.

Na comparação lexical normalizada, 1.045 dos 1.109 nomes existem também no
Trixie e 64 não existem sob o mesmo nome. Entre os 64 estão componentes Ubuntu,
ABIs de bibliotecas antigas e os três pacotes Noble que serão fornecidos
localmente. Esses 64 casos foram preservados em relatório; não foram convertidos
automaticamente para pacotes possivelmente diferentes.

## Fontes dos componentes

| Camada | Fonte |
|---|---|
| kernel, módulos e módulos-extra | pacotes locais Ubuntu Noble, SHA-256 obrigatório |
| base, libc, systemd e udev | Debian 13 Trixie |
| Live, initramfs e overlay | Debian `live-boot`/`live-config` |
| XFCE, Xorg e LightDM | Debian Trixie |
| Mesa/Vulkan, input, fontes e áudio | Debian Trixie |
| rede, energia, discos e firmware | Debian Trixie |
| criação BIOS/UEFI da ISO | Debian `live-build`, GRUB/xorriso/syslinux |
| Calamares ou outro instalador | ausente |

Não há mirror Ubuntu no chroot. APT não pode misturar Ubuntu e Debian.

## Arquitetura de boot

```text
BIOS/UEFI
  -> bootloader Debian
  -> kernel + módulos Ubuntu Noble
  -> initramfs-tools/live-boot Debian
  -> filesystem.squashfs Debian somente leitura
  -> OverlayFS em RAM
  -> systemd/live-config
  -> LightDM
  -> XFCE/Xorg
```

## O que significa “da maneira do Knoppix”

O PlayOS usa o **modelo arquitetural** que tornou o Knoppix uma referência de
Live Debian, não uma cópia dos scripts ou patches Knoppix:

| Conceito observado no Knoppix | Implementação atual no PlayOS |
|---|---|
| raiz comprimida e imutável | `filesystem.squashfs` |
| escrita durante a sessão | OverlayFS em RAM |
| boot direto da mídia | GRUB BIOS/UEFI + `live-boot` |
| base Debian | Debian 13 Trixie |
| desktop leve | XFCE + Xorg + LightDM |
| detecção de hardware | kernel, udev e serviços Debian atuais |
| remasterização declarativa | perfil versionado do `live-build` |

Não são usados `cloop`, AUFS, scripts históricos de autodetecção nem patches
do Knoppix. A ferramenta de construção é o `live-build` atual do Debian. Isso
é mais reproduzível e compatível com SquashFS, OverlayFS, systemd e UEFI.

O diferencial do PlayOS é controlado: o userspace e todo o mecanismo Live são
Debian, enquanto a imagem e os módulos do kernel vêm de três pacotes oficiais
Ubuntu Noble locais e de ABI idêntica. Nenhum repositório Ubuntu é adicionado
ao APT Debian.

## Receita operacional implementada

O perfil encontra-se em:

```text
live-build/playos-debian-trixie-xfce-noble-kernel/
├── auto/config
├── config/package-lists/playos-xfce.list.chroot
├── config/packages.chroot/
├── config/hooks/live/010-playos-xfce.hook.chroot
├── config/hooks/live/900-playos-audit.hook.chroot
├── manifests/
└── tools/
```

### Configuração Debian Live

`auto/config` fixa:

- modo Debian e suite `trixie`;
- arquitetura `amd64`;
- áreas `main contrib non-free-firmware`;
- mirrors exclusivamente Debian;
- ISO híbrida;
- GRUB para BIOS e UEFI;
- `live-boot` e systemd;
- nenhum Debian Installer;
- recomendações APT habilitadas no primeiro build;
- usuário e hostname Live `playos`, locale `pt_BR.UTF-8` e teclado `br`.

O perfil aponta o sabor de kernel para `6.8.0-138-generic`. Os pacotes locais
com esse nome satisfazem a seleção sem instalar o metapacote Debian
`linux-image-amd64`.

### Pacotes da Live

A entrada operacional contém 67 solicitações diretas, organizadas em:

- infraestrutura `live-boot`/`live-config`;
- três pacotes do kernel Noble;
- XFCE, XFCE Goodies, Xorg e LightDM;
- D-Bus, polkit, NetworkManager, UPower, udisks2 e XDG;
- Mesa, Vulkan, libinput, fontes, ALSA, PipeWire e WirePlumber;
- firmware e microcode Debian;
- armazenamento, diagnóstico e utilitários Live.

A relação legível está em
`PACOTES_LIVE_DEBIAN_TRIXIE_XFCE_KERNEL_NOBLE.md`. A fonte executável continua
sendo `config/package-lists/playos-xfce.list.chroot`.

### Hooks

O primeiro hook define `graphical.target`, habilita LightDM e NetworkManager e
regenera todos os initramfs. O segundo aborta o build se encontrar:

```text
calamares
calamares-data
calamares-settings-debian
libcalamares*
subiquity
curtin
casper
linux-image-amd64
linux-image-cloud-amd64
linux-image-rt-amd64
```

Quando passa, o hook grava em `/usr/share/playos/build-audit.txt` as versões
dos componentes críticos e a identidade da composição.

## Procedimento de construção da maneira Debian

### 1. Usar um builder Debian 13

O host possui uma versão Ubuntu antiga do `live-build` que não deve executar
este perfil. O build deve ocorrer em VM Debian Trixie isolada. No builder, as
ferramentas requeridas são:

```text
live-build debootstrap squashfs-tools xorriso
grub-pc-bin grub-efi-amd64-bin dosfstools mtools
isolinux syslinux-common syslinux-utils rsync
```

### 2. Conferir o kernel local

O preflight exige exatamente os três arquivos `.deb`, arquitetura amd64 e os
checksums registrados em `manifests/noble-kernel.sha256`:

```text
linux-image-6.8.0-138-generic_6.8.0-138.138_amd64.deb
linux-modules-6.8.0-138-generic_6.8.0-138.138_amd64.deb
linux-modules-extra-6.8.0-138-generic_6.8.0-138.138_amd64.deb
```

### 3. Executar preflight e build

Dentro da VM Debian, com o perfil copiado para um caminho sem espaços:

```sh
cd /root/playos-debian-trixie-xfce-noble-kernel
./tools/preflight.sh
lb config
./tools/build.sh
```

`build.sh` precisa de privilégios dentro do builder porque `debootstrap`,
mounts do chroot e criação da mídia exigem root. Ele executa
`lb clean --purge`, reconfigura o perfil, compõe a ISO e gera SHA-256.

### 4. Resultado esperado

O `live-build` deve produzir uma ISO híbrida com kernel/initramfs em `/live`,
raiz SquashFS, boot BIOS/UEFI e um manifesto completo de pacotes. O nome exato
da saída só será declarado depois do build concluído.

## Execução realizada até agora

- `result`: os três pacotes oficiais Noble 6.8.0-138 foram obtidos, importados
  e tiveram os SHA-256 conferidos;
- `result`: o preflight estático passou no builder Debian;
- `result`: o primeiro build instalou a raiz Debian, XFCE, LightDM, firmware,
  kernel e módulos, e gerou `initrd.img-6.8.0-138-generic` com `live-boot`;
- `result`: esse build não chegou à ISO porque o contêiner LXD não privilegiado
  representou `/dev/null` como arquivo comum durante o chroot. Um redirecionamento
  gravou `/usr/bin/aspell` nesse arquivo e o `dictionaries-common` falhou;
- `decision`: não tornar o contêiner persistentemente privilegiado para
  contornar o problema;
- `implementation`: foi iniciada a preparação de uma VM Debian completa, onde
  os device nodes do chroot não dependem dessa limitação do contêiner;
- `unknown`: ISO final, boot BIOS/UEFI, sessão XFCE, rede, áudio e hardware.

A falha foi do ambiente de construção, não evidência de incompatibilidade do
kernel Noble com o userspace Debian. Essa compatibilidade só poderá ser marcada
como resultado depois do boot da ISO.

## Decisões de pacote

- não usar `live-task-xfce`, pois recomenda settings Debian do Calamares;
- solicitar diretamente XFCE, XFCE Goodies e LightDM;
- manter `apt-recommends` durante o primeiro build para integração completa;
- bloquear Calamares, settings, Subiquity, Curtin e Casper em hook de auditoria;
- bloquear metapacote de kernel Debian;
- manter ferramentas de disco e recuperação mesmo sem instalador;
- usar firmware Debian, porque somente kernel/módulos podem vir do Ubuntu.

## Verificações realizadas

- `fact`: Debian 13 Trixie é a stable corrente em 2026-09-03;
- `fact`: todos os nomes da lista operacional foram encontrados nos índices
  oficiais Trixie após substituir `policykit-1` por `polkitd`, `pkexec` e
  `lxpolkit`;
- `result`: manifesto derivado contém 1.109 entradas e uma exclusão direta;
- `result`: comparação com índices Trixie encontrou 1.045 nomes coincidentes e
  64 nomes Ubuntu/ABI/local sem correspondência literal;
- `implementation`: receita, hooks, includes, importador, preflight e script de
  build existem;
- `result`: os três `.deb` Noble foram importados e seus checksums conferidos;
- `result`: a primeira execução avançou até kernel e initramfs, mas foi
  interrompida pelo `/dev/null` inválido do contêiner não privilegiado;
- `unknown`: ISO, boot, desktop, rede, áudio e hardware ainda não foram testados.

## Riscos

1. o boot do kernel Ubuntu sobre o userspace Debian ainda precisa de teste em
   runtime; instalação bem-sucedida do pacote não comprova inicialização;
2. kernel e módulos devem ter a mesma ABI;
3. firmware Debian pode não cobrir algum hardware suportado no Ubuntu;
4. o `live-build` antigo do host não deve ser usado e contêiner sem device
   nodes reais não é adequado a este build;
5. Secure Boot não está resolvido para kernel local;
6. o tamanho final permanece `unknown` até o build.

## Próximos gates

1. concluir a preparação da VM Debian 13 com `live-build` atual;
2. executar novamente o perfil no ambiente com device nodes reais;
3. auditar manifesto final e estrutura BIOS/UEFI;
4. inicializar em VM e verificar XFCE, overlay e ausência do Calamares;
5. testar hardware e estabelecer atualização/rollback do kernel.

## Fontes

- manifesto local `Live cd Xfce-calamares filesystem.packages`;
- `COMPARACAO_FEDORA_KNOPPIX_LIVE_XFCE_KERNEL_LOCAL_2026-08-26.md`;
- `LIVE_CD_RESOLUTE_XFCE_MINIMAL_KNOPPIX.md`;
- documentação oficial Debian Live e índices de pacotes Trixie;
- informação oficial de release do Debian 13 Trixie.
