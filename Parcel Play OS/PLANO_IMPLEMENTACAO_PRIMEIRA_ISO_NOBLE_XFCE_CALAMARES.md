# Plano de implementação da primeira ISO PlayOS Noble XFCE Calamares

## Metadados

- **ID:** `KB-PLAYOS-FIRST-ISO-PLAN-001`
- **Tipo:** `implementation-plan`
- **Estado:** `implementation`; build em andamento
- **Confiança:** alta para entradas e pipeline; `unknown` para boot final
- **Data:** 2026-08-28
- **Perfil:** `live-build/playos-graphics-core-noble/`
- **Builder:** VM LXD `playos-noble-graphics-vm`

## 1. Resultado pretendido

Produzir uma ISO híbrida amd64 com:

```text
Ubuntu Noble
+ kernel oficial generic
+ live-boot/live-config
+ PlayOS Graphics Core neutro
+ Xorg + XFCE 4.18
+ Wayland + Labwc técnico
+ LightDM
+ Mesa/OpenGL/Vulkan
+ PipeWire/WirePlumber
+ Calamares
+ GRUB
```

O Graphics Core permanece uma camada sem GNOME, KDE Plasma ou XFCE. O XFCE é
um consumidor instalado somente no perfil da Live. Calamares é o único motor
de instalação. `--debian-installer false` desativa o Debian Installer do
`live-build`; isso não desativa Calamares, que é instalado no rootfs.

## 2. Política de fontes

### Online

O APT baixa pacotes e dependências de:

| Uso | URL | Suite/componentes |
|---|---|---|
| bootstrap, chroot e binário | `http://archive.ubuntu.com/ubuntu/` | Noble; main, restricted, universe, multiverse |
| atualizações de segurança | `http://security.ubuntu.com/ubuntu/` | Noble security |
| atualizações habilitadas pelo perfil | archive Ubuntu | Noble updates conforme índices APT |

As assinaturas dos índices são verificadas pelo APT/debootstrap. No primeiro
checkpoint, o debootstrap confirmou uma assinatura Release válida.

### Local

O projeto injeta apenas arquivos de configuração, scripts, launchers, sessão e
branding. Não existe pacote `.deb` PlayOS local neste perfil.

### Consequência para reprodutibilidade

Os pacotes seguem o candidato vigente nos repositórios Noble. Portanto:

- a composição nominal é reproduzível;
- versões podem mudar entre dois builds;
- o resultado ainda não é bit a bit reproduzível;
- o manifesto final deve registrar todas as versões realmente instaladas;
- para congelamento futuro, usar snapshot de repositório ou espelho interno
  assinado e versionado.

## 3. Pacotes explicitamente solicitados

Todos os 74 nomes abaixo têm origem **online** nos repositórios Ubuntu Noble.
Nenhum deles é lido da pasta `Kernels/`, de `/home/marcel/Parcel Suite/Linux
Kernels` ou de um `.deb` local.

### Boot e sessão Live — online

```text
live-boot
live-config
systemd-sysv
sudo
locales
console-setup
keyboard-configuration
```

### IPC, login e autorização — online

```text
dbus
dbus-user-session
policykit-1
lxpolkit
```

### Rede, energia e armazenamento — online

```text
network-manager
upower
udisks2
```

### Integração XDG — online

```text
desktop-file-utils
shared-mime-info
xdg-utils
xdg-user-dirs
hicolor-icon-theme
```

### Gráficos, Mesa e Vulkan — online

```text
libdrm2
libgl1-mesa-dri
mesa-vulkan-drivers
libvulkan1
vulkan-tools
mesa-utils
```

### Input e fontes — online

```text
libinput10
libinput-tools
xserver-xorg-input-libinput
fontconfig
fonts-dejavu-core
fonts-noto-core
```

### X11 e XFCE — online

```text
xserver-xorg
xserver-xorg-core
x11-xserver-utils
xinit
xterm
xfce4
xfce4-goodies
xfce4-terminal
xfce4-power-manager
thunar-volman
```

Baseline confirmada no Noble:

```text
xfce4          4.18
xfce4-session  4.18.3-1build2
xfwm4          4.18.0-1build3
xfce4-panel    4.18.4-1ubuntu0.1
thunar         4.18.8-1build3
```

### Wayland técnico — online

```text
wayland-protocols
xwayland
labwc
foot
wofi
mako-notifier
wlr-randr
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-wlr
```

Labwc continua uma sessão Wayland separada. A ISO não declara XFCE 4.18 como
desktop Wayland nativo.

### Login — online

```text
lightdm
lightdm-gtk-greeter
```

### Instalador e discos — online

