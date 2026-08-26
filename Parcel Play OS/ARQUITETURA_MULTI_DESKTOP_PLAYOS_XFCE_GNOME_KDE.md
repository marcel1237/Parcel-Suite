# Arquitetura multi-desktop do PlayOS: XFCE, GNOME e KDE Plasma

## Estado

- **Classificação:** `decision`, `architecture` e `proposal`.
- **Data:** 2026-08-26.
- **Decisão:** PlayOS não será limitado ao XFCE.
- **Desktops previstos:** XFCE, GNOME e KDE Plasma.
- **Implementação e runtime:** ainda não realizados por este documento.

Este documento amplia o PlayOS Graphics Platform. A base de kernel, serviços,
gráficos, entrada, fontes, áudio e padrões XDG será compartilhada. Cada desktop
terá pacote, sessão, compositor, portal e integração próprios.

## 1. Visão do produto

```text
PlayOS Graphics Platform
├── base compartilhada
│   ├── kernel PlayOS + systemd/logind
│   ├── D-Bus + polkit
│   ├── NetworkManager + UPower + udisks2
│   ├── XDG + fontes + input
│   ├── DRM/KMS + Mesa
│   ├── X.Org + Wayland + Xwayland
│   └── ALSA + PipeWire + WirePlumber
├── PlayOS XFCE
│   ├── XFCE/X11 + xfwm4
│   └── XFCE/Wayland Lab + Labwc
├── PlayOS GNOME
│   ├── GNOME/X11 + Mutter
│   └── GNOME/Wayland + Mutter
└── PlayOS KDE Plasma
    ├── Plasma/X11 + KWin
    └── Plasma/Wayland + KWin
```

O usuário escolhe o desktop e a sessão na tela de login. Todos usam o mesmo
kernel, drivers, rede, dispositivos, áudio e arquivos pessoais, mas não devem
executar simultaneamente seus compositores e agentes de sessão.

## 2. O que é compartilhado

| Camada | Compartilhada pelos três desktops |
|---|---|
| boot | UEFI, GRUB, kernel PlayOS, initramfs e systemd |
| sessão | logind, PAM e D-Bus |
| autorização | polkit, com um agente por sessão |
| hardware | udev, DRM/KMS, evdev e ALSA |
| gráficos | Mesa, Vulkan/OpenGL, libdrm e firmware |
| entrada | libevdev, libinput e xkeyboard-config |
| texto | fontconfig, FreeType, HarfBuzz e fontes |
| rede | NetworkManager |
| energia | UPower e logind |
| discos | udisks2 e integrações de gerenciador de arquivos |
| áudio | PipeWire, WirePlumber e compatibilidade PulseAudio |
| aplicações | XDG, MIME, desktop entries, ícones e portals |
| compatibilidade | X.Org para sessões X11 e Xwayland nas Wayland |

Compartilhar a base evita três sistemas duplicados. Desktops podem instalar
bibliotecas GTK, Qt e KDE Frameworks em paralelo; o custo é espaço de disco e
mais atualizações, não incompatibilidade automática.

## 3. XFCE no PlayOS

### Papel

XFCE oferece sessão leve, recuperação gráfica e boa compatibilidade X11. A
sessão Wayland permanece laboratório enquanto seus componentes e o compositor
externo não passarem pelos testes.

### Composição candidata

```text
xfce4
xfce4-goodies                 # recomendado, não núcleo cego
thunar
gvfs + gvfs-backends
xfce4-session
xfce4-panel
xfdesktop4
xfce4-settings
xfwm4                         # somente X11
labwc                         # sessão Wayland experimental
xdg-desktop-portal-gtk        # candidato de portal
```

### Sessões

```text
XFCE/X11:    display manager → Xorg → startxfce4 → xfwm4
XFCE/Wayland: display manager → Labwc → componentes XFCE compatíveis
```

Xwayland fica disponível na sessão Labwc para aplicações X11. `xfwm4` não pode
concorrer com Labwc.

### Pontos de teste

- painel, desktop, Thunar, atalhos e configurações;
- energia, rede, montagem USB e notificações;
- persistência separada entre X11 e Wayland;
- comportamento de componentes XFCE ainda dependentes de X11;
- logout sem loop e retorno ao display manager.

