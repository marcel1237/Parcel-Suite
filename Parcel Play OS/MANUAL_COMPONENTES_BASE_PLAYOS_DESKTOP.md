# Manual dos componentes-base do desktop PlayOS

## Estado e escopo

- **Classificação:** `architecture`, `manual` e `proposal`.
- **Data:** 2026-08-26.
- **Base pretendida:** Ubuntu Noble com kernel PlayOS.
- **Desktops:** XFCE, GNOME e KDE Plasma, com sessões X11 e Wayland conforme o
  suporte de cada ambiente.
- **Implementação:** os metapacotes descritos ainda não foram produzidos.
- **Validação:** nomes e versões exatos dos pacotes ainda precisam ser resolvidos
  no repositório APT usado pelo build.

> **Fronteira do kernel:** XFCE, GNOME e KDE Plasma foram retirados do conceito
> de kernel gráfico. Este manual descreve serviços e userspace que podem ser
> instalados sobre ele. O kernel independente está especificado em
> `KERNEL_GRAFICO_PLAYOS_SEM_DESKTOPS.md`.

> **Graphics Core vigente:** todos os componentes comuns deste manual voltam à
> composição instalável, exceto GNOME, KDE Plasma e XFCE. Consulte
> `PLAYOS_GRAPHICS_CORE_COMPLETO_SEM_DESKTOPS.md`.

> **Vulkan:** o Graphics Core inclui loader e drivers Vulkan userspace sobre
> DRM/Mesa, com WSI X11 e Wayland. Consulte
> `VULKAN_NO_PLAYOS_GRAPHICS_CORE.md`.

Este manual documenta o uso no PlayOS de:

```text
systemd/logind + D-Bus + polkit
NetworkManager + UPower + udisks2
utilitários e padrões XDG
DRM/KMS + Mesa
libinput + libevdev
fontconfig + FreeType + HarfBuzz
X.Org + XCB + Xft
Wayland + Xwayland + Labwc
LightDM/GDM/SDDM + XFCE/GNOME/KDE Plasma
ALSA + PipeWire + WirePlumber
```

Os nomes de pacotes apresentados são **candidatos Ubuntu/Debian**, não evidência
de que já estejam instalados na imagem PlayOS.

> **Ampliação multi-desktop:** este manual detalha a base comum e originalmente
> aprofundou XFCE. GNOME, Mutter, GDM, KDE Plasma, KWin, SDDM, seus portals e a
> convivência entre os três desktops estão especificados em
> `ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md`. XFCE não é mais o único
> desktop planejado.

### Desktops acrescentados à composição

| Desktop | Sessão X11 | Sessão Wayland | Compositor | Display manager preferencial |
|---|---|---|---|---|
| XFCE | XFCE + `xfwm4` | XFCE experimental + Labwc | `xfwm4` ou Labwc | LightDM |
| GNOME | GNOME Shell + Mutter/X11 | GNOME Shell + Mutter/Wayland | Mutter | GDM |
| KDE Plasma | Plasma + KWin/X11 | Plasma + KWin/Wayland | KWin | SDDM |

Xorg, Wayland, Xwayland, DRM/Mesa, input, fontes, áudio e serviços são
compartilhados. Somente o desktop escolhido e seus serviços de sessão são
iniciados no login.

## 1. Como todas as partes se conectam

```text
kernel PlayOS
├── DRM/KMS ── Mesa ── X.Org ou Labwc/Wayland ── XFCE/aplicações
├── evdev ── libevdev ── libinput ── X.Org ou Labwc
├── ALSA ── PipeWire ── WirePlumber ── aplicações
└── dispositivos ── udev/logind ── sessão do usuário

systemd/logind ── serviços, seats, sessões e energia
D-Bus ─────────── comunicação entre serviços e aplicações
polkit ────────── autorização para operações privilegiadas
NetworkManager ─ rede
UPower ────────── bateria e energia
udisks2 ───────── armazenamento removível
XDG ───────────── arquivos, menus, MIME, autostart e diretórios
LightDM ───────── autenticação e escolha da sessão
```

O kernel fornece mecanismos. Serviços de sistema controlam recursos. O display
manager cria uma sessão autenticada. Xorg ou Labwc apresenta janelas. XFCE
oferece o desktop. PipeWire entrega áudio e mídia. D-Bus conecta as camadas e
polkit decide se uma ação privilegiada pode prosseguir.

