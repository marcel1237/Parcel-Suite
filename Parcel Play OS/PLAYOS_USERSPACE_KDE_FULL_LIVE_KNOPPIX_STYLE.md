# PlayOS Userspace + KDE Full + kernel Noble — Live inspirada no KNOPPIX

- ID: `PLAYOS-USERSPACE-KDE-KNOPPIX-001`
- tipo: `implementation-plan`
- estado: userspace e perfil Live estruturados; ISO intermediária construída; runtime pendente
- confiança: alta para arquitetura; média para primeiro build; runtime `unknown`
- data: 2026-09-07

## Decisão

O produto não usará um rootfs KNOPPIX nem um userspace Debian. A primeira
geração terá identidade e composição PlayOS, usando os binários Ubuntu Noble
como baseline de bootstrap e compatibilidade. Essa dependência deve permanecer
visível: mudar `/etc/os-release` não transforma pacotes Ubuntu em software
desenvolvido pelo PlayOS.

O KNOPPIX 9.1 público é baseado em Debian Bullseye e inclui alguns pacotes Sid.
Também usa patches `cloop` e AUFS. Portanto, usar o rootfs ou pipeline exato do
KNOPPIX contrariaria o requisito de não usar userspace Debian e exigiria
alterações desnecessárias no kernel Noble.

## O que será reproduzido do modelo KNOPPIX

| Comportamento KNOPPIX | Implementação PlayOS inicial |
|---|---|
| filesystem comprimido somente leitura | SquashFS |
| escrita durante a sessão | OverlayFS em RAM |
| copiar a raiz para RAM | parâmetro `toram` do `live-boot` |
| conferir integridade da mídia | `verify-checksums` e `md5sum.txt` |
| mídia utilizável como ISO e USB | ISO híbrida BIOS/UEFI |
| autodetecção | kernel Noble, udev e systemd |
| persistência opcional | gate futuro com `persistence` |

Não entram `cloop`, AUFS, scripts antigos de detecção, kernel 32-bit ou mistura
de releases. A arquitetura é inspirada no KNOPPIX, não compatível com o layout
privado de sua mídia.

## Composição da primeira ISO

- identidade: PlayOS 1;
- bootstrap de pacotes: arquivos Ubuntu Noble `main`, `restricted`, `universe`
  e `multiverse`;
- kernel: Ubuntu Noble `generic`, versão exata registrada após o build;
- desktop: `kde-full` do Ubuntu Noble, Plasma 5.27 na baseline do arquivo;
- sessões: Plasma X11 e Wayland;
- login: SDDM, inicialmente com greeter X11 e autologin da sessão Live;
- rede: NetworkManager;
- áudio: PipeWire, WirePlumber e ALSA;
- gráficos: Mesa, Vulkan e firmware Ubuntu;
- Live: `live-boot`, `live-config`, SquashFS e OverlayFS;
- instalador: nenhum.

## Fontes e propriedade

`userspace/playos-noble/` é a fonte canônica da composição do userspace. O
perfil de ISO está em
`live-build/playos-ubuntu-noble-kde-full-knoppix-style/`. Nesta fase, pacotes
binários continuam sendo baixados dos mirrors Ubuntu; nenhum mirror Debian é
aceito pela auditoria.

Para o userspace se tornar progressivamente independente, o projeto ainda
precisa de um pacote `playos-base-files`, repositório APT assinado, publicação
de fontes correspondentes, rebuilds dos pacotes modificados, infraestrutura de
atualizações e política de segurança.

## Resultado da execução de 2026-09-16/17

- `result`: preflight inicial passou com aproximadamente 53 GiB livres no
  staging do host.
- `implementation`: o perfil foi executado em uma VM Ubuntu 24.04 Noble
  isolada chamada `playos-ubuntu-noble-kde-builder-vm`, com 4 vCPUs, 4 GiB de
  RAM e disco lógico de 40 GiB.
- `result`: o bootstrap Ubuntu Noble e a composição `kde-full` foram gerados
  no chroot preservado da VM.