## 4. GNOME no PlayOS

### Papel

GNOME fornece um desktop integrado, com Wayland como caminho moderno e sessão
X11 como compatibilidade quando disponível. GNOME Shell e Mutter formam a
experiência gráfica; Mutter é o compositor/gerenciador de janelas.

### Composição candidata

```text
gnome-shell
gnome-session
gnome-control-center
gnome-settings-daemon
nautilus
gdm3                            # display manager recomendado para perfil GNOME
xdg-desktop-portal-gnome
xdg-desktop-portal-gtk          # fallback quando requerido
```

Metapacotes Ubuntu como `ubuntu-desktop-minimal` podem simplificar a seleção,
mas também acrescentar branding e aplicações Ubuntu. O PlayOS deve comparar a
dependência explícita com o metapacote antes de adotá-lo.

### Sessões

```text
GNOME/X11:    GDM/display manager → Xorg → GNOME Shell/Mutter
GNOME/Wayland: GDM/display manager → Mutter/Wayland → GNOME Shell
```

Mutter ocupa o papel que Labwc exerce no XFCE Wayland e que KWin exerce no
Plasma. Labwc não participa da sessão GNOME.

### Integrações GNOME

- `gnome-settings-daemon` consome energia, input e configurações;
- GNOME Shell apresenta rede, áudio, sessão e notificações;
- Nautilus usa GVfs/udisks2;
- GNOME Software, se incluído, usa AppStream e backend escolhido;
- portal GNOME atende screenshots, screencast, seletores e integração sandbox;
- extensões GNOME ficam fora do núcleo até validação por versão.

### Riscos e testes

- GNOME e suas aplicações aumentam ISO e RAM;
- GDM possui integração mais natural com GNOME/Wayland, mas não pode ficar
  ativo junto de LightDM ou SDDM;
- extensões podem quebrar em atualização do Shell;
- conferir aceleração Mutter, screen sharing PipeWire e portal correto;
- testar login, lock screen, troca de usuário, suspensão e logout.

## 5. KDE Plasma no PlayOS

### Papel

KDE Plasma oferece desktop Qt/KDE altamente configurável. KWin é compositor e
gerenciador de janelas tanto em X11 quanto Wayland.

### Composição candidata

```text
plasma-desktop
plasma-workspace
kwin-x11
kwin-wayland
systemsettings
dolphin
sddm                            # display manager recomendado para perfil Plasma
xdg-desktop-portal-kde
```

Metapacotes como `kubuntu-desktop` podem trazer uma experiência ampla, branding
Kubuntu e aplicações adicionais. Devem ser comparados com uma composição
PlayOS explícita. Os nomes exatos dependem da versão Plasma presente em Noble.

### Sessões

```text
Plasma/X11:    SDDM/display manager → Xorg → Plasma → KWin/X11
Plasma/Wayland: SDDM/display manager → KWin/Wayland → Plasma
```

Labwc e Mutter não participam da sessão Plasma. Xwayland atende aplicações X11
na sessão KWin/Wayland.

### Integrações KDE

- Plasma e System Settings consomem NetworkManager, UPower e PipeWire;
- Dolphin integra KIO, dispositivos e locais de rede;
- portal KDE atende seleção de arquivos, screenshot e screencast;
- KDE Frameworks e Qt são dependências transitivas grandes, mas legítimas;
- Discover, se escolhido, exige AppStream e backend de pacotes/Flatpak.

### Riscos e testes

- evitar dois agentes de polkit no mesmo login;
- testar KWallet/keyring e segredos de rede;
- validar tema GTK dentro de Plasma e tema Qt fora dele;
- testar KWin X11/Wayland, escala fracionária, múltiplos monitores e Xwayland;
- medir tamanho da composição Plasma separadamente.

## 6. Display manager: somente um ativo

LightDM, GDM e SDDM podem estar instalados, mas apenas um deve fornecer
`display-manager.service` e controlar o login gráfico.

