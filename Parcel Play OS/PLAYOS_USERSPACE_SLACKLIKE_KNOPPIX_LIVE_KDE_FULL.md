# PlayOS Native Userspace: modelo Slackware + Live modelo KNOPPIX + KDE completo

- ID: `PLAYOS-NATIVE-USERSPACE-SLACK-KNOPPIX-KDE-001`
- tipo: `architecture-decision`
- estado: arquitetura aprovada; Stage0 de console implementado, empacotado e inicializado em VM UEFI; stack nativa completa e KDE pendentes
- confiança: alta para separação arquitetural e boot Stage0; runtime gráfico `unknown`
- data: 2026-09-07

## Resultado arquitetural

```text
kernel e módulos Ubuntu Noble locais
                 ↓
initramfs Live PlayOS
                 ↓
SquashFS somente leitura + OverlayFS gravável
                 ↓
PlayOS Native Userspace
├── init tradicional e scripts /etc/rc.d
├── pacotes PlayOS .pxz
├── pkgtools PlayOS
├── biblioteca e serviços compilados por receitas PlayOS
└── perfil playos-kde-full construído de fontes KDE upstream
```

“Imitação total” significa reproduzir princípios, interfaces e experiência por
implementação própria e auditável. Não significa copiar marca, identidade,
scripts ou código de Slackware/KNOPPIX sem revisão de licença. Os nomes do
produto e dos comandos públicos serão PlayOS.

## Baseline que substitui a anterior

A proposta anterior usava identidade PlayOS sobre pacotes Ubuntu Noble. Ela é
útil como protótipo, mas não satisfaz um userspace nativo. Nesta baseline:

- Ubuntu fornece somente kernel, módulos, firmware necessário ao kernel e,
  temporariamente, o compilador de bootstrap no host;
- o rootfs final não usa APT, dpkg nem repositórios Debian/Ubuntu;
- cada componente do userspace possui receita, versão, fonte, checksum,
  licença e log de build PlayOS;
- o KDE completo é um conjunto PlayOS, não o metapacote `kde-full` do APT;
- nenhum pacote será declarado PlayOS apenas por renomear metadados Ubuntu.

## Modelo Slackware reproduzido

| Comportamento observado | Implementação PlayOS |
|---|---|
| pacote simples `.txz` | pacote `.pxz`, tar + xz, manifesto e checksum |
| `installpkg` | `playpkg-install` |
| `removepkg` | `playpkg-remove` |
| `upgradepkg` | `playpkg-upgrade` |
| `makepkg` | `playpkg-build` |
| histórico em `/var/log/packages` | `/var/lib/playpkg/installed` e transações |
| dependências explícitas | receitas declaram dependências; resolução é opcional e auditável |
| sets `a`, `ap`, `d`, `l`, `n`, `x`, `xap`, `kde` | collections PlayOS equivalentes |
| SysV init + scripts BSD-like | `sysvinit`, `/etc/inittab` e `/etc/rc.d/rc.*` próprios |
| runlevel 3 texto e 4 gráfico | mesmos contratos no PlayOS |

Compatibilidade de comportamento não implica compatibilidade binária com
pacotes Slackware. Pacotes Slackware não serão instalados diretamente.

## Modelo KNOPPIX reproduzido

| Comportamento observado | Implementação PlayOS |
|---|---|
| imagem comprimida somente leitura | `/PLAYOS/PLAYOS.squashfs` |
| escrita transparente | OverlayFS com upperdir em tmpfs |
| boot da mídia e USB | ISO híbrida BIOS/UEFI |
| `toram` | cópia opcional do SquashFS para RAM |
| teste da mídia | SHA-256 antes de montar a raiz |
| persistência | partição/arquivo rotulado `PLAYOS-DATA`, gate posterior |
| detecção automática | udev, kmod e scripts PlayOS |
| remasterização | `playos-flash` e `playos-remaster`, gates posteriores |

Não serão usados `cloop` ou AUFS. O kernel Noble já oferece SquashFS e
OverlayFS; portar patches antigos aumentaria risco sem melhorar o contrato.

## KDE completo do PlayOS

O nome `kde-full` é um metapacote de distribuições APT. Para o userspace nativo,
`playos-kde-full` será uma collection formada por receitas upstream:

1. Qt e dependências gráficas;
2. KDE Frameworks;
3. Plasma Workspace, KWin, SDDM e Plasma NetworkManager;
4. KDE Gear: administração, educação, jogos, gráficos, multimídia, rede, PIM,
   utilitários e desenvolvimento;
5. X11, Wayland, Xwayland, Mesa, Vulkan, PipeWire e WirePlumber;
6. traduções, fontes, temas, portais XDG e integração polkit/elogind.

Cada grupo terá lockfile de versões. “Completo” será definido pelo manifesto,
não pela expectativa de que toda aplicação publicada pelo KDE caiba na ISO.

## Problema de integração do kernel Noble

O kernel pode ser reutilizado, mas seus pacotes `.deb` não entram no rootfs.
O pipeline extrairá de artefatos verificados apenas:

- `vmlinuz`;
- `/lib/modules/<ABI>`;
- firmware necessário e permitido;
- metadados de versão e checksums.

O initramfs será gerado pelo PlayOS e deverá carregar SquashFS, OverlayFS,
ISO9660, armazenamento, USB, teclado e drivers essenciais. Kernel compilado não
comprova que esse userspace inicializa.

## Fases obrigatórias

1. **Bootstrap:** toolchain isolado e diretório raiz vazio.
2. **Base:** musl ou glibc, shell, coreutils, util-linux, e2fsprogs, kmod e udev.
3. **Init:** sysvinit e scripts PlayOS; console funcional no runlevel 3.
4. **Pacotes:** formato `.pxz`, banco de arquivos, instalação atômica e rollback.
5. **Rede e sessão:** D-Bus, elogind, polkit, NetworkManager e áudio.
6. **Gráficos:** DRM userspace, Mesa, X.Org, Wayland e Xwayland.
7. **KDE:** Qt, Frameworks, Plasma e collections KDE Gear.
8. **Live:** initramfs PlayOS, SquashFS/OverlayFS e ISO híbrida.
9. **Runtime:** BIOS, UEFI, X11, Wayland, rede, áudio, Vulkan e persistência.
10. **Distribuição:** fontes correspondentes, licenças, repositório assinado e atualizações.

## Evidência dos protótipos XFCE e KDE anteriores

O protótipo XFCE provou que o kernel Noble `6.8.0-138-generic` pode ser
empacotado com initramfs `live-boot`, SquashFS e um desktop em uma ISO híbrida.
Seu build gerou uma ISO de 1.388.435.456 bytes; o boot UEFI carregou kernel e
initrd e a sessão alcançou rede. A abertura visual do XFCE permaneceu sem prova.

O KDE não é apenas teoricamente possível: o mesmo pipeline já produziu uma ISO
de 3.755.513.856 bytes. O manifesto confirmou `kde-full`, Plasma, KWin X11 e
Wayland, SDDM, Dolphin, Konsole e os mesmos três pacotes Noble. Checksum e boot
estático BIOS/UEFI passaram; o runtime gráfico ainda não foi executado.

As diferenças reais entre os dois perfis foram pequenas:

- `xfce4`/LightDM foram substituídos por `kde-full`/SDDM;
- o hook habilitou SDDM em vez de LightDM;
- a auditoria passou a exigir Plasma, KWin, Dolphin e Konsole;
- a ISO cresceu aproximadamente 2,20 GiB;
- o staging KDE exigiu disco substancialmente maior.

Ambos usaram Debian Trixie, APT/dpkg, systemd, `live-build`, `live-boot` e
`live-config`. Portanto, eles provam a compatibilidade do **kernel Noble com a
arquitetura Live e com KDE**, mas não provam o novo PlayOS Native Userspace.

No userspace nativo, a equivalência deverá ser reconstruída camada por camada:

```text
live-build/live-boot       -> playos-live-builder + initramfs PlayOS
APT/dpkg                   -> playpkg e pacotes .pxz
systemd/live-config        -> sysvinit + rc.d + configuração Live PlayOS
pacote kde-full            -> collection playos-kde-full
pacotes Debian de Qt/KDE   -> receitas PlayOS compiladas de fontes upstream
```