## 2. systemd e logind

### Função no PlayOS

`systemd` será o PID 1 do sistema Noble. Ele monta sistemas de arquivos,
inicializa serviços, registra eventos no journal e conduz o boot até
`graphical.target`.

`systemd-logind` registra usuários, sessões e seats. Um seat associa uma sessão
local a monitor, GPU, teclado e mouse. LightDM registra a sessão; Xorg ou Labwc
obtém acesso controlado aos dispositivos correspondentes.

### Pacotes candidatos

```text
systemd
systemd-sysv
libpam-systemd
```

### Serviços e interfaces

```text
systemd-logind.service
graphical.target
multi-user.target
display-manager.service
org.freedesktop.login1 (D-Bus)
```

### Regras PlayOS

- usar `graphical.target` no desktop e preservar `multi-user.target` para
  recuperação;
- não criar outro gerenciador de sessão concorrente;
- não substituir logind por ConsoleKit;
- serviços do usuário devem ficar em `systemd --user` quando apropriado;
- o diagnóstico PlayOS não pode bloquear o boot gráfico;
- suspensão e energia devem passar pelas interfaces mantidas de logind/UPower.

### Diagnóstico

```bash
systemctl get-default
systemctl --failed
systemctl status systemd-logind
loginctl list-seats
loginctl list-sessions
loginctl session-status
journalctl -b -u systemd-logind
```

### Aceitação

- PID 1 ativo e sem unidades críticas falhas;
- `seat0` e sessão gráfica corretamente identificados;
- sessão marcada como `x11` ou `wayland` conforme a escolha;
- logout encerra processos da sessão sem derrubar o sistema.

## 3. D-Bus

### Função no PlayOS

D-Bus é a malha de comunicação. O barramento de sistema conecta serviços
privilegiados e o barramento de sessão conecta aplicações do usuário.

Exemplos:

```text
XFCE/app → D-Bus → NetworkManager
XFCE/app → D-Bus → UPower
Thunar/GVfs → D-Bus → udisks2
aplicação → D-Bus → portal/notificações
```

### Pacotes candidatos

```text
dbus
dbus-user-session
```

### Regras PlayOS

- usar ativação D-Bus/systemd, não scripts que iniciam múltiplos daemons;
- separar políticas do system bus das permissões do session bus;
- não permitir métodos privilegiados apenas porque o chamador está no desktop;
- APIs PlayOS futuras devem usar nomes como `org.playos.*`, sem ocupar nomes
  `org.freedesktop.*` que não implementem contratos oficiais.

### Diagnóstico

```bash
busctl list
busctl --user list
busctl status org.freedesktop.NetworkManager
```

`dbus-monitor` e Bustle pertencem à imagem de diagnóstico, pois podem revelar
metadados de atividades e produzir muito log.

## 4. polkit

### Função no PlayOS

Polkit avalia pedidos de aplicações sem privilégio para serviços privilegiados.
Ele não substitui autenticação PAM, `sudo`, permissões Unix ou políticas D-Bus.

Exemplos: montar uma unidade, alterar rede do sistema, definir energia ou
administrar impressora. Um agente gráfico apresenta o diálogo de autenticação.

### Pacotes candidatos

```text
policykit-1
agente polkit compatível com XFCE
```

O agente exato deve ser selecionado no repositório Noble e iniciado uma única
vez pela sessão XFCE.

### Regras PlayOS

- regras administrativas ficam em `/etc/polkit-1/rules.d/`;
- pacotes fornecem defaults em local próprio, sem sobrescrever regras do
  administrador;
- não criar regra `YES` ampla para todos os usuários locais;
- acesso físico, sessão ativa e grupo administrativo não são equivalentes;
- Live ISO pode ter política específica, documentada e removida da instalação.

### Testes

- usuário comum recebe negação ou autenticação conforme a ação;
- cancelamento não executa a operação;
- sessão remota/inativa não herda autorização local;
- ausência do agente falha de forma segura, sem congelar o desktop.

## 5. NetworkManager

### Função no PlayOS

Gerencia Ethernet, Wi-Fi, VPN e estado de conectividade. O applet do painel
XFCE atua como cliente; NetworkManager continua sendo a autoridade.