| Perfil | Preferência inicial | Razão |
|---|---|---|
| XFCE | LightDM | integração simples e leve |
| GNOME | GDM | integração GNOME/Wayland e lock screen |
| KDE Plasma | SDDM | integração Plasma e temas Qt |
| ISO com todos | decisão de build pendente | precisa iniciar e listar todas as sessões sem prejudicar Wayland |

Para a ISO multi-desktop, três alternativas precisam de teste:

1. **GDM como unificador:** favorece GNOME/Wayland;
2. **SDDM como unificador:** favorece Plasma/Wayland;
3. **LightDM como unificador:** favorece leveza/XFCE, mas exige comprovação das
   sessões Wayland GNOME/Plasma.

Nenhuma será declarada vencedora sem uma matriz de login, lock, logout,
suspensão e recuperação para os três desktops. O build não pode depender de
uma pergunta interativa do `dpkg`; o pacote PlayOS deve definir explicitamente
o display manager selecionado para aquela imagem.

## 7. Arquivos de sessão

Sessões X11 são anunciadas em:

```text
/usr/share/xsessions/
```

Sessões Wayland são anunciadas em:

```text
/usr/share/wayland-sessions/
```

Pacotes upstream devem ser proprietários de suas sessões GNOME e Plasma. O
PlayOS cria arquivos próprios apenas quando realmente fornece um launcher ou
identidade diferente, como o laboratório XFCE/Labwc. Não duplicar sessões
upstream mudando apenas o nome.

Identidades esperadas:

```text
XDG_CURRENT_DESKTOP=XFCE:PlayOS
XDG_CURRENT_DESKTOP=GNOME:PlayOS
XDG_CURRENT_DESKTOP=KDE:PlayOS
XDG_SESSION_TYPE=x11|wayland
```

Os valores finais devem respeitar o que os desktops usam para selecionar
configurações e portals; não devem ser inventados sem teste.

## 8. Portals em ambiente multi-desktop

`xdg-desktop-portal` oferece interfaces comuns a aplicações sandboxed. Os
backends desenham diálogos e implementam recursos específicos.

```text
XFCE → portal GTK/compatível
GNOME → xdg-desktop-portal-gnome
KDE   → xdg-desktop-portal-kde
```

Instalar vários backends é permitido, mas a sessão precisa selecionar o backend
correto. Sem roteamento, pode haver diálogos com tema errado, seleção de arquivo
duplicada ou falha de screencast.

Regras:

- fornecer configuração por desktop conforme mecanismo da versão instalada;
- não iniciar todos os backends indiscriminadamente;
- testar FileChooser, OpenURI, Screenshot, ScreenCast e RemoteDesktop;
- PipeWire é dependência funcional de captura/compartilhamento moderno;
- registrar no diagnóstico qual backend respondeu.

## 9. Agentes polkit e serviços de sessão

Cada desktop pode trazer seu próprio agente de autenticação. Somente um agente
deve atender a sessão corrente.

```text
XFCE → agente GTK escolhido
GNOME → agente integrado/compatível do perfil GNOME
KDE   → agente polkit KDE
```

O autostart deve usar condições de desktop. A mesma regra vale para:

- daemons de settings;
- notification daemons;
- screen lockers;
- keyring/KWallet;
- clipboard managers;
- applets de rede e energia.

Executar agentes de três desktops ao mesmo tempo causa múltiplos diálogos,
conflitos de configuração e consumo desnecessário.

## 10. Temas, aplicações padrão e arquivos pessoais

Os três desktops compartilham `$HOME`, mas mantêm configurações diferentes em
`~/.config`, `~/.local/share` e outros diretórios. O PlayOS deve:

- usar padrões XDG para aplicações e MIME;
- fornecer tema PlayOS para GTK e Qt sem sobrescrever preferências pessoais;
- garantir fallback `hicolor` para ícones;
- escolher navegador, terminal, editor e visualizador por política comum;
- não apagar configuração de outro desktop durante remoção;
- testar Thunar, Nautilus e Dolphin sobre os mesmos arquivos;
- preservar permissões, thumbnails e lixeira interoperável.

Aplicações repetidas são decisão de produto. Uma ISO com três gerenciadores de
arquivos e três terminais é válida para laboratório, mas pode ser confusa na
edição de usuário. A edição final pode instalar todos os desktops e manter um
conjunto comum de aplicações padrão.