- `implementation`: `--updates true` foi removido do `auto/config` porque a
  versão local do `live-build` não aceita essa opção; Noble, Noble Updates e
  Noble Security permaneceram nos mirrors configurados.
- `implementation`: `syslinux-utils` foi adicionado ao manifesto para prover
  `isohybrid` no chroot; `genisoimage` precisou ser instalado na VM para a
  etapa final.
- `implementation`: `--build-with-chroot false` foi fixado no perfil para
  reutilizar corretamente a árvore direta `chroot/` preservada.
- `result`: o SquashFS final teve 6.024 MiB comprimidos, a partir de cerca de
  9.394 MiB descomprimidos.
- `result`: a ISO foi criada em
  `build/playos-ubuntu-noble-kde-full-knoppix-style/playos-ubuntu-noble-kde-full-live.iso`,
  com 6.458.335.232 bytes e SHA-256
  `03863ec2c98d10cce3d33c3112bcb71f5a1b7fc2410c5170e780e42da50c5075`.
- `result`: `file` identificou uma imagem ISO 9660 bootável e `xorriso -toc`
  confirmou volume `PLAYOS_NOBLE_KDE`, catálogo El Torito e entrada
  `boot/grub/grub_eltorito`.
- `warning`: a tentativa de `isohybrid` falhou porque a imagem GRUB2 não
  possui a assinatura `isolinux.bin`; portanto, a propriedade híbrida
  USB/BIOS ainda não foi comprovada.
- `result`: a cópia da ISO da VM para `build/` foi conferida contra o mesmo
  SHA-256.
- `result`: as VMs `playos-ubuntu-noble-kde-builder-vm` e
  `playos-noble-graphics-builder` foram desligadas após a transferência.
- `unknown`: boot BIOS/UEFI, SDDM, Plasma X11, Plasma Wayland, KWin,
  Xwayland, Mesa/Vulkan, áudio, input, rede e kernel PlayOS ainda não foram
  validados em runtime.

### Perfil efetivamente construído

O manifesto versionado em
`live-build/playos-ubuntu-noble-kde-full-knoppix-style/config/package-lists/playos-kde-full.list.chroot`
inclui:

- `live-boot`, `live-config`, systemd, initramfs-tools, locales e console;
- `kde-full`, Plasma Workspace, Plasma Wayland, KWin X11, KWin Wayland e SDDM;
- Dolphin e Konsole;
- NetworkManager, udisks2, UPower, PolicyKit e portais XDG/KDE;
- PipeWire, `pipewire-audio`, WirePlumber e ALSA;
- Mesa DRI, drivers Vulkan Mesa e `vulkan-tools`;
- firmware Linux, `pciutils` e `usbutils`;
- SquashFS, `syslinux-utils`, `procps`, `kmod`, `curl` e certificados.

O hook `010-playos-live.chroot`:

1. escreve a identidade Live em `/etc/issue`;
2. adiciona `overlay`, `squashfs` e `iso9660` ao initramfs;
3. define `graphical.target`;
4. habilita SDDM e NetworkManager;
5. regenera todos os initramfs.

O hook `900-playos-audit.chroot` falha se encontrar repositórios Debian,
instaladores proibidos ou desktops/display managers não autorizados, e imprime
as versões dos pacotes KDE, Live, rede, áudio e kernel. A auditoria estática
não substitui boot ou teste visual.

### Sequência operacional reproduzida

O fluxo realizado na VM foi:

```sh
lb clean --purge
./auto/config
./tools/preflight.sh
lb build 2>&1 | tee build.log
```

Após falhas nas etapas finais, o rootfs pronto foi preservado e somente a etapa
binária foi repetida. O modo final foi:

```sh
./auto/config
lb clean --binary
lb binary 2>&1 | tee binary-retry6.log
```

Como a versão instalada do `live-build` não concluiu a última chamada de
`genisoimage`, a imagem foi fechada manualmente com:

```sh
genisoimage -J -l -cache-inodes -allow-multidot \
  -allow-limited-size -iso-level 3 \
  -A "PlayOS Noble KDE Full Live" \
  -V PLAYOS_NOBLE_KDE \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -r -b boot/grub/grub_eltorito \
  -o binary.hybrid.iso binary
```