O caminho de menor risco preserva primeiro o kernel/initramfs e obtém um
console nativo. Somente depois adiciona gráficos e KDE. Tentar compilar KDE
antes de libc, init, dispositivos, D-Bus, elogind, polkit, Mesa e áudio estarem
validados produziria uma ISO grande sem uma base inicializável diagnosticável.

## Gates de segurança e qualidade

- zero binários sem origem, licença e checksum;
- nenhuma colisão silenciosa de arquivos entre pacotes;
- remoção de pacote não pode apagar arquivo pertencente a outro pacote;
- scripts de pacote executam em ambiente controlado;
- initramfs falha em shell de recuperação legível;
- mídia adulterada é rejeitada quando verificação for solicitada;
- build reproduzível medido, não presumido;
- nenhum uso da marca Slackware ou KNOPPIX como identidade PlayOS.

## Implementação inicial realizada

O formato `.pxz` v1 e os comandos `playpkg-build`, `playpkg-install` e
`playpkg-remove` já existem em `userspace/playos-native/pkgtools/`. O banco
registra metadados, lista de arquivos e propriedade exclusiva de arquivos e
links; diretórios permanecem compartilháveis.

Os smoke tests confirmaram:

- criação determinística básica de um pacote tar+xz;
- instalação e execução de payload numa raiz temporária;
- remoção do payload e dos registros;
- rejeição de colisão entre arquivos de dois pacotes;
- rejeição de symlink absoluto;
- exclusão de metadados e arquivos temporários do payload instalado.

Também foi criado o primeiro pacote real, `playos-base-files`, contendo
identidade, hostname, `inittab` e os scripts próprios `rc.S`, `rc.M`, `rc.4` e
`rc.6`. Ele passou build, instalação e remoção em rootfs temporário. Isso ainda
não comprova boot: os binários consumidos pelos scripts não foram compilados.

Limitações conhecidas do formato v1: ainda não há assinatura, upgrade
transacional, recuperação após queda de energia, scripts de pacote isolados ou
resolução de dependências.

## Fontes primárias