### Pacotes candidatos

```text
network-manager
network-manager-gnome
```

Plugins VPN entram por perfil. ModemManager entra no perfil de banda larga
móvel.

### Regras PlayOS

- não ativar simultaneamente outro gerenciador para a mesma interface;
- definir quem administra interfaces em `/etc/NetworkManager/`;
- conexões com segredo seguem permissões e armazenamento apropriados;
- conectividade da Live não deve modificar permanentemente o host;
- DNS precisa de uma única integração coerente com o sistema Noble.

### Diagnóstico

```bash
systemctl status NetworkManager
nmcli general status
nmcli device status
nmcli connection show
journalctl -b -u NetworkManager
```

### Aceitação

Ethernet e Wi-Fi conectam, reconectam, alternam redes, respeitam modo offline e
continuam operacionais nas duas sessões gráficas.

## 6. UPower

### Função no PlayOS

Publica bateria, alimentação, carga e estado energético pelo D-Bus. O plugin de
energia do XFCE consome esses dados.

### Pacote candidato

```text
upower
```

### Regras e testes

- não duplicar políticas de suspensão entre XFCE, UPower e logind;
- definir claramente quem reage ao fechamento da tampa e bateria crítica;
- desktop sem bateria deve funcionar sem alertas falsos;
- notebook deve exibir fonte, percentual e transições de carga.

```bash
systemctl status upower
upower -e
upower -d
```

## 7. udisks2

### Função no PlayOS

Oferece operações de armazenamento pelo D-Bus. Thunar/GVfs pode solicitar
montagem e desmontagem de USB sem executar lógica de disco como root.

### Pacotes candidatos

```text
udisks2
gvfs
gvfs-backends
```

### Regras PlayOS

- polkit controla operações privilegiadas;
- não montar automaticamente mídia executável com permissões perigosas;
- “remover com segurança” deve sincronizar e desmontar;
- não confundir udisks2 com o mecanismo que monta a raiz no boot;
- ferramentas destrutivas de particionamento não pertencem ao clique padrão.

### Diagnóstico

```bash
systemctl status udisks2
udisksctl status
udisksctl dump
lsblk -f
```

## 8. Utilitários e padrões XDG

### Componentes essenciais

```text
desktop-file-utils
shared-mime-info
xdg-utils
xdg-user-dirs
hicolor-icon-theme
```

### Contratos usados

| Contrato | Uso PlayOS |
|---|---|
| Base Directory | separa configuração, dados, cache e estado do usuário |
| Desktop Entry | descreve aplicações e sessões `.desktop` |
| Menu | organiza aplicações no menu XFCE |
| Icon Theme | temas e fallback `hicolor` |
| Shared MIME | identifica tipos de arquivos |
| MIME Apps | escolhe aplicativos padrão |
| Autostart | inicia componentes após login |
| Trash | lixeira interoperável |
| User Dirs | Desktop, Documents, Downloads etc. |

### Regras PlayOS

- defaults globais em `/etc/xdg` ou `/usr/share`, preferências em `~/.config`;
- nunca escrever arquivos pessoais durante o build da ISO;
- validar todo `.desktop` criado pelo PlayOS;
- executar apenas comandos previstos pelo campo `Exec`;
- não usar autostart para corrigir dependência que deveria ser serviço;
- respeitar associações definidas pelo usuário.

### Diagnóstico

```bash
echo "$XDG_CONFIG_HOME"
echo "$XDG_DATA_DIRS"
xdg-user-dir DESKTOP
xdg-mime query default text/plain
desktop-file-validate /usr/share/applications/arquivo.desktop
update-mime-database /usr/share/mime
```

O último comando é de instalação/administração, não deve ser executado a cada
login.

## 9. DRM/KMS e Mesa

### DRM/KMS no kernel

DRM gerencia GPUs e render nodes. KMS controla modos, conectores, resoluções e
scanout. São partes do kernel PlayOS, não pacotes gráficos comuns.

Requisitos:

- drivers Intel, AMD, nouveau e GPUs virtuais conforme perfis;
- firmware compatível;
- `/dev/dri/card*` e `/dev/dri/renderD*` com permissões da sessão;
- framebuffer/console de recuperação;
- dma-buf e sincronização exigidos pela pilha.

