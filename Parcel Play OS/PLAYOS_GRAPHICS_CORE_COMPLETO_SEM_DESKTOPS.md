# PlayOS Graphics Core completo sem GNOME, KDE ou XFCE

## Estado e decisão

- **Classificação:** `decision`, `architecture` e `proposal`.
- **Data:** 2026-08-26.
- **Produto:** `playos-graphics-core`.
- **Kernel:** `linux-playos-graphics`.
- **Desktops excluídos:** GNOME, KDE Plasma e XFCE.
- **Implementação/build/runtime:** ainda não realizados por este documento.

Esta revisão recoloca todos os componentes comuns na distribuição gráfica do
PlayOS, exceto os três ambientes de desktop. O produto inclui boot, sessão,
autorização, rede, energia, discos, padrões XDG, aceleração, input, fontes, X11,
Wayland, login e áudio.

Isso não altera a fronteira técnica do Linux: componentes userspace não serão
ligados ao `vmlinux`. “Tudo junto” significa uma única composição instalável,
uma ISO, um manifesto, um diagnóstico e uma política de atualização.

## 1. Composição restaurada

```text
PlayOS Graphics Core
├── linux-playos-graphics
│   ├── DRM/KMS
│   ├── drivers de GPU
│   ├── dma-buf e sincronização
│   ├── evdev/HID
│   └── console e firmware
├── systemd/logind + D-Bus + polkit
├── NetworkManager + UPower + udisks2
├── utilitários e padrões XDG
├── libdrm + Mesa
│   └── OpenGL + Vulkan + EGL/GLX
├── libinput + libevdev
├── fontconfig + FreeType + HarfBuzz
├── X.Org + XCB + Xft
├── Wayland + Xwayland + Labwc
├── LightDM
└── ALSA + PipeWire + WirePlumber
```

Ficam fora:

```text
GNOME / GNOME Shell / Mutter / GDM
KDE Plasma / KWin / SDDM / KDE Frameworks como desktop
XFCE / xfwm4 / painel / sessão / Thunar como desktop
```

Bibliotecas GTK ou Qt podem aparecer como dependências de utilitários, mas isso
não significa instalar GNOME ou KDE. A composição deve evitar metapacotes de
desktop.

Vulkan integra oficialmente o runtime do Graphics Core por loader e ICDs Mesa.
WSI X11 usa Xorg/XCB; WSI Wayland usa Labwc. A especificação detalhada está em
`VULKAN_NO_PLAYOS_GRAPHICS_CORE.md`.

## 2. Duas unidades, um produto

### Unidade kernel

`linux-playos-graphics` contém somente código kernel:

- DRM/KMS, drivers e memória gráfica;
- dma-buf, fences e sincronização;
- input evdev/HID;
- console e framebuffer de recuperação;
- firmware loader, PCI, IOMMU e energia.

### Unidade userspace

`playos-graphics-core` instala serviços, bibliotecas, servidores e ferramentas
que usam o kernel. O metapacote depende do kernel, nunca o inverso.

```text
playos-graphics-core
        ↓ depende
linux-playos-graphics-meta
```

Para o usuário, `sudo apt install playos-graphics-core` instala a composição
completa. Para engenharia, cada pacote continua substituível e auditável.

## 3. systemd/logind, D-Bus e polkit

### Uso

- systemd inicializa serviços e sessões;
- logind controla seats, usuários ativos e acesso a dispositivos;
- D-Bus conecta serviços e aplicações;
- polkit autoriza operações privilegiadas.

Mesmo sem desktop, esses componentes são necessários para LightDM, Labwc,
NetworkManager, UPower, udisks2 e sessão do usuário.

### Regras

- `graphical.target` pode iniciar LightDM;
- `multi-user.target` permanece recuperação;
- somente uma sessão recebe o seat ativo;
- um agente polkit leve e neutro pode ser iniciado na sessão Labwc;
- nenhuma regra polkit universalmente permissiva;
- serviços D-Bus usam políticas próprias e nomes corretos.