- [Slackware Package Management](https://docs.slackware.com/slackware%3Apackage_management)
- [Slackware package anatomy and pkgtools](https://docs.slackware.com/slackware%3Apackage_management_hands_on)
- [Slackware init and boot process](https://docs.slackware.com/howtos%3Aslackware_admin%3Ainit_and_boot_process)
- [Slackware official package browser](https://packages.slackware.com/)
- [KNOPPIX 9.1 release notes](https://www.knopper.net/knoppix/knoppix910-en.html)

As fontes confirmam os comportamentos usados como referência. A comprovação do
PlayOS depende separadamente dos resultados locais descritos abaixo.

## Resultado executável: Native Stage0

Em 2026-09-07 foi construída a primeira ISO de console do novo pipeline, sem
`live-build`, rootfs Debian ou gerenciadores de pacotes de outras
distribuições. O script reproduzível é
`userspace/playos-native/live/build-stage0.sh` e a saída é
`build/playos-native-stage0/output/playos-native-stage0-noble-amd64.iso`.

Composição confirmada:

- kernel e módulos Ubuntu Noble `6.8.0-138-generic`, validados pelo manifesto
  SHA-256 local antes da extração;
- BusyBox 1.37.0 estático, fonte com SHA-256 fixado;
- `playos-base-files` instalado pelo `playpkg-install` no staging vazio;
- initramfs próprio que encontra a mídia, monta SquashFS, cria OverlayFS e
  executa `switch_root`;
- GRUB e ISO híbrida com entradas El Torito BIOS e UEFI;
- arquivos do SquashFS e initramfs normalizados como `root:root`;
- applets `apt`, `dpkg`, `dpkg-deb`, `rpm` e `rpm2cpio` ausentes.

O boot UEFI foi executado numa VM LXD/KVM isolada. O console confirmou
`PlayOS Native 1`, kernel `6.8.0-138-generic`, `/dev/sr0` montado somente para
leitura em `/mnt/live`, raiz OverlayFS gravável e criação bem-sucedida de um
arquivo em `/root`. Portanto, o estado correto é `result`: **Stage0 de console
inicializado em UEFI**.

Defeitos encontrados e corrigidos durante o gate:

1. o applet BusyBox `tc` não compilava com os headers Linux atuais e foi
   removido do Stage0, pois não participa do boot;
2. o staging persistia entre builds e agora seus diretórios transitórios são
   limpos, preservando somente cache de fontes;
3. o SquashFS preservava UID/GID do host e agora usa `-all-root`;
4. os links `/sbin/modprobe`, `/sbin/mdev` e `/sbin/switch_root` faltavam no
   initramfs;
5. `/run` passou a ser tmpfs antes do `switch_root`;
6. o `inittab` inicial foi reduzido ao formato aceito pelo PID 1 BusyBox;
7. applets de pacotes estrangeiros habilitados por `defconfig` foram
   explicitamente desativados.

Limites: o teste executado comprova UEFI em VM, não BIOS em runtime nem
hardware real. BusyBox ainda é bootstrap e não comprova libc/toolchain,
SysVinit completo, D-Bus, elogind, polkit, Mesa, áudio, rede gerenciada,
Wayland/X11, SDDM ou KDE. O próximo gate técnico é substituir o bootstrap por
pacotes nativos versionados e obter o runlevel 3 antes de iniciar a árvore KDE.

## Stage1 nativo concluído e inicializado

Foi criado `userspace/playos-native/buildroot/` para produzir uma toolchain e
um rootfs Stage1 por cross-compilação de fontes. Buildroot 2026.02 está fixado
pelo SHA-256
`d54b7ffece06ff28cbb81e28e3de74ea405ca6b77c38fbe8b18fa57bef585f8b`.
Ele é ferramenta de bootstrap, não identidade, repositório binário ou
gerenciador de pacotes do produto.

A configuração efetiva seleciona glibc, headers 6.8, C++, localidades
`pt_BR.UTF-8`/`en_US.UTF-8`, SysVinit, eudev, Bash, ferramentas GNU, util-linux,
e2fsprogs, kmod, shadow, procps-ng, D-Bus, polkit e certificados. Um overlay
adiciona os scripts `rc.d`, identidade e `playpkg`; o pós-build rejeita APT,
dpkg e RPM.

O staging ficou isolado em
`/home/marcel/kernel-work/playos-native-stage1`, porque `/tmp` possui somente
2,6 GiB e o caminho do projeto contém espaços. O build retomável roda como
`playos-native-stage1-build.service`; o log é
`build/playos-native-stage1/build.log`.

### Resultado do rootfs

- `result`: `build/playos-native-stage1/output/playos-native-stage1-rootfs.tar`
  foi produzido com 49.715.200 bytes e SHA-256
  `c1816a65ab97bc794a140585bb9992dd65cffbf16794a39a0eeabcd7f88f2fcd`;
- `result`: a identidade do rootfs é `PlayOS Native Stage1` (`ID=playos`);
- `result`: APT, dpkg e RPM estão ausentes;
- `implementation`: as interfaces nativas presentes são
  `playpkg-install` e `playpkg-remove`, com banco em `/var/lib/playpkg`.

### ISO e teste UEFI

A composição Live reutiliza exclusivamente o `vmlinuz`, o initramfs e os
módulos do kernel Noble já validados. O restante do rootfs vem do Stage1
cross-compilado. O script reproduzível é
`userspace/playos-native/live/build-stage1-iso.sh`.

- `result`: ISO criada em
  `build/playos-native-stage1-iso/output/playos-native-stage1-noble-amd64.iso`;
- `result`: tamanho 316.071.936 bytes; SHA-256
  `0368dd13c443673f3788d67aa46fff4593cae7bf06ff286a8fa198c023c65a1a`;
- `result`: El Torito BIOS e UEFI passaram na inspeção estática;
- `result`: boot UEFI em VM chegou ao login do runlevel 3;
- `result`: runtime confirmou kernel `6.8.0-138-generic`, PID 1 `init`, eudev,
  D-Bus, módulos Noble e root gravável por OverlayFS;
- `result`: escrita em `/root` passou; APT, dpkg e RPM continuaram ausentes no
  runtime.

O teste não valida BIOS em runtime, hardware físico, Secure Boot, rede
gerenciada, áudio ou gráficos. O próximo gate é a camada Stage2 com DRM/Mesa,
libinput, X.Org/Wayland, PipeWire/WirePlumber e Qt 6; KDE vem depois que essa
base iniciar e for testada isoladamente.
