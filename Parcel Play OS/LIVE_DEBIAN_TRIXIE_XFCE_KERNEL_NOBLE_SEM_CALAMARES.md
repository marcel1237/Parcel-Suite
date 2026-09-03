# Live PlayOS Debian Trixie + XFCE + kernel Noble, sem Calamares

## Registro

- **ID:** `PLAYOS-LIVE-DEBIAN-XFCE-NOBLE-001`
- **Tipo:** `implementation` e `implementation-plan`
- **Estado:** perfil criado; pacotes do kernel, build e runtime pendentes
- **Confiança:** alta para a composição e nomes Debian; runtime `unknown`
- **Data:** 2026-09-03
- **Suite:** Debian 13 `trixie`, fixada por codinome
- **Kernel pretendido:** Ubuntu Noble `6.8.0-138-generic`, artefatos pendentes
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
- `unknown`: os três `.deb` Noble ainda não foram localizados/importados;
- `unknown`: ISO, boot, desktop, rede, áudio e hardware ainda não foram testados.

## Riscos

1. os pacotes Ubuntu do kernel podem declarar dependências incompatíveis com
   Debian e precisam de auditoria com `dpkg-deb -I`;
2. kernel e módulos devem ter a mesma ABI;
3. firmware Debian pode não cobrir algum hardware suportado no Ubuntu;
4. o `live-build` antigo do host não deve ser usado;
5. Secure Boot não está resolvido para kernel local;
6. o tamanho final permanece `unknown` até o build.

## Próximos gates

1. localizar ou gerar os três pacotes Noble 6.8.0-138;
2. importar e validar checksums/dependências;
3. executar em builder Debian 13 com `live-build` atual;
4. auditar manifesto final e estrutura BIOS/UEFI;
5. inicializar em VM e verificar XFCE, overlay e ausência do Calamares;
6. testar hardware e estabelecer atualização/rollback do kernel.

## Fontes

- manifesto local `Live cd Xfce-calamares filesystem.packages`;
- `COMPARACAO_FEDORA_KNOPPIX_LIVE_XFCE_KERNEL_LOCAL_2026-08-26.md`;
- `LIVE_CD_RESOLUTE_XFCE_MINIMAL_KNOPPIX.md`;
- documentação oficial Debian Live e índices de pacotes Trixie;
- informação oficial de release do Debian 13 Trixie.