## 11. Áudio e mídia compartilhados

ALSA, PipeWire e WirePlumber são únicos para as três sessões. Cada desktop usa
seu painel de volume, mas todos consultam o mesmo grafo PipeWire.

Testes obrigatórios após alternar desktops:

- volume e mute preservados;
- dispositivo padrão coerente;
- microfone e HDMI disponíveis;
- Bluetooth reconecta quando o perfil o inclui;
- screen sharing Wayland escolhe o portal da sessão atual;
- logout encerra clientes sem derrubar serviços do sistema.

Não instalar servidores PulseAudio concorrentes por desktop.

## 12. Metapacotes propostos

```text
playos-graphics-platform
├── playos-desktop-common
├── playos-desktop-xfce
├── playos-desktop-gnome
├── playos-desktop-kde
└── playos-display-manager-profile
```

### `playos-desktop-common`

Base compartilhada documentada em `MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md`.

### Pacotes por desktop

- `playos-desktop-xfce`: XFCE, xfwm4, Labwc experimental, sessão e portal;
- `playos-desktop-gnome`: GNOME Shell, Mutter, sessão e portal GNOME;
- `playos-desktop-kde`: Plasma, KWin, sessão e portal KDE;
- `playos-desktop-all`: depende dos três para laboratório/ISO completa.

O metapacote público `playos-graphics-platform` poderá depender de
`playos-desktop-all` se a decisão final for entregar todos por padrão. Enquanto
o impacto de tamanho não for medido, também devem existir imagens por desktop.

## 13. Estratégias de imagem

| Imagem | Conteúdo | Uso |
|---|---|---|
| PlayOS XFCE | base + XFCE | leve, recuperação e hardware modesto |
| PlayOS GNOME | base + GNOME | experiência GNOME integrada |
| PlayOS KDE | base + Plasma | experiência configurável Qt/KDE |
| PlayOS All Desktops | base + três desktops | demonstração, teste e escolha completa |

A imagem “All Desktops” será maior que a soma simples dos metapacotes visíveis,
pois inclui bibliotecas GTK, Qt/KDE, aplicações, temas, portals e caches. O
tamanho precisa ser medido por APT e por ISO real; o estudo anterior de XFCE
não pode ser reutilizado como tamanho multi-desktop.

## 14. Inicialização multi-desktop

```text
UEFI → GRUB → kernel/initramfs → systemd
 → display-manager.service (um único DM)
 → escolha da sessão
    ├── XFCE/X11
    ├── XFCE/Labwc Wayland
    ├── GNOME/X11
    ├── GNOME/Wayland
    ├── Plasma/X11
    └── Plasma/Wayland
```

O display manager inicia somente a sessão escolhida. A seleção não altera o
kernel em execução nem inicia automaticamente os outros desktops.

## 15. Remoção e troca de desktop

- remover um metapacote não deve remover a base comum ainda necessária;
- configurações pessoais não são apagadas por `remove`;
- `purge` remove configurações de sistema do pacote, não `$HOME`;
- `autoremove` precisa ser revisado para não retirar bibliotecas usadas por
  outro desktop;
- trocar display manager é operação administrativa explícita;
- a sessão em execução não deve ser encerrada por scripts de pacote;
- ao remover o desktop padrão, selecionar outro antes do próximo boot gráfico.

## 16. Matriz de testes

Cada desktop precisa ser testado nas duas modalidades declaradas:

| Função | XFCE/X11 | XFCE/Wayland | GNOME/X11 | GNOME/Wayland | Plasma/X11 | Plasma/Wayland |
|---|---:|---:|---:|---:|---:|---:|
| login/logout | pendente | pendente | pendente | pendente | pendente | pendente |
| DRM/Mesa | pendente | pendente | pendente | pendente | pendente | pendente |
| teclado/mouse | pendente | pendente | pendente | pendente | pendente | pendente |
| rede/energia | pendente | pendente | pendente | pendente | pendente | pendente |
| USB/arquivos | pendente | pendente | pendente | pendente | pendente | pendente |
| áudio | pendente | pendente | pendente | pendente | pendente | pendente |
| polkit | pendente | pendente | pendente | pendente | pendente | pendente |
| portal | pendente | pendente | pendente | pendente | pendente | pendente |
| lock/suspend | pendente | pendente | pendente | pendente | pendente | pendente |
| Xwayland | N/A | pendente | N/A | pendente | N/A | pendente |