```text
calamares
parted
dosfstools
e2fsprogs
rsync
squashfs-tools
grub-pc-bin
grub-efi-amd64-bin
```

Calamares foi confirmado como `3.3.5-0ubuntu4` em `noble/universe`.

### Áudio — online

```text
alsa-utils
pipewire
pipewire-audio
pipewire-pulse
wireplumber
```

### Diagnóstico e utilitários — online

```text
pciutils
usbutils
procps
kmod
less
nano
curl
ca-certificates
```

## 4. Kernel, módulos e firmware

Origem: **online Ubuntu Noble**.

O `live-build` está configurado com:

```text
--linux-packages linux-image
--linux-flavours generic
```

Isso resolve o kernel generic vigente, seus módulos e dependências pelo APT.
No ambiente de referência, `linux-image-generic` apontava para
`6.8.0-138.138`, mas a versão autoritativa desta ISO será a registrada no
manifesto final. `linux-firmware` também é baixado online; durante o build foi
observado `20240318.git3b128b60-0ubuntu2.29` com aproximadamente 655 MB de
download.

Nenhum kernel modificado das pastas externas ou overlays PlayOS é usado nesta
primeira ISO. Isso elimina o risco de misturar `vmlinuz`, módulos e initramfs
de ABIs diferentes.

## 5. Dependências transitivas

Como `--apt-recommends true`, o APT instala:

- dependências obrigatórias;
- pacotes recomendados;
- bibliotecas Qt/KF5 necessárias ao Calamares;
- componentes internos XFCE;
- drivers Xorg/Mesa e bibliotecas auxiliares;
- kernel, módulos e firmware.

Esses pacotes são todos **online**. A lista completa só fica determinada após
o fechamento do chroot. No checkpoint do build já haviam sido resolvidos mais
de 700 downloads, mas quantidade de mensagens não equivale ao total final de
pacotes.

O inventário definitivo será produzido por:

```bash
chroot chroot dpkg-query -W -f='${binary:Package}\t${Version}\n' \
  | sort > playos-noble-xfce-calamares.packages.tsv
```

Também devem ser preservados:

```text
/var/lib/apt/lists/
/var/log/apt/history.log
/var/log/apt/term.log
/usr/share/playos/graphics-core-build-audit.txt
```

## 6. Arquivos fornecidos localmente pelo PlayOS

Origem: **local**, dentro de
`live-build/playos-graphics-core-noble/config/includes.chroot/`.

### Calamares

```text
etc/calamares/settings.conf
etc/calamares/modules/bootloader.conf
etc/calamares/modules/displaymanager.conf
etc/calamares/modules/finished.conf
etc/calamares/modules/partition.conf
etc/calamares/modules/services-systemd.conf
etc/calamares/modules/unpackfs.conf
etc/calamares/modules/users.conf
etc/calamares/modules/welcome.conf
usr/local/sbin/playos-installer
usr/share/applications/playos-install.desktop
usr/share/calamares/branding/playos/branding.desc
usr/share/calamares/branding/playos/slide.svg
```

### Sessão e identidade

```text
etc/lightdm/lightdm.conf.d/50-playos-live.conf
etc/playos-release
etc/xdg/labwc/autostart
usr/local/bin/playos-core-wayland-session
usr/share/wayland-sessions/playos-core-wayland.desktop
```

XFCE fornece sua própria sessão X11 online; não existe mais sessão Openbox
local. LightDM seleciona `xfce` como padrão.

### Hooks locais

```text
config/hooks/010-playos-graphics-core.chroot
config/hooks/900-playos-graphics-audit.chroot
```

O primeiro aplica permissões, identidade e serviços. O segundo gera uma
auditoria contendo desktops proibidos, desktop da Live e pacotes requeridos.

## 7. Ferramentas usadas somente para construir

As ferramentas abaixo estão instaladas na VM builder a partir de pacotes
**online Ubuntu Noble**, mas não devem ser confundidas com o conteúdo final:

```text
live-build
debootstrap
apt/dpkg
squashfs-tools
xorriso
grub tooling
systemd
```

LXD e a VM são infraestrutura do host. O diretório do projeto e o perfil são
fontes locais. A internet é necessária no modelo atual.

## 8. Plano de execução

### Fase A — preparar ambiente

1. Confirmar VM Ubuntu 24.04, amd64, CPU, RAM e espaço.
2. Confirmar relógio, DNS e acesso aos mirrors.
3. Verificar assinaturas Release e ferramentas de build.
4. Limpar somente o build transitório anterior com `lb clean --purge`.
5. Preservar logs/configuração anterior para diagnóstico.
6. Sincronizar o perfil local em diretório novo.
7. Confirmar ausência dos scripts Openbox removidos.

