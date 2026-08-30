# Recriar a primeira ISO PlayOS Noble com XFCE e Calamares

## Metadados

- **ID:** `KB-PLAYOS-REBUILD-FIRST-CALAMARES-ISO-001`
- **Tipo:** `rebuild-runbook`
- **Estado:** `result` para a auditoria do artefato; `implementation` para o perfil; runtime do instalador reprovado pelo usuário
- **Confiança:** alta para composição, arquivos, comandos e auditoria estática; baixa para repetibilidade bit a bit
- **Data da auditoria:** 2026-08-29
- **Artefato de referência:** `/home/marcel/Parcel Suite/Parcel Suite/Parcel Play OS/build/playos-graphics-core-noble/output/playos-noble-xfce-calamares-amd64.iso`
- **Perfil:** `live-build/playos-graphics-core-noble/`
- **Fontes locais:** a ISO, seu manifesto, o perfil `live-build` e `PROGRESSO.md`

Este é o arquivo obrigatório para qualquer IA que precise recriar **a primeira
versão Calamares + XFCE**, e não a variante posterior Calamares + Subiquity nem
a futura versão Desktop Provision.

> **Pipeline obrigatório:** não use `livecd-rootfs`, `build-livefs-lxd`,
> `common_layered_desktop_image`, germinate, Casper, `/casper/` ou
> `boot=casper`. A primeira ISO usa `live-build`, `live-boot`, `/live/` e
> `boot=live`. Consulte também
> [SOLUCAO_IMPEDIMENTOS_RECRIACAO_ISO_CALAMARES_XFCE.md](SOLUCAO_IMPEDIMENTOS_RECRIACAO_ISO_CALAMARES_XFCE.md).

## 1. Identidade exata da ISO de referência

```text
nome: playos-noble-xfce-calamares-amd64.iso
tamanho: 1.755.160.576 bytes
SHA-256: 4ce6c108ad9d455e80ad859ae61e9890f9aa8a5f14d7408d7e8bed8bf994c1b2
data interna xorriso: 2026-08-28 01:22:41 UTC
manifesto: 1.110 linhas
SHA-256 do manifesto: bd8ffeb0a82a596043518ed3c7542572cb4f2f090eb478cebc21792aac9ff855
```

Estruturas estáticas confirmadas: GRUB2, El Torito para BIOS, imagem EFI,
MBR híbrido e GPT protetora. Isso comprova estrutura de boot, não boot real.

Principais versões confirmadas no manifesto da própria ISO:

```text
Ubuntu base                 Noble 24.04
linux-image-generic         6.8.0-138.138
linux-modules               6.8.0-138.138
linux-modules-extra         6.8.0-138.138
linux-firmware              20240318.git3b128b60-0ubuntu2.29
XFCE                        4.18
xfce4-session               4.18.3-1build2
xfwm4                       4.18.0-1build3
xfce4-panel                 4.18.4-1ubuntu0.1
Thunar                      4.18.8-1build3
LightDM                     1.30.0-0ubuntu14
Calamares                   3.3.5-0ubuntu4
Labwc                       0.7.1-1build1
Xwayland                    2:23.2.6-1ubuntu0.8
GRUB amd64                  2.12-1ubuntu7.3
squashfs-tools              1:4.6.1-1build1
WirePlumber                 0.4.17-1ubuntu4.1
```

GNOME Shell, `ubuntu-desktop`, KDE Plasma e Openbox estavam ausentes do
manifesto. XFCE era o desktop da Live; Labwc era uma sessão Wayland técnica.

## 2. Alerta: o perfil atual não é mais idêntico à primeira ISO

Depois da criação do artefato de referência, o perfil foi alterado para testar
uma ponte Calamares → Subiquity. A primeira ISO **não** continha:

```text
subiquity-server
curtin
casper
/usr/lib/calamares/modules/subiquity_bridge/
/usr/lib/calamares/modules/subiquity_exec/
```

Na primeira ISO, `settings.conf` executava os módulos nativos do Calamares:

```yaml
---
modules-search: [ local ]

sequence:
  - show:
      - welcome
      - locale
      - keyboard
      - partition
      - users
      - summary
  - exec:
      - partition
      - mount
      - unpackfs
      - machineid
      - locale
      - keyboard
      - localecfg
      - fstab
      - users
      - displaymanager
      - networkcfg
      - hwclock
      - services-systemd
      - initramfs
      - bootloader
      - umount
  - show:
      - finished

branding: playos
prompt-install: true
dont-chroot: false
oem-setup: false
disable-cancel: false
disable-cancel-during-exec: true
hide-back-and-next-during-exec: true
quit-at-end: false
```

Para reproduzir a primeira versão em um checkout que já contém a ponte
híbrida, prepare automaticamente uma **cópia transitória do perfil**:

```sh
profile_work="$(mktemp -d /tmp/playos-first-calamares.XXXXXX)"
rmdir "$profile_work"
./live-build/playos-graphics-core-noble/tools/prepare-first-calamares-profile.sh \
  "$profile_work"
```

O preparador executa e valida estas ações na cópia:

1. restaure `config/includes.chroot/etc/calamares/settings.conf` com o YAML
   acima;
2. remova da lista direta `subiquity-server`, `curtin` e `casper`;
3. remova os diretórios locais `subiquity_bridge/` e `subiquity_exec/`;
4. mantenha `python3-yaml` se ele já existir: ele estava presente no sistema
   final e não muda a identidade do motor;
5. não altere o perfil canônico nem apague trabalho posterior do usuário.

## 3. Pré-requisitos e limites de segurança

Use uma VM ou container isolado Ubuntu 24.04 amd64. Não instale kernel,
bootloader ou Calamares no host. Não use discos físicos para validar o
instalador.

Recursos recomendados:

```text
CPU: 4 vCPUs
RAM: 4 GiB mínimos; 8 GiB somente se o host possuir memória real suficiente
disco livre: 25 GiB ou mais
rede: acesso aos repositórios Ubuntu Noble
```

Não configure uma VM com mais memória que o host. Em 2026-08-28 uma VM de
8 GiB em host de cerca de 5 GiB esgotou RAM e swap e causou `soft lockup` do
agente LXD durante outro build.

Ferramentas do builder, obtidas dos repositórios Noble:

```sh
sudo apt-get update
sudo apt-get install -y \
  live-build debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools
```

Registre antes do build:

```sh
uname -a
dpkg-query -W live-build debootstrap squashfs-tools xorriso \
  grub-pc-bin grub-efi-amd64-bin
df -h
free -h
```

O build original usou `live-build 3.0~a57`. Versões diferentes podem produzir
outra árvore e outro hash. Os mirrors não estão congelados em snapshot, logo um
novo build é nominalmente reproduzível, mas não bit a bit.

Não instale nem execute `livecd-rootfs` neste ambiente. Sua diversão de
`update-initramfs`, suas tasks/germinate e a convenção Casper pertencem a outro
pipeline. Se houver `update-initramfs.REAL` no chroot antes de `live-tools`,
descarte o chroot contaminado em vez de remover a diversão por hook.

## 4. Preparar uma cópia isolada do perfil

Na raiz do projeto:

```sh
profile_source="$PWD/live-build/playos-graphics-core-noble"
profile_work="$(mktemp -d /tmp/playos-calamares-first.XXXXXX)"
cp -a "$profile_source/." "$profile_work/"
cd "$profile_work"
```

Não reutilize `config/`, `chroot/`, `binary/` ou `.build/` de build
interrompido. Execute a restauração da seção 2 na cópia e confirme:

```sh
! grep -qxE '(subiquity-server|curtin|casper)' \
  config/package-lists/playos-graphics-core.list.chroot
! find config/includes.chroot/usr/lib/calamares/modules \
  -maxdepth 1 -type d -name 'subiquity_*' | grep .
grep -q '^      - unpackfs$' \
  config/includes.chroot/etc/calamares/settings.conf
grep -q '^      - bootloader$' \
  config/includes.chroot/etc/calamares/settings.conf
```

Os testes com `!` devem terminar com código zero.

## 5. Configuração do live-build usada

`auto/config` deve selecionar:

```text
mode: ubuntu
arquitetura: amd64
distribution/parent: noble
componentes: main restricted universe multiverse
imagem: iso-hybrid
bootloader: grub2
debian-installer: false
initramfs: live-boot
init: systemd
kernel: linux-image generic
APT recommends: true
volume: PLAYOS_NOBLE_GC
usuário Live: playos
hostname: playos
locale: pt_BR.UTF-8
teclado: br
```

Fontes online:

```text
http://archive.ubuntu.com/ubuntu/
http://security.ubuntu.com/ubuntu/
```

Fontes locais injetadas pelo perfil:

- configurações e sequência do Calamares;
- launcher `playos-installer` e entrada de desktop;
- branding PlayOS do Calamares;
- LightDM e identidade da Live;
- sessão técnica Labwc;
- hooks de configuração e auditoria.

O kernel da primeira ISO veio do Ubuntu Noble online. Nenhum overlay em
`Kernels/` e nenhum kernel externo do PlayOS foi usado.

## 6. Executar o build

Na cópia transitória:

```sh
sudo lb clean --purge
sudo lb config
sudo lb build 2>&1 | tee playos-noble-xfce-calamares-build.log
```

O `auto/config` também é chamado automaticamente pelo `lb config`. Preserve o
log mesmo quando o comando falhar.

Durante o chroot, os hooks devem:

- tornar os launchers executáveis;
- definir `graphical.target`;
- habilitar LightDM e NetworkManager;
- atualizar MIME, desktop database e fontes;
- gerar `/usr/share/playos/graphics-core-build-audit.txt`;
- falhar se os pacotes requeridos não existirem.

Antes de empacotar, confirme no chroot:

```sh
sudo chroot chroot dpkg-query -W \
  calamares xfce4 xfce4-session xfwm4 xfce4-panel thunar \
  lightdm labwc xwayland mesa-vulkan-drivers libvulkan1 \
  pipewire wireplumber linux-image-generic

sudo chroot chroot sh -c \
  "dpkg-query -W -f='\${binary:Package}\n' | \
   grep -E '^(ubuntu-desktop|kubuntu-desktop|gnome-shell|plasma-desktop|openbox)(:|$)'" \
  && { echo 'erro: desktop proibido presente'; exit 1; } || true
```

## 7. Corrigir a finalização GRUB da versão antiga

No build original, `live-build 3.0~a57` conseguiu criar a árvore binária, mas
falhou na finalização por pressupor Syslinux/isohybrid e chamar ferramentas
GRUB de forma incompatível. Se `lb build` deixar `binary/` ou
`chroot/binary/`, execute:

```sh
sudo ./tools/finalize-grub-iso.sh \
  playos-noble-xfce-calamares-amd64.iso
```

O script usa `grub-mkrescue` e xorriso, aceita ambas as localizações da árvore
e gera SHA-256. Não substitua o payload SquashFS por uma árvore de outra
compilação.

## 8. Gerar e guardar os artefatos

```sh
PROJECT_ROOT="/caminho/absoluto/para/Parcel Play OS"
output="$PROJECT_ROOT/build/playos-graphics-core-noble/output"
mkdir -p "$output"
cp -f playos-noble-xfce-calamares-amd64.iso "$output/"
sha256sum "$output/playos-noble-xfce-calamares-amd64.iso" \
  > "$output/playos-noble-xfce-calamares-amd64.iso.sha256"

sudo chroot chroot dpkg-query -W -f='${binary:Package}\t${Version}\n' \
  | sort > "$output/filesystem.packages"
```

`PROJECT_ROOT` deve ser o caminho absoluto da raiz do checkout. A política do
projeto é manter apenas um output canônico por variante; não apague a ISO de
referência antes de a nova passar nos gates.

## 9. Auditoria estática obrigatória

```sh
cd "$output"
sha256sum -c playos-noble-xfce-calamares-amd64.iso.sha256
stat -c '%n %s bytes' playos-noble-xfce-calamares-amd64.iso

xorriso -indev playos-noble-xfce-calamares-amd64.iso \
  -report_el_torito as_mkisofs

xorriso -indev playos-noble-xfce-calamares-amd64.iso \
  -find /live -maxdepth 2 -type f
```