### Mesa no userspace

Mesa implementa APIs como OpenGL, Vulkan, EGL e GLX e seleciona o driver
userspace compatível com o driver DRM.

Pacotes candidatos:

```text
libdrm2
libgl1-mesa-dri
mesa-vulkan-drivers
mesa-utils
```

`mesa-utils` pode ficar no standard/diagnóstico. Drivers e loaders exatos serão
resolvidos por arquitetura e GPU.

### Fluxos

```text
aplicação OpenGL → Mesa/GLX → Xorg → DRM → GPU
aplicação EGL/Vulkan → Mesa → Labwc/Wayland → DRM → GPU
```

### Diagnóstico

```bash
ls -l /dev/dri
lspci -nnk | grep -A3 -E 'VGA|3D|Display'
cat /sys/class/drm/card*/device/uevent
glxinfo -B
eglinfo
vulkaninfo --summary
journalctl -b -k | grep -iE 'drm|gpu|firmware'
```

`llvmpipe` é fallback de software, não prova de aceleração. Cada GPU precisa de
teste real nas sessões X11 e Wayland.

## 10. libevdev e libinput

### Função

O kernel publica eventos por evdev. `libevdev` fornece acesso de baixo nível.
`libinput` interpreta teclado, mouse, touchpad, touchscreen e tablet e fornece
comportamento coerente a Xorg e ao compositor Wayland.

Pacotes candidatos:

```text
libinput10
libinput-tools
xserver-xorg-input-libinput
```

Bibliotecas exatas são transitivas; ferramentas podem ficar no diagnóstico.

### Regras PlayOS

- não abrir dispositivos diretamente em aplicações comuns;
- usar a mesma política básica de touchpad nas duas sessões;
- configurações Xorg não são automaticamente configuração Wayland;
- quirks específicos de hardware precisam de identificação e teste;
- acessibilidade de teclado não pode ser quebrada por defaults agressivos.

### Diagnóstico

```bash
libinput list-devices
libinput debug-events
grep -E 'Handlers|Name' /proc/bus/input/devices
```

`debug-events` exige cuidado: captura atividade de dispositivos de entrada e
deve ser usado somente durante diagnóstico consciente.

## 11. fontconfig, FreeType e HarfBuzz

### Funções

- **fontconfig:** descobre fontes e escolhe famílias/substituições;
- **FreeType:** rasteriza glifos;
- **HarfBuzz:** aplica shaping, ligaduras e regras de escrita complexa.

Fluxo:

```text
texto da aplicação
 → HarfBuzz organiza glifos
 → fontconfig escolhe a fonte
 → FreeType rasteriza
 → toolkit/Mesa/X11/Wayland exibe
```

Pacotes candidatos incluem bibliotecas transitivas e famílias como
`fonts-dejavu-core` e `fonts-noto-core`. A seleção final deve medir tamanho,
cobertura linguística e licença.

### Regras PlayOS

- UTF-8 como padrão;
- fontes legíveis para interface, terminal e fallback Unicode;
- não empacotar fontes sem licença verificável;
- manter cache fontconfig reproduzível, sem cache de usuário na imagem;
- testar português, acentos, emoji e escrita bidirecional do perfil standard.

### Diagnóstico

```bash
fc-list | head
fc-match sans-serif
fc-match monospace
fc-cache -v
```

## 12. X.Org, XCB e Xft

### Papel no PlayOS

X.Org é o servidor da sessão estável. XCB é biblioteca de protocolo X11. Xft
renderiza fontes em clientes X11 com fontconfig/FreeType.

Pacotes candidatos:

```text
xserver-xorg
xserver-xorg-core
xserver-xorg-input-libinput
x11-xserver-utils
libxcb1
libxft2
```

As bibliotecas devem chegar pelas dependências corretas; o metapacote declara
somente o que constitui o contrato da sessão.

### Inicialização

```text
LightDM → Xorg → startxfce4 → xfce4-session → xfwm4
```

### Regras PlayOS

- preferir configuração automática por DRM/libinput;
- arquivos em `/etc/X11/xorg.conf.d/` somente para correções comprovadas;
- não gerar `xorg.conf` global por padrão;
- manter X11 como fallback durante maturação Wayland;
- autenticação e cookies X11 devem permanecer privados à sessão;
- não executar `xhost +`.

