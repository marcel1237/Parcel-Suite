# Live ISO Noble com XFCE sobre o PlayOS Graphics Core

## Metadados

- **ID:** `KB-PLAYOS-LIVE-XFCE-CORE-001`
- **Tipo:** `implementation-report`
- **Estado:** `implementation`; rebuild e runtime pendentes
- **Confiança:** alta para composição; `unknown` para boot e instalação
- **Verificado em:** 2026-08-27
- **Fontes:** Ubuntu Noble e perfil `live-build/playos-graphics-core-noble/`

## Decisão

O PlayOS passa a separar explicitamente duas camadas:

```text
PlayOS Graphics Core
  kernel + systemd/logind + DRM/Mesa/Vulkan + input + Xorg + Wayland/Labwc
  nenhum GNOME, KDE Plasma ou XFCE
                         |
                         v
PlayOS Noble Live Profile
  XFCE 4.18 + LightDM + Calamares
  nenhum GNOME ou KDE Plasma
```

O XFCE não foi colocado no kernel nem no núcleo gráfico. Ele foi acrescentado
somente à lista de pacotes da edição Live que consome o núcleo. Isso preserva a
possibilidade de outras edições usarem o mesmo Graphics Core com outro desktop
ou sem desktop.

## Por que 4.18 e não 4.20

A consulta ao repositório Noble na VM de build retornou:

```text
xfce4             4.18
xfce4-session     4.18.3-1build2
xfwm4             4.18.0-1build3
xfce4-panel       4.18.4-1ubuntu0.1
thunar            4.18.8-1build3
xfce4-terminal    1.1.3-1build1
xfce4-goodies     4.18.2build1
```

Assim, a baseline reproduzível do Noble é XFCE 4.18. Uma migração para 4.20
exigiria repositório externo, backport ou distribuição diferente, com novo
baseline e testes. Ela não foi realizada silenciosamente.

## Alterações implementadas

- removido o pacote `openbox`;
- removidos script, sessão XDG e autostart específicos do Openbox;
- adicionados `xfce4`, `xfce4-goodies`, `xfce4-terminal`,
  `xfce4-power-manager` e `thunar-volman`;
- LightDM agora seleciona `xfce` como sessão padrão;
- o auditor diferencia `graphics_core_desktop_environment=none` de
  `live_profile_desktop_environment=xfce`;
- Openbox virou pacote proibido no manifesto da edição;
- XFCE, `xfce4-session`, `xfwm4`, painel e Thunar viraram requisitos auditados;
- Labwc e Xwayland permanecem como sessão Wayland técnica opcional;
- o relatório do Calamares passou a tratar XFCE como frontend da Live.

## Sessões resultantes

### Padrão

```text
LightDM -> Xorg -> xfce4-session -> xfwm4 + xfce4-panel + xfdesktop + Thunar
```

### Alternativa técnica

```text
LightDM -> Labwc/Wayland -> Xwayland quando necessário
```

O XFCE 4.18 do Noble não é declarado como sessão Wayland nativa. Labwc continua
separado e não transforma automaticamente XFCE em desktop Wayland.

## Efeito sobre o instalador

O launcher XDG do Calamares aparecerá no menu do XFCE. O Calamares continua
sendo o único motor desta edição e continua implantando
`/run/live/medium/live/filesystem.squashfs`. Como o payload contém XFCE, o
sistema instalado também deverá conter XFCE; isso ainda precisa ser comprovado
por instalação offline em VM.

## Validação realizada

- `fact`: pacotes e versões XFCE existem no Noble.
- `implementation`: perfil não referencia mais Openbox.
- `implementation`: LightDM aponta para a sessão `xfce` fornecida pelo pacote.
- `unknown`: novo rootfs, tamanho do SquashFS e ISO final.
- `unknown`: boot, sessão XFCE, wallpaper, áudio, Vulkan e instalação Calamares.

## Próximos gates

1. Reconstruir o chroot porque o SquashFS anterior ainda contém Openbox e não
   contém esta nova composição XFCE.