## 4. NetworkManager, UPower e udisks2

### NetworkManager

Oferece Ethernet, Wi-Fi e VPN por serviço e CLI. Sem painel de desktop, a
administração inicial usa `nmcli` ou uma ferramenta gráfica neutra opcional.

```bash
nmcli general status
nmcli device status
nmcli device wifi list
```

### UPower

Publica bateria e alimentação. Sem painel GNOME/KDE/XFCE, seus dados ficam
disponíveis por D-Bus, `upower` e futuras ferramentas PlayOS.

```bash
upower -e
upower -d
```

### udisks2

Permite montagem segura de mídia removível. Sem gerenciador de arquivos de
desktop, a operação pode usar `udisksctl` ou uma aplicação neutra futura.

```bash
udisksctl status
udisksctl mount -b /dev/<dispositivo>
```

O exemplo exige substituir o dispositivo com identificação consciente.

## 5. Padrões e utilitários XDG

O core mantém:

```text
desktop-file-utils
shared-mime-info
xdg-utils
xdg-user-dirs
hicolor-icon-theme
```

Contratos preservados:

- Base Directory;
- Desktop Entry;
- menus e categorias;
- temas e nomes de ícones;
- MIME e aplicações padrão;
- autostart;
- lixeira;
- diretórios do usuário.

Esses padrões permitem instalar qualquer shell ou aplicação posteriormente sem
recriar a infraestrutura.

## 6. DRM/KMS, libdrm e Mesa

```text
GPU
 ↓
driver DRM/KMS no kernel
 ↓
/dev/dri/card* e renderD*
 ↓
libdrm + Mesa
 ↓
Xorg ou Labwc/Wayland
```

DRM/KMS permanece no kernel. `libdrm` e Mesa voltam para a composição completa,
mas ficam no userspace. Mesa fornece OpenGL, Vulkan, EGL, GLX e fallback de
software conforme os pacotes selecionados.

Ferramentas de diagnóstico candidatas:

```text
modetest
drm_info
glxinfo
eglinfo
vulkaninfo
kmscube
```

Ferramentas invasivas ou grandes podem ficar em `playos-graphics-core-debug`.

## 7. libinput e libevdev

`libevdev` acessa eventos do kernel. `libinput` aplica interpretação de teclado,
mouse, touchpad, touchscreen e tablet para Xorg e Labwc.

Sem centros de configuração dos três desktops, defaults ficam em pacotes
upstream e configurações PlayOS pequenas. Uma futura CLI pode expor somente
opções comprovadamente portáveis entre X11 e Wayland.

```bash
libinput list-devices
libinput debug-events
```

O segundo comando captura atividade de entrada e pertence a diagnóstico
consciente.

## 8. Fontconfig, FreeType e HarfBuzz

Esses componentes voltam ao core porque qualquer interface gráfica precisa de
texto:

```text
texto → HarfBuzz → fontconfig → FreeType → X11/Wayland/Mesa → tela
```

O produto inclui fontes básicas legíveis, terminal, fallback Unicode, UTF-8 e
layout brasileiro. Não inclui coleções enormes ou fontes sem licença validada.

## 9. X.Org, XCB e Xft

X11 volta como servidor gráfico suportado sem desktop.

```text
LightDM ou console
 ↓
Xorg
 ↓
sessão X11 mínima de diagnóstico
 ↓
terminal/aplicação de teste
```

XCB fornece protocolo cliente e Xft integra fontes. Como GNOME, KDE e XFCE
estão ausentes, a sessão X11 mínima não pretende ser um desktop final.

### Sessão X11 mínima

Pode iniciar um terminal e ferramentas de teste por um launcher PlayOS. Um
gerenciador de janelas independente só será adicionado se selecionado como
componente próprio, sem trazer um dos três desktops.