Esse comando criou a sessão ISO 9660 com catálogo El Torito GRUB2. A execução
posterior de `isohybrid binary.hybrid.iso` não foi aceita, pois `isohybrid`
esperava uma assinatura de boot `isolinux.bin`, inexistente no layout GRUB2.

### Artefatos e hashes

| Artefato | Estado | Evidência |
|---|---|---|
| `binary/live/filesystem.squashfs` | `result` | 6.024 MiB comprimidos; 227.974 inodes |
| `binary/live/vmlinuz-6.8.0-139-generic` | `result` | kernel Ubuntu Noble empacotado |
| `binary/live/initrd.img-6.8.0-139-generic` | `result` | initramfs correspondente empacotado |
| `binary/live/filesystem.packages` | `result` | manifesto gerado pelo live-build |
| `binary.hybrid.iso` | `result` | 6.458.335.232 bytes; ISO 9660 bootável |
| `playos-ubuntu-noble-kde-full-live.iso` | `result` | cópia em `build/`, hash conferido |
| `*.iso.sha256` | `result` | `03863ec2c98d10cce3d33c3112bcb71f5a1b7fc2410c5170e780e42da50c5075` |

O nome `binary.hybrid.iso` foi mantido por compatibilidade com o perfil, mas
não deve ser interpretado como prova de híbrido USB/BIOS. A própria ferramenta
reportou a rejeição da assinatura híbrida.

### Matriz de tentativas e recuperação

| Tentativa | Sintoma | Causa | Ação |
|---|---|---|---|
| configuração inicial | opção `--updates true` rejeitada | opção inexistente na versão local | remover a opção |
| build no host | exigência de root | `lb build` precisa montar/chrootar como root | mover para VM Noble |
| binário inicial | `isohybrid: not found` | utilitário ausente no chroot | adicionar `syslinux-utils` |
| retry binário | `binary` não vazio | saída residual da tentativa anterior | limpar somente etapa binária |
| retry seguinte | SquashFS acima de 4 GiB | `binary*` anterior foi incluído recursivamente | remover artefatos residuais |
| retry seguinte | `flash-kernel` já existe | link residual `/bin/true` | remover somente esse link |
| retry com chroot padrão | `Cannot stat source directory chroot` | modo esperava `chroot/chroot` | fixar `--build-with-chroot false` |
| ISO padrão | `genisoimage: not found` | dependência ausente na VM | instalar `genisoimage` |
| fechamento manual | `isohybrid` rejeitado | GRUB2 não fornece assinatura isolinux | manter como ISO El Torito intermediária |

Nenhum kernel foi instalado no host, nenhuma entrada de boot foi alterada e as
duas VMs foram desligadas ao final.

Falhas recuperadas durante a execução:

1. `lb config` rejeitou `--updates true`.
2. `lb build` no host exigiu root; o build foi movido para VM isolada.
3. A primeira etapa binária não encontrou `isohybrid`.
4. Uma tentativa reutilizou `binary` residual e falhou por diretório não vazio.
5. Artefatos binários residuais foram incluídos recursivamente no SquashFS,
   ultrapassando o limite ISO9660 convencional.
6. A reexecução encontrou o link residual `chroot/usr/sbin/flash-kernel`.
7. O modo de chroot foi corrigido e a geração do SquashFS passou.
8. A etapa padrão não encontrou `genisoimage`; a dependência foi instalada e
   a ISO foi gerada manualmente com ISO9660 nível 3.

## Estado de capacidade

Após a limpeza da VM anterior, o host apresentou aproximadamente 20 GiB
livres. O build KDE Full anterior precisou de mais espaço de staging. Por isso,
o preflight do novo perfil exige 30 GiB livres e o build não foi iniciado.
Apagar ISOs ou VMs adicionais requer inventário e autorização específica para
não perder resultados únicos.

## Gates