### Diagnóstico

```bash
echo "$XDG_SESSION_TYPE"
echo "$DISPLAY"
xrandr --query
xdpyinfo | head
xinput list
journalctl -b _COMM=Xorg
```

## 13. Wayland, Xwayland e Labwc

### Funções

- **Wayland:** protocolo entre clientes e compositor;
- **Labwc:** compositor e gerenciador de janelas da sessão PlayOS Wayland;
- **Xwayland:** servidor X compatível executado dentro da sessão Wayland.

Labwc acessa DRM/KMS e libinput. Aplicações Wayland falam com Labwc. Aplicações
X11 falam com Xwayland, que apresenta suas superfícies ao compositor.

```text
app Wayland ───────────────→ Labwc → DRM/KMS
app X11 → Xwayland ────────→ Labwc → DRM/KMS
teclado/mouse → libinput ──→ Labwc
```

Pacotes candidatos:

```text
libwayland-client0
libwayland-server0
wayland-protocols
xwayland
labwc
xdg-desktop-portal
xdg-desktop-portal-gtk
```

Os nomes e a disponibilidade de Labwc no repositório usado precisam ser
confirmados. `wlroots` deve chegar como dependência do compositor compatível.

### Regras PlayOS

- Labwc substitui `xfwm4` nessa sessão;
- `XDG_SESSION_TYPE=wayland` e `WAYLAND_DISPLAY` devem refletir a sessão real;
- Xwayland oferece compatibilidade, não deve ser o caminho de apps nativas;
- screen sharing e seletores de arquivo usam portals quando aplicável;
- a sessão é experimental até concluir os gates de XFCE e aplicações;
- falha Wayland retorna ao LightDM sem remover X11.

### Diagnóstico

```bash
echo "$XDG_SESSION_TYPE"
echo "$WAYLAND_DISPLAY"
echo "$DISPLAY"
loginctl show-session "$XDG_SESSION_ID" -p Type -p Desktop
pgrep -a 'labwc|Xwayland'
journalctl --user -b
```

## 14. LightDM e XFCE

### LightDM

Autentica o usuário, oferece sessões e cria o ambiente de login. Pacotes
candidatos:

```text
lightdm
lightdm-gtk-greeter
```

Arquivos PlayOS:

```text
/usr/share/xsessions/playos-xfce-x11.desktop
/usr/share/wayland-sessions/playos-xfce-wayland.desktop
```

Não habilitar autologin por padrão. Configuração Live, se necessária, deve ser
isolada da instalação final.

### XFCE

Componentes esperados:

- `xfce4-session` para ciclo da sessão;
- `xfce4-panel` para painel;
- `xfdesktop4` para desktop;
- `xfce4-settings` para preferências;
- `xfwm4` somente na sessão X11;
- Thunar e GVfs para arquivos e dispositivos;
- plugin de energia, rede e notificações conforme o perfil.

O metapacote pode depender de `xfce4` e selecionar explicitamente componentes
para uma edição lean. `xfce4-goodies` é recomendado, não requisito cego.

### Diagnóstico

```bash
systemctl status display-manager
lightdm --show-config
ls -l /usr/share/xsessions /usr/share/wayland-sessions
pgrep -a 'xfce4-session|xfwm4|xfce4-panel|xfdesktop|labwc'
journalctl -b -u display-manager
```

### Aceitação

- greeter aparece e autentica;
- X11 inicia XFCE com `xfwm4`;
- Wayland inicia Labwc sem `xfwm4` concorrente;
- logout retorna ao greeter;
- troca de usuário, bloqueio e encerramento respeitam logind/polkit.

## 15. ALSA, PipeWire e WirePlumber

### Funções

- **ALSA:** drivers no kernel e API/dispositivos de áudio de baixo nível;
- **PipeWire:** grafo de áudio/vídeo e servidor de mídia da sessão;
- **WirePlumber:** política e gerenciamento dos dispositivos/nós PipeWire.

```text
hardware → driver ALSA → PipeWire → aplicação
                         ↑
                    WirePlumber
```

Pacotes candidatos:

```text
alsa-utils
pipewire
pipewire-audio
pipewire-pulse
wireplumber
libspa-0.2-bluetooth
```