Regras:

- não usar `xhost +`;
- não gerar `xorg.conf` global sem necessidade;
- manter autenticação X11 privada;
- terminar a sessão ao fechar o launcher principal;
- deixar claro no greeter que é sessão técnica.

## 10. Wayland, Xwayland e Labwc

Wayland, Xwayland e Labwc voltam ao core. Labwc é um compositor independente e
não exige XFCE.

```text
LightDM
 ↓
PlayOS Core Wayland
 ↓
Labwc
 ├── aplicações Wayland
 └── Xwayland → aplicações X11
```

Uma sessão mínima precisa de:

- Labwc;
- terminal Wayland leve selecionado;
- launcher/menu neutro opcional;
- agente polkit neutro;
- notification daemon neutro se houver aplicações que o exijam;
- portal GTK/wlr compatível, condicionado à matriz Noble;
- Xwayland para compatibilidade.

Ela é um ambiente gráfico básico, não GNOME, KDE ou XFCE.

## 11. LightDM sem XFCE

LightDM retorna como display manager neutro do Graphics Core. GDM e SDDM ficam
fora porque pertencem aos perfis removidos nesta composição.

Sessões propostas:

```text
PlayOS Core (Console)          # selecionada fora do greeter/por target
PlayOS Core X11 (Diagnostic)
PlayOS Core Wayland (Labwc)
```

LightDM autentica e inicia launchers PlayOS próprios. Não habilitar autologin
no sistema instalado. A Live ISO pode ter configuração de autologin isolada.

## 12. ALSA, PipeWire e WirePlumber

O áudio volta completo:

```text
hardware → ALSA → PipeWire → aplicação
                     ↑
                WirePlumber
```

- ALSA fornece drivers e API de baixo nível;
- PipeWire fornece grafo e compatibilidade de áudio;
- WirePlumber aplica política de sessão;
- `pipewire-pulse` atende aplicações PulseAudio;
- screen capture Wayland pode usar PipeWire/portal.

Os serviços executam como usuário e não dependem de desktop. Controle inicial:

```bash
wpctl status
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

## 13. Pacotes propostos

```text
linux-playos-graphics-meta
playos-graphics-services
playos-graphics-xdg
playos-graphics-runtime
playos-vulkan-runtime
playos-graphics-x11
playos-graphics-wayland
playos-graphics-login
playos-audio-stack
playos-graphics-tools
playos-graphics-core             # metapacote superior
playos-graphics-core-debug       # testes opcionais
```

### Relações

`playos-graphics-core` depende dos componentes funcionais. Ferramentas de debug
ficam em `Recommends` ou pacote separado. Nenhum metapacote depende de GNOME,
KDE Plasma, XFCE ou seus metapacotes Ubuntu derivados.

## 14. Pacotes candidatos Ubuntu/Debian

Os nomes abaixo precisam ser resolvidos contra a suite real:

```text
systemd systemd-sysv libpam-systemd
dbus dbus-user-session policykit-1
network-manager upower udisks2
desktop-file-utils shared-mime-info xdg-utils xdg-user-dirs hicolor-icon-theme
libdrm2 libgl1-mesa-dri mesa-vulkan-drivers
libvulkan1
libinput10 libinput-tools xserver-xorg-input-libinput
fontconfig fonts-dejavu-core fonts-noto-core
xserver-xorg xserver-xorg-core x11-xserver-utils libxcb1 libxft2
libwayland-client0 libwayland-server0 wayland-protocols xwayland labwc
lightdm lightdm-gtk-greeter
alsa-utils pipewire pipewire-audio pipewire-pulse wireplumber
```

Não adicionar `ubuntu-desktop`, `kubuntu-desktop`, `xubuntu-desktop`,
`gnome-shell`, `plasma-desktop` ou `xfce4`.

## 15. Inicialização

### Modo console

```text
UEFI → GRUB → kernel/initramfs → systemd → multi-user.target
```

### Modo X11 técnico

```text
systemd → LightDM → Xorg → launcher PlayOS → terminal/testes
```

### Modo Wayland básico

```text
systemd → LightDM → Labwc → terminal/menu/aplicações → Xwayland se necessário
```

O usuário pode instalar outro ambiente posteriormente sem trocar o kernel.

## 16. Live ISO Graphics Core

A ISO proposta contém:

- kernel PlayOS e initramfs;
- live-boot, SquashFS e OverlayFS;
- todos os serviços comuns;
- Mesa, input, fontes e áudio;
- Xorg e sessão técnica;
- Wayland/Labwc e Xwayland;
- LightDM;
- terminal e diagnóstico;
- nenhum GNOME, KDE Plasma ou XFCE.

Objetivos:

- provar toda a infraestrutura gráfica;
- servir como base para outras edições;
- permitir diagnóstico em hardware;
- medir o custo real do core sem desktops;
- evitar que falhas de desktop ocultem falhas da base.

## 17. Segurança

- somente um LightDM ativo;
- sessões executam como usuário comum;
- logind/udev controlam dispositivos;
- polkit não recebe regra universal;
- terminal da Live não implica senha administrativa vazia no instalado;
- X11 é marcado como sessão técnica com seus limites de isolamento;
- portal e PipeWire mediam captura Wayland quando suportado;
- nenhuma permissão `777`, `xhost +` ou daemon de sessão como root;
- pacotes de desktop removidos não deixam agentes/autostarts órfãos.

## 18. Diagnóstico unificado

```text
playos-graphicsctl status
playos-graphicsctl kernel
playos-graphicsctl services
playos-graphicsctl drm
playos-graphicsctl input
playos-graphicsctl fonts
playos-graphicsctl x11
playos-graphicsctl wayland
playos-graphicsctl audio
playos-graphicsctl report --json
```

O relatório confirma explicitamente:

```text
desktop_environment=none
display_manager=lightdm
x11=available
wayland=available
wayland_compositor=labwc
xwayland=available
audio_server=pipewire
session_manager=wireplumber
```

## 19. Gates

| Gate | Evidência | Estado |
|---|---|---|
| GC0 | arquitetura completa sem desktops | presente |
| GC1 | pacotes e versões Noble resolvidos | pendente |
| GC2 | metapacotes compilados | pendente |
| GC3 | boot até console | pendente |
| GC4 | serviços D-Bus/polkit/rede/energia/discos | pendente |
| GC5 | DRM/Mesa/input/fontes | pendente |
| GC6 | LightDM e sessão X11 técnica | pendente |
| GC7 | Labwc/Wayland e Xwayland | pendente |
| GC8 | PipeWire/WirePlumber | pendente |
| GC9 | Live ISO construída e inicializada | pendente |
| GC10 | upgrade, remoção e rollback | pendente |
| GC11 | hardware representativo | pendente |

## 20. Critérios de aceitação

O Graphics Core estará pronto quando:

- iniciar em console sem desktop;
- iniciar LightDM sem puxar GNOME/KDE/XFCE;
- abrir sessão X11 técnica;
- abrir sessão Labwc/Wayland e aplicações X11 por Xwayland;
- oferecer aceleração Mesa ou identificar fallback;
- operar input, fontes, rede, energia, discos e áudio;
- produzir uma ISO reproduzível;
- permitir instalar qualquer desktop posteriormente;
- passar pelos testes de segurança e hardware.

Até esses gates, o estado correto é **composição restaurada e documentada,
ainda não implementada**.

## Documentos relacionados

- `KERNEL_GRAFICO_PLAYOS_SEM_DESKTOPS.md`;
- `MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md`;
- `PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `INICIALIZACAO_PLAYOS_GRAPHICS_PLATFORM.md`.
- `VULKAN_NO_PLAYOS_GRAPHICS_CORE.md`.