1. verificar a composição e os metadados da ISO intermediária;
2. obter uma rota de teste com console gráfico e inicializar em VM;
3. validar BIOS e UEFI, distinguindo boot El Torito de ISO híbrida USB;
4. testar SDDM, Plasma X11/Wayland, rede, áudio e Vulkan;
5. repetir os gates com o kernel PlayOS mantendo o kernel Ubuntu como fallback;
6. implementar persistência somente após o modo Live imutável funcionar;
7. empacotar a identidade em `playos-base-files` antes de uma release.

## Plano de implementação

### Fase 0 — congelar o contrato

1. Manter Ubuntu Noble como único userspace e fonte de pacotes.
2. Fixar amd64, `main restricted universe multiverse` e os mirrors usados no
   build.
3. Manter `kde-full` como composição KDE Full, aceitando o custo de espaço e
   tempo de build.
4. Manter Plasma X11 como primeiro caminho de validação e Plasma Wayland como
   segundo caminho.
5. Manter SDDM como único display manager da variante.
6. Não incluir Debian, KDE neon, Calamares, Subiquity, Casper ou rootfs
   KNOPPIX.
7. Registrar a versão real do `kde-full`, Plasma, kernel, SDDM e Mesa no
   manifesto produzido pelo build.

**Saída:** contrato de composição aprovado e matriz de versões congelada.

### Fase 1 — preparar o ambiente isolado

1. Recuperar pelo menos 30 GiB livres no pool/staging sem apagar artefatos
   únicos.
2. Copiar o perfil para um caminho sem espaços, por exemplo:

   ```text
   /home/marcel/playos-ubuntu-noble-kde-full-knoppix-style
   ```

3. Usar VM ou outro ambiente isolado para o build.
4. Confirmar a presença de `lb`, `debootstrap`, `mksquashfs`, `xorriso`,
   ferramentas GRUB BIOS/UEFI e `isohybrid`.
5. Executar o preflight antes de qualquer limpeza.

**Saída:** staging reproduzível, ferramentas auditadas e espaço suficiente.

### Fase 2 — completar o perfil Live

1. Revisar `auto/config` para garantir:
   - Ubuntu Noble;
   - ISO híbrida;
   - GRUB BIOS/UEFI;
   - `--debian-installer false`;
   - `boot=live components`;
   - `--initramfs live-boot`.
2. Manter no manifesto:
   - `kde-full`;
   - `plasma-workspace-wayland`;
   - `kwin-x11`;
   - `kwin-wayland`;
   - `sddm`;
   - X.Org/Xwayland;
   - Mesa/Vulkan;
   - NetworkManager;
   - PipeWire/WirePlumber;
   - firmware e microcode.
3. Criar hook de auditoria que falhe se detectar:
   - pacotes Debian ou mirrors Debian;
   - KDE neon ou PPAs não autorizados;
   - instaladores;
   - mais de um display manager habilitado.
4. Configurar autologin somente na Live e deixar explícito que isso não é
   aceitável para uma instalação persistente.
5. Gerar `/usr/share/playos/build-audit.txt` com versões e origem dos pacotes.

**Saída:** perfil Ubuntu Noble KDE Full auditável antes do build.

### Fase 3 — construir a ISO de referência

1. Executar:

   ```sh
   lb clean --purge
   lb config
   lb build 2>&1 | tee build.log
   ```

2. Confirmar código de saída zero.
3. Preservar:
   - ISO;
   - manifesto de pacotes;
   - inventário de conteúdo;
   - log;
   - checksum SHA-256.
4. Inspecionar a ISO e confirmar:
   - `/live/vmlinuz`;
   - initramfs correspondente;
   - `filesystem.squashfs`;
   - entradas BIOS e UEFI;
   - volume e identidade PlayOS.
5. Não declarar boot ou desktop funcional apenas com o build concluído.

**Saída:** ISO Ubuntu Noble KDE Full estruturalmente validada.

### Fase 4 — validar boot básico

1. Criar VM descartável separada da VM de build.
2. Testar UEFI e BIOS quando o console disponível permitir.
3. Confirmar:
   - GRUB;
   - kernel e initramfs;
   - montagem do SquashFS;
   - OverlayFS;
   - `systemd`;
   - `graphical.target`;
   - rede via NetworkManager.