Bluetooth é perfil/recomendação e depende também da pilha BlueZ. Os nomes
exatos precisam ser resolvidos em Noble.

### Execução

PipeWire e WirePlumber são serviços de usuário, preferencialmente ativados por
socket/systemd. Não se deve iniciar uma instância manual no autostart do XFCE.
`pipewire-pulse` fornece compatibilidade para aplicações PulseAudio; não exige
um servidor PulseAudio concorrente.

### Regras PlayOS

- um único gerenciador de sessão PipeWire: WirePlumber;
- não executar PipeWire do desktop como root;
- ALSA permanece disponível como base, mas acesso direto exclusivo não pode
  bloquear o servidor da sessão;
- volumes e dispositivos padrão pertencem à política de sessão;
- captura de tela/áudio e portals exigem consentimento apropriado;
- codecs Bluetooth e multimídia dependem de suporte e licenças da edição.

### Diagnóstico

```bash
aplay -l
arecord -l
systemctl --user status pipewire pipewire-pulse wireplumber
wpctl status
wpctl inspect @DEFAULT_AUDIO_SINK@
pw-cli info all
journalctl --user -b -u pipewire -u wireplumber
```

### Aceitação

- saída e entrada detectadas;
- volume, mute e troca de dispositivo funcionam;
- aplicações PulseAudio funcionam pela compatibilidade;
- áudio persiste ao trocar entre X11 e Wayland;
- suspensão/reconexão não deixa dispositivos duplicados;
- Bluetooth, HDMI e microfone são testados nos perfis correspondentes.

## 16. Divisão entre pacotes PlayOS

| Metapacote | Responsabilidade |
|---|---|
| `playos-system-session` | systemd/logind, D-Bus, polkit e integração PAM |
| `playos-desktop-services` | NetworkManager, UPower, udisks2 e agentes/applets |
| `playos-xdg-integration` | XDG, MIME, menus, ícones e defaults |
| `playos-graphics-runtime` | Mesa, libinput, fontes e contratos comuns |
| `playos-display-x11` | X.Org e suporte da sessão X11 |
| `playos-display-wayland` | Wayland, Xwayland, Labwc e portals |
| `playos-desktop-xfce` | LightDM, XFCE, sessões e identidade |
| `playos-audio-stack` | ALSA userspace, PipeWire e WirePlumber |
| `playos-graphics-platform` | entrada única que depende de todos os anteriores |

Bibliotecas transitivas não precisam virar metapacotes próprios. Essa divisão
serve a propriedade, teste e rollback, mantendo uma instalação pública única.

## 17. Ordem de inicialização

```text
1. kernel: DRM, evdev, ALSA e dispositivos
2. systemd/udev: descobre hardware e inicia serviços
3. D-Bus: disponibiliza barramentos
4. logind: registra seat e sessões
5. NetworkManager, UPower, udisks2 e polkit
6. LightDM: greeter e autenticação
7. Xorg ou Labwc: sessão gráfica
8. XFCE: desktop e aplicações
9. PipeWire/WirePlumber: mídia da sessão do usuário
```

Ativação por socket/D-Bus pode fazer alguns serviços nascerem sob demanda. A
ordem representa dependências lógicas, não uma sequência obrigatoriamente
serial.

## 18. Uso na Live ISO

A raiz SquashFS deve conter o metapacote `playos-graphics-platform`. No boot:

- systemd inicia serviços do sistema na raiz overlay;
- LightDM pode usar autologin somente no perfil Live;
- NetworkManager não leva segredos para a instalação;
- polkit Live tem regras mínimas e separadas;
- PipeWire/WirePlumber nascem na sessão do usuário Live;
- hardware é detectado a cada boot;
- logs ficam no overlay efêmero, salvo mecanismo explícito de coleta.

A configuração instalada não deve herdar automaticamente autologin, senhas,
conexões, regras permissivas ou identidade do usuário Live.

## 19. Segurança integrada

- kernel controla dispositivos; logind concede acesso conforme sessão ativa;
- D-Bus define interfaces e políticas; polkit decide autorizações de alto nível;
- display manager autentica por PAM;
- X11 permanece menos isolado entre clientes da mesma sessão;
- Wayland reduz acesso global por desenho, mas Xwayland mantém compatibilidade
  e parte dos riscos X11;