Estado: concluído. A VM possuía 16 GiB livres antes do build.

### Fase B — configurar live-build

1. Executar `lb config` por `auto/config`.
2. Selecionar Ubuntu Noble amd64.
3. Habilitar main, restricted, universe e multiverse.
4. Selecionar ISO híbrida e GRUB2 (`--bootloader grub2`); nesta versão antiga
   do `live-build`, `grub` significa o removido GRUB Legacy.
5. Selecionar live-boot, systemd e kernel generic.
6. Definir usuário `playos`, hostname, locale pt_BR e teclado br.

Estado: concluído.

### Fase C — bootstrap e chroot

1. Baixar índices e sistema base.
2. Validar assinaturas e hashes.
3. Instalar os 74 pacotes declarados e dependências.
4. Instalar kernel, módulos e firmware.
5. Copiar os arquivos locais para o chroot.
6. Executar hooks PlayOS.
7. Gerar initramfs para a mesma ABI do kernel.
8. Gerar manifesto completo.

Estado no momento deste documento: em andamento.

### Fase D — validação antes da compressão

Bloquear o build se faltar qualquer item requerido ou se aparecer:

```text
openbox
gnome-shell
plasma-desktop
ubuntu-desktop
kubuntu-desktop
```

Confirmar:

```text
xfce4, xfce4-session, xfwm4, xfce4-panel, thunar
lightdm
calamares
labwc, xwayland
mesa-vulkan-drivers, libvulkan1
pipewire, wireplumber
kernel, módulos e initramfs com a mesma ABI
```

### Fase E — SquashFS e ISO

1. Comprimir chroot em `live/filesystem.squashfs`.
2. Copiar kernel e initrd para a árvore ISO.
3. Gerar menu GRUB e estruturas BIOS/UEFI suportadas.
4. Gerar filesystem manifest e metadados da mídia.
5. Montar ISO híbrida com volume `PLAYOS_NOBLE_GC`.
6. Produzir somente um output canônico em
   `build/playos-graphics-core-noble/output/`.
7. Gerar SHA-256 e registrar tamanho em bytes.

### Fase F — inspeção estática da ISO

1. Verificar ISO com `xorriso`.
2. Listar kernel, initrd, SquashFS, GRUB e manifesto.
3. Montar a ISO somente leitura.
4. Extrair e comparar o manifesto.
5. Confirmar launcher e configurações Calamares.
6. Confirmar o caminho usado por `unpackfs`:
   `/run/live/medium/live/filesystem.squashfs`.

### Fase G — boot sem instalação

1. Boot UEFI em QEMU.
2. Boot BIOS em QEMU.
3. Confirmar live-boot, usuário `playos` e LightDM.
4. Confirmar sessão XFCE completa.
5. Confirmar Labwc separadamente.
6. Testar rede, áudio, input, Mesa e Vulkan.
7. Abrir Calamares sem disco alvo e confirmar recusa segura.

### Fase H — instalação destrutiva controlada

1. Criar VM descartável com disco vazio de pelo menos 20 GiB.
2. Inicializar a ISO em UEFI.
3. Usar somente o disco virtual.
4. Instalar offline com ext4, sem criptografia no primeiro caso.
5. Remover a ISO.
6. Provar boot por GRUB, kernel e initramfs instalados.
7. Provar LightDM e XFCE no sistema alvo.
8. Confirmar remoção ou desativação de componentes exclusivos da Live.
9. Repetir em BIOS.

Nenhum teste inicial deve usar disco físico.

## 9. Artefatos e evidências esperados

```text
playos-noble-xfce-calamares-amd64.iso
playos-noble-xfce-calamares-amd64.iso.sha256
playos-noble-xfce-calamares.packages.tsv
playos-noble-xfce-calamares.files.txt
playos-noble-xfce-calamares-build.log
playos-noble-xfce-calamares-boot-uefi.log
playos-noble-xfce-calamares-boot-bios.log
playos-noble-xfce-calamares-install.log
```

Os nomes finais serão confirmados quando a ISO existir. Nenhum deles deve ser
marcado como resultado antes de ser efetivamente produzido.

## 10. Critério de conclusão

A primeira ISO só será chamada funcional quando:

- build e auditoria estática passarem;
- checksum for registrado;
- UEFI e BIOS iniciarem;
- XFCE abrir pela LightDM;
- Calamares concluir instalação offline em disco virtual;
- o sistema instalado reiniciar sem a mídia;
- kernel, módulos, initramfs e bootloader forem coerentes.

Build, pacote presente ou interface aberta isoladamente não satisfazem esse
critério.