4. Registrar o kernel efetivamente executado com `uname`.
5. Registrar falhas de `grub-probe`, D-Bus, device nodes e firmware sem
   transformá-las em sucesso implícito.

**Gate B0:** boot até userspace/rede.

### Fase 5 — validar Plasma X11

1. Confirmar SDDM como display manager ativo.
2. Entrar na sessão Plasma X11.
3. Confirmar KWin X11, teclado, mouse, resolução e logout.
4. Validar Dolphin, Konsole, rede, montagem de mídia e áudio.
5. Confirmar `/dev/dri`, renderer Mesa e aceleração ou fallback identificado.
6. Guardar logs do SDDM, X.Org, KWin, PipeWire e kernel.

**Gate B1:** login, uso básico e logout em Plasma X11.

### Fase 6 — validar Plasma Wayland

1. Selecionar Plasma Wayland no SDDM.
2. Confirmar KWin Wayland e Xwayland.
3. Testar aplicações X11 dentro da sessão Wayland.
4. Validar Mesa/Vulkan, input, áudio e logout.
5. Testar retorno ao SDDM sem loop de login.
6. Manter Plasma X11 como fallback caso Wayland falhe.

**Gate B2:** login, compatibilidade Xwayland e logout em Plasma Wayland.

### Fase 7 — integrar o kernel PlayOS

1. Repetir o build com o kernel PlayOS/Noble somente depois de validar o
   userspace com o kernel Ubuntu genérico.
2. Injetar kernel, módulos e initramfs da mesma ABI.
3. Confirmar que o perfil não instala um kernel Debian concorrente.
4. Comparar boot, DRM/KMS, input, rede, áudio, Mesa e Vulkan com a ISO de
   referência.
5. Preservar o kernel genérico como fallback durante os testes.

**Gate B3:** KDE Full funcional sobre o kernel PlayOS.

### Fase 8 — endurecimento e distribuição

1. Remover autologin da variante instalada.
2. Separar configurações Live de configurações persistentes.
3. Criar pacote `playos-base-files` para identidade declarativa.
4. Criar repositório APT PlayOS assinado antes de distribuir modificações
   próprias.
5. Testar atualização, rollback e preservação do kernel anterior.
6. Testar mídia USB, `toram` e checksum; persistência fica para fase posterior.
7. Atualizar catálogos, manifesto, `PROGRESSO.md` e relatório de execução.

**Gate final:** ISO reproduzível, boot validado, Plasma X11 e Wayland
registrados como `result`, e limitações de hardware explicitamente documentadas.

## Matriz de bloqueadores

| Bloqueador | Impacto | Resolução |
|---|---|---|
| Espaço insuficiente | impede `kde-full` e o SquashFS | liberar staging isolado |
| QEMU/VGA indisponível | impede validação visual | obter QEMU ou console gráfico equivalente |
| Kernel customizado sem boot | separa kernel de userspace | validar primeiro com kernel Ubuntu |
| Mistura de mirrors | quebra identidade e ABI | auditoria de fontes APT |
| Autologin persistente | risco de segurança | restringir autologin à Live |
| Plasma Wayland falhar | perda do segundo caminho gráfico | manter X11 como fallback |

## Fontes primárias consultadas

- [KNOPPIX 9.1 — notas oficiais](https://www.knopper.net/knoppix/knoppix910-en.html)
- [Descrição oficial do KNOPPIX](https://www.knopper.net/knoppix/index-en)
- [Fontes dos componentes especiais KNOPPIX](https://knopper.net/knoppix-sources/)
- [Ubuntu Noble — pacote kde-full](https://packages.ubuntu.com/en/noble/kde-full)
- [Ubuntu — manual live-boot](https://manpages.ubuntu.com/manpages/resolute/man7/live-boot.7.html)

As notas do KNOPPIX confirmam Debian Bullseye, `cloop`, AUFS, mídia híbrida,
filesystem comprimido, overlay persistente e `flash-knoppix`. O arquivo Ubuntu
confirma `kde-full` 5:146ubuntu3 em Noble. Nenhuma dessas fontes comprova o boot
da futura ISO PlayOS; isso permanece pendente.