- PipeWire/portals devem mediar captura quando suportado;
- dispositivos de entrada, áudio e render nodes não recebem permissões globais;
- nenhuma correção deve usar `chmod 777`, `xhost +` ou regra polkit universal.

## 20. Diagnóstico PlayOS unificado

`playos-graphicsctl diagnose` deve reunir, sem modificar o sistema:

```text
BOOT      systemd/logind/seat/session
IPC       system bus e session bus
AUTH      polkit e agente
NETWORK   NetworkManager
POWER     UPower
STORAGE   udisks2/GVfs
XDG       directories, MIME, desktop entries
GPU       DRM/KMS, driver, Mesa renderer
INPUT     evdev/libinput
FONTS     fontconfig e fallbacks
DISPLAY   Xorg ou Labwc/Wayland/Xwayland
DESKTOP   LightDM e XFCE
AUDIO     ALSA, PipeWire e WirePlumber
```

Cada camada retorna `PASS`, `WARN`, `FAIL` ou `NOT-APPLICABLE`, inclui a fonte
da evidência e evita capturar segredos.

## 21. Gates conjuntos

| Gate | Teste | Estado |
|---|---|---|
| C0 | pacotes e versões Noble resolvidos | pendente |
| C1 | instalação APT limpa | pendente |
| C2 | boot até console e sessão logind | pendente |
| C3 | rede, energia e armazenamento | pendente |
| C4 | DRM/Mesa acelerado ou fallback identificado | pendente |
| C5 | teclado, mouse, touchpad e fontes | pendente |
| C6 | LightDM + XFCE/X11 | pendente |
| C7 | LightDM + XFCE/Labwc/Wayland + Xwayland | pendente |
| C8 | ALSA/PipeWire/WirePlumber | pendente |
| C9 | polkit e segurança negativa | pendente |
| C10 | Live ISO e instalação sem vazamento de configuração | pendente |
| C11 | upgrade e rollback | pendente |
| C12 | hardware representativo | pendente |

## 22. Critério de produto pronto

O conjunto estará integrado quando o metapacote puder ser instalado e removido
sem quebrar APT; bootar até LightDM; abrir XFCE/X11; abrir a sessão Wayland
experimental; fornecer rede, mídia removível, entrada, fontes e áudio; aplicar
autorizações corretamente; e recuperar-se por console/X11/kernel anterior.

Até a execução desses testes, o conteúdo deste manual continua sendo
**especificação de uso**, não resultado de runtime.

## Fontes primárias

- freedesktop.org Software: <https://www.freedesktop.org/wiki/Software/>
- freedesktop.org Specifications: <https://www.freedesktop.org/wiki/Specifications/>
- systemd: <https://systemd.io/>
- D-Bus: <https://www.freedesktop.org/wiki/Software/dbus/>
- polkit: <https://polkit.pages.freedesktop.org/polkit/>
- NetworkManager: <https://networkmanager.dev/docs/>
- UPower: <https://upower.freedesktop.org/>
- udisks: <https://www.freedesktop.org/wiki/Software/udisks/>
- Mesa: <https://docs.mesa3d.org/>
- libinput: <https://wayland.freedesktop.org/libinput/doc/latest/>
- fontconfig: <https://www.freedesktop.org/wiki/Software/fontconfig/>
- FreeType: <https://freetype.org/freetype2/docs/>
- HarfBuzz: <https://harfbuzz.github.io/>
- X.Org: <https://www.x.org/wiki/>
- Wayland: <https://wayland.freedesktop.org/>
- Labwc: <https://labwc.github.io/>
- LightDM: <https://github.com/canonical/lightdm>
- XFCE: <https://docs.xfce.org/>
- ALSA: <https://www.alsa-project.org/wiki/Main_Page>
- PipeWire: <https://docs.pipewire.org/>
- WirePlumber: <https://pipewire.pages.freedesktop.org/wireplumber/>

## Documentos relacionados

- `ANALISE_SOFTWARE_FREEDESKTOP_PLAYOS_GRAPHICS_PLATFORM_2026-08-26.md`;
- `PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `INICIALIZACAO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `MANUAL_PLAYOS_GRAPHICS_KERNEL_STACK_X11_WAYLAND.md`.