2. Auditar manifesto e confirmar ausência de Openbox, GNOME e Plasma.
3. Gerar ISO GRUB e SHA-256.
4. Inicializar em VM e provar LightDM -> XFCE.
5. Abrir Calamares pelo menu do XFCE.
6. Instalar em disco virtual descartável e reiniciar sem a ISO.
7. Validar a sessão Labwc separadamente.

Build bem-sucedido não comprova boot; abertura do instalador não comprova que
particionamento, extração e bootloader funcionam.

## Build da primeira candidata iniciado em 2026-08-28

- o build anterior foi limpo com `lb clean --purge`;
- o diretório antigo foi preservado como
  `/root/playos-graphics-core-noble.pre-xfce-20260827` na VM;
- o perfil foi sincronizado novamente, sem scripts ou sessão Openbox;
- foram confirmados `xfce4`, `calamares` e `--bootloader grub`;
- a VM possuía 16 GiB livres antes do build;
- `lb build` foi iniciado pela unidade transitória
  `playos-xfce-calamares-build.service`;
- estado no primeiro checkpoint: `active`, fase `lb_bootstrap`;
- ISO, checksum e boot permanecem `pending`.

### Correção da etapa binária

A primeira passagem chegou ao manifesto e falhou antes da ISO porque
`--bootloader grub` selecionou `grub-legacy`, indisponível no Noble. A versão
local do `live-build` contém um módulo separado `lb_binary_grub2` e tratamento
correspondente em `lb_binary_iso`; o perfil foi corrigido para
`--bootloader grub2`. O chroot concluído será reutilizado e somente a camada
binária será regenerada.

## Resultado da primeira ISO — 2026-08-28

### Artefato

- `result`: `build/playos-graphics-core-noble/output/playos-noble-xfce-calamares-amd64.iso`;
- tamanho: `1.755.160.576` bytes;
- SHA-256: `4ce6c108ad9d455e80ad859ae61e9890f9aa8a5f14d7408d7e8bed8bf994c1b2`;
- manifesto: `build/playos-graphics-core-noble/output/filesystem.packages`,
  com 1.110 entradas.

### Conteúdo confirmado estaticamente

- kernel e initrd `6.8.0-138-generic`;
- SquashFS 4.0 válido, gzip, 97.507 inodes e 1.602.002.944 bytes;
- XFCE 4.18, LightDM e Calamares 3.3.5;
- Labwc, Xorg, Xwayland, Mesa/Vulkan, PipeWire e WirePlumber;
- NetworkManager, UPower, udisks2, D-Bus e polkit;
- GNOME Shell, Ubuntu Desktop, KDE Plasma e Openbox ausentes do manifesto;
- configurações PlayOS do Calamares, LightDM, sessão Labwc, launcher e branding
  presentes no SquashFS.

### Bootloader e correção aplicada

O `lb binary` antigo completou o SquashFS, mas chamou `grub-mkimage` sem o
prefixo obrigatório e falhou depois pela ausência de `isohybrid`. A ISO
preliminar, cujo El Torito tinha somente 2.048 bytes, foi descartada. A árvore
binária foi finalizada com `grub-mkrescue`/xorriso.

A inspeção final confirmou El Torito BIOS, entrada UEFI em `/efi.img`, MBR
GRUB2 híbrido, GPT protetora e entradas GRUB coerentes com `/live/`. O
procedimento reutilizável está em
`live-build/playos-graphics-core-noble/tools/finalize-grub-iso.sh`.

### Estado correto

- `result`: build, SquashFS, manifesto, checksum e estrutura BIOS/UEFI
  auditados estaticamente;
- `unknown`: boot BIOS/UEFI, LightDM -> XFCE, áudio, aceleração Mesa, Vulkan,
  Labwc e instalação completa pelo Calamares;
- `unknown`: funcionamento em hardware físico;
- `decision`: não declarar a imagem pronta para distribuição antes dos testes
  de runtime e instalação.

O wallpaper final permanece fora deste perfil. Isso não bloqueia o primeiro
teste de boot, mas bloqueia a aprovação visual da edição.