Confirme pelo menos:

```text
/live/filesystem.squashfs
/live/filesystem.packages ou equivalente
kernel vmlinuz
initrd
/boot/grub/
imagem EFI
entrada El Torito BIOS
```

Extraia o SquashFS e compare a configuração real:

```sh
audit_dir="$(mktemp -d /tmp/playos-first-iso-audit.XXXXXX)"
xorriso -osirrox on \
  -indev playos-noble-xfce-calamares-amd64.iso \
  -extract /live/filesystem.squashfs "$audit_dir/filesystem.squashfs"

unsquashfs -cat "$audit_dir/filesystem.squashfs" \
  etc/calamares/settings.conf
unsquashfs -ll "$audit_dir/filesystem.squashfs" | \
  grep -E 'playos-installer|playos-install.desktop|calamares|playos-release'
```

O launcher espera o payload em
`/run/live/medium/live/filesystem.squashfs`. Se a mídia montar em outro
caminho, o Calamares recusará iniciar.

## 10. Testes de runtime

Estado conhecido:

- `result`: ISO criada e auditada estaticamente;
- `unknown`: boot BIOS e UEFI desta ISO nunca foi comprovado nos registros;
- `unknown`: XFCE, Labwc, rede, áudio, Mesa e Vulkan em runtime;
- `result`: o usuário informou posteriormente que o Calamares não funcionou;
- `unknown`: causa exata da falha, porque não há log de runtime do instalador.

Primeiro teste sem instalação:

1. inicializar em QEMU UEFI;
2. repetir em BIOS;
3. confirmar usuário Live, LightDM e XFCE;
4. verificar `/run/live/medium/live/filesystem.squashfs`;
5. executar `/usr/local/sbin/playos-installer` pelo terminal e guardar stdout,
   stderr e `journalctl`;
6. confirmar que Calamares abre e detecta somente discos virtuais.

Teste destrutivo controlado:

1. usar VM descartável e disco virtual vazio de pelo menos 20 GiB;
2. iniciar em UEFI, instalar offline em ext4 sem criptografia;
3. remover a ISO e provar boot por GRUB;
4. provar kernel, initramfs, LightDM e XFCE no sistema instalado;
5. repetir em BIOS;
6. somente depois testar LVM, criptografia, dual boot e Secure Boot.

Nunca testar inicialmente em disco físico. Nunca classificar `build` como
`boot`, nem interface aberta como instalação concluída.

## 11. Diagnóstico mínimo quando o Calamares falhar

Na sessão Live, colete:

```sh
test -r /run/live/medium/live/filesystem.squashfs
ls -lh /run/live/medium/live/filesystem.squashfs
calamares --version
sudo -E calamares -d 2>&1 | tee /tmp/calamares-debug.log
journalctl -b --no-pager > /tmp/journal-live.log
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
findmnt
```

Verifique especialmente:

- caminho e leitura do SquashFS;
- compatibilidade dos módulos listados em `settings.conf` com Calamares 3.3.5;
- montagem do alvo e espaço livre;
- geração de `fstab` e initramfs;
- instalação BIOS/UEFI do GRUB;
- exclusão de arquivos e serviços exclusivos da Live no alvo.

Sem esses logs, a causa permanece `unknown`. A próxima versão com Desktop
Provision deve ser construída em outro perfil/output e não deve alterar a
evidência histórica desta ISO.

## 12. Critério de equivalência e conclusão

Uma reconstrução é **equivalente em composição** quando:

- usa Noble amd64 e kernel generic coerente;
- contém XFCE 4.18, LightDM e Calamares 3.3.5 ou versões Noble registradas;
- usa a sequência nativa Calamares desta página;
- não contém Subiquity, Curtin ou Casper como backend do instalador;
- contém os mesmos arquivos locais e caminho de payload;
- passa a auditoria estática BIOS/UEFI e registra manifesto e SHA-256.

Ela só será **funcional** quando também inicializar e concluir instalação em
VM descartável, reiniciando sem a mídia. O hash igual ao artefato de referência
só é esperado com as mesmas versões de ferramentas, pacotes e índices de
repositório; no modelo atual, isso não está garantido.