Também testar sequência de alternância:

```text
XFCE → logout → GNOME → logout → Plasma → reboot → XFCE
```

Isso detecta agentes, variáveis ou serviços que sobrevivem incorretamente ao
logout.

## 17. Diagnóstico unificado

`playos-graphicsctl status` deve informar:

```text
display_manager=<lightdm|gdm|sddm>
desktop=<XFCE|GNOME|KDE>
session_type=<x11|wayland>
compositor=<xfwm4|labwc|mutter|kwin>
xwayland=<active|inactive|not-applicable>
portal_backend=<gtk|gnome|kde|unknown>
polkit_agent=<processo detectado>
```

Falhas importantes:

- dois display managers ativos;
- compositor incorreto para a sessão;
- dois agentes polkit ou notification daemons;
- portal incompatível com `$XDG_CURRENT_DESKTOP`;
- `xfwm4` dentro de Labwc;
- Labwc dentro de GNOME ou Plasma;
- sessão Wayland registrada como X11;
- PipeWire/WirePlumber duplicados.

## 18. Segurança

- GNOME, KDE e XFCE executam como usuário comum;
- somente o display manager autentica e abre a sessão;
- polkit continua sendo autorização, independentemente do desktop;
- X11 permite mais observação entre clientes da mesma sessão;
- Wayland depende do compositor e dos portals para captura/mediação;
- extensões GNOME, widgets Plasma e plugins XFCE são código da sessão e exigem
  política de origem e atualização;
- temas e scripts baixados não recebem execução automática;
- configurações de Live/autologin nunca migram silenciosamente ao instalado.

## 19. Gates de implementação

| Gate | Evidência | Estado |
|---|---|---|
| M0 | arquitetura multi-desktop aprovada | presente |
| M1 | pacotes/versões Noble resolvidos | pendente |
| M2 | tamanho APT por desktop e conjunto | pendente |
| M3 | display manager da ISO selecionado | pendente |
| M4 | XFCE X11/Wayland testado | pendente |
| M5 | GNOME X11/Wayland testado | pendente |
| M6 | Plasma X11/Wayland testado | pendente |
| M7 | portals e polkit sem conflito | pendente |
| M8 | troca sequencial de desktop | pendente |
| M9 | Live ISO multi-desktop inicializada | pendente |
| M10 | upgrade, remoção e rollback | pendente |
| M11 | hardware representativo | pendente |

## 20. Próximos passos

1. resolver no APT Noble as versões e dependências de GNOME e Plasma;
2. medir download, tamanho instalado e impacto SquashFS de cada desktop;
3. construir os três metapacotes separados;
4. montar VM primeiro com um desktop por vez;
5. comparar GDM, SDDM e LightDM como unificador da imagem completa;
6. definir roteamento de portals e autostarts por desktop;
7. produzir `playos-desktop-all`;
8. executar a matriz de alternância e a Live ISO.

## Fontes primárias

- GNOME: <https://www.gnome.org/>
- GNOME administrador: <https://help.gnome.org/admin/>
- Mutter: <https://mutter.gnome.org/>
- KDE Plasma: <https://kde.org/plasma-desktop/>
- KDE documentação: <https://docs.kde.org/>
- KWin: <https://invent.kde.org/plasma/kwin>
- SDDM: <https://github.com/sddm/sddm>
- XFCE: <https://docs.xfce.org/>
- Labwc: <https://labwc.github.io/>
- XDG Desktop Portal: <https://flatpak.github.io/xdg-desktop-portal/>

## Documentos relacionados

- `MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md`;
- `PROJETO_SOFTWARE_UNICO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `INICIALIZACAO_PLAYOS_GRAPHICS_PLATFORM.md`;
- `MANUAL_PLAYOS_GRAPHICS_KERNEL_STACK_X11_WAYLAND.md`.
