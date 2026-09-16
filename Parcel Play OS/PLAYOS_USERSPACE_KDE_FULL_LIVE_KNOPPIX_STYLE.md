# PlayOS Userspace + KDE Full + kernel Noble — Live inspirada no KNOPPIX

- ID: `PLAYOS-USERSPACE-KDE-KNOPPIX-001`
- tipo: `implementation-plan`
- estado: userspace e perfil Live estruturados; preflight, build e runtime pendentes
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

## Estado de capacidade

Após a limpeza da VM anterior, o host apresentou aproximadamente 20 GiB
livres. O build KDE Full anterior precisou de mais espaço de staging. Por isso,
o preflight do novo perfil exige 30 GiB livres e o build não foi iniciado.
Apagar ISOs ou VMs adicionais requer inventário e autorização específica para
não perder resultados únicos.

## Gates

1. liberar pelo menos 30 GiB e executar o preflight;
2. construir em staging sem espaços no caminho;
3. confirmar que todos os repositórios são Ubuntu Noble;
4. validar identidade PlayOS e versões reais dos pacotes;
5. verificar SquashFS, OverlayFS, initramfs, BIOS e UEFI;
6. inicializar em VM e testar SDDM, Plasma X11/Wayland, rede, áudio e Vulkan;
7. implementar persistência somente após o modo Live imutável funcionar;
8. empacotar a identidade em `playos-base-files` antes de uma release.

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
