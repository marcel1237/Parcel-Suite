# Manual do PlayOS Graphics Kernel Stack

## X11 e Wayland como produto integrado

- ID: `PLAYOS-GRAPHICS-STACK-MANUAL-001`
- tipo: `technical-manual`
- estado: arquitetura e uso documentados; implementação pendente
- confiança: alta para arquitetura Linux; média para integração XFCE/Wayland
- versão do documento: 1.0
- data: 2026-08-26
- arquitetura relacionada: `ARQUITETURA_PLAYOS_GRAPHICS_KERNEL_STACK_2026-08-26.md`
- kernel atualmente escolhido: Ubuntu Noble `6.8.0-30.30`, Linux 6.8.4
- userspace planejado: Ubuntu Resolute + XFCE 4.20

## 1. Finalidade

O PlayOS Graphics Kernel Stack é o conjunto integrado responsável por levar o
sistema desde a inicialização do hardware gráfico até uma sessão desktop XFCE
funcional em X11 ou Wayland.

O nome “Graphics Kernel Stack” descreve um produto distribuído como unidade. Não
significa que Xorg, Wayland, XFCE ou Mesa serão compilados dentro do kernel. O
produto mantém as fronteiras normais do Linux:

- o kernel controla hardware e expõe APIs;
- bibliotecas de userspace implementam renderização e acesso às APIs;
- Xorg ou um compositor Wayland executa como servidor gráfico;
- XFCE implementa a experiência de desktop;
- um metapacote instala versões compatíveis do conjunto.

Objetivos:

1. permitir uma instalação simples do stack gráfico completo;
2. oferecer X11 estável e Wayland experimental no mesmo sistema;
3. manter fallback quando uma sessão, compositor ou driver falhar;
4. garantir correspondência entre kernel, módulos, firmware e userspace;
5. facilitar Live ISO, instalação, atualização, diagnóstico e rollback;
6. não aumentar desnecessariamente o código executado em kernelspace.

## 2. Estado real

### Confirmado (`fact`)

- a fonte local é Linux 6.8.4 com empacotamento Ubuntu Noble 6.8.0-30.30;
- DRM, KMS, simpledrm, dma-buf, sync, evdev, uinput, framebuffer e VT estão
  habilitados para amd64;
- AMDGPU, i915, nouveau, VKMS e diversos drivers HID são módulos;
- o arquivo Resolute oferece XFCE 4.20, Xorg, Xwayland, Labwc e Wayfire;
- Xorg e compositores Wayland são userspace;
- XFCE 4.20 mantém X11 e possui suporte Wayland experimental;
- xfwm4 4.20 continua sendo um gerenciador de janelas X11.

### Decidido (`decision`)

- X11 será a sessão padrão inicial;
- Wayland será uma sessão explicitamente experimental;
- Labwc será o primeiro compositor Wayland avaliado;
- Xwayland fornecerá compatibilidade para aplicações X11 na sessão Wayland;
- o produto será instalado por `playos-graphics-stack`;
- o flavor de kernel será denominado conceitualmente
  `linux-playos-graphics`;
- nenhum servidor gráfico será ligado ao `vmlinux`.

### Proposto (`proposal`)

- pacotes PlayOS para metapacote, sessões e defaults;
- duas entradas selecionáveis no gerenciador de login;
- testes automatizados de DRM/KMS, Xorg, Wayland e Xwayland;
- matriz de GPUs e mecanismo de fallback;
- canal experimental para componentes Wayland.

### Não implementado (`unknown` ou pendente)

- pacotes `.deb` do novo flavor;
- metapacote funcional;
- sessão Wayland do PlayOS;
- compatibilidade do LightDM com o fluxo final Wayland;
- boot em QEMU ou hardware;
- aceleração Intel, AMD ou NVIDIA medida;
- Secure Boot;
- consumo de RAM, tempo de boot, desempenho e compatibilidade de jogos.

## 3. Modelo mental

### 3.1 Caminho gráfico comum

```text
Aplicativo
   │
   ├── OpenGL/Vulkan/VA-API
   │         │
   │       Mesa/driver userspace
   │         │
   └── toolkit GTK/Qt + protocolo X11 ou Wayland
             │
       Xorg ou compositor Wayland
             │
       libdrm/libinput/libseat
             │
       DRM/KMS + evdev no kernel
             │
          GPU/display/input
```

### 3.2 Sessão X11

```text
LightDM
  └── Xorg
       ├── xfwm4
       ├── xfce4-session
       ├── xfce4-panel
       ├── xfdesktop
       └── aplicações X11/XWayland-capable
```

Xorg é o servidor gráfico. O xfwm4 organiza janelas e também fornece composição
X11. Aplicações Wayland nativas não recebem uma sessão Wayland nesse modo; elas
normalmente usam backend X11 quando disponível.

### 3.3 Sessão Wayland

```text
gerenciador de login
  └── Labwc
       ├── xfce4-session --wayland
       ├── xfce4-panel
       ├── xfdesktop
       ├── aplicações Wayland nativas
       └── Xwayland
            └── aplicações X11 legadas
```

O compositor é o servidor Wayland. Ele controla KMS, recebe input e compõe as
janelas. Xwayland executa como cliente Wayland especial e atende programas X11.

## 4. Componentes do kernel

### 4.1 DRM

Direct Rendering Manager fornece as interfaces de dispositivos gráficos. Em um
sistema típico:

```text
/dev/dri/card0       operações de display e DRM master
/dev/dri/renderD128  renderização sem modesetting privilegiado
```

Render nodes permitem que clientes usem a GPU sem controlar diretamente as
saídas de vídeo. Permissões desses dispositivos devem ser administradas por
udev, logind e grupos/sessões, não por `chmod 777`.

### 4.2 KMS

Kernel Mode Setting representa conectores, CRTCs, encoders, planes e
framebuffers. Xorg e o compositor Wayland usam KMS para:

- descobrir monitores;
- selecionar resolução e frequência;
- apresentar frames;
- executar page flips;
- controlar múltiplas saídas;
- negociar formatos e modificadores.

### 4.3 dma-buf e sincronização

dma-buf permite compartilhar buffers entre GPU, compositor, aplicativos,
captura e decodificação de vídeo. `CONFIG_SYNC_FILE` fornece primitivas usadas
na sincronização de trabalho gráfico. Falhas nessa área podem aparecer como
flicker, corrupção, frame atrasado ou travamento de GPU, mesmo quando o desktop
consegue iniciar.

### 4.4 Input

O kernel normaliza teclado, mouse, touchpad, touchscreen e controles por evdev.
Xorg ou o compositor Wayland consome eventos através de libinput. uinput permite
dispositivos virtuais e é relevante para acessibilidade, streaming, testes e
alguns recursos de jogos.

### 4.5 simpledrm e framebuffer

`simpledrm` oferece display inicial usando framebuffer deixado pelo firmware.
Ele ajuda no console e no Plymouth antes do driver nativo assumir o dispositivo.
Não substitui AMDGPU, i915 ou um driver NVIDIA para aceleração completa.

### 4.6 Drivers como módulos

O modelo modular é preservado:

- `amdgpu`: GPUs AMD suportadas;
- `i915`: gráficos Intel contemplados por esse kernel;
- `nouveau`: driver aberto NVIDIA;
- `vkms`: dispositivo KMS virtual para testes;
- HID/I2C HID: dispositivos de entrada.

Um módulo presente não comprova suporte a toda geração de hardware. A versão
6.8 também não possui necessariamente suporte introduzido em kernels mais novos.

## 5. Componentes de userspace

### 5.1 Mesa

Mesa fornece implementações e drivers userspace para OpenGL, EGL e Vulkan em
várias GPUs. O kernel e Mesa precisam cooperar por UAPI estável, mas não precisam
ter o mesmo número de versão.

Pacotes devem ser registrados no manifesto, incluindo bibliotecas 32-bit se o
produto futuramente oferecer jogos Steam/Wine que dependam de multiarquitetura.

### 5.2 libdrm

libdrm encapsula partes da interface DRM para userspace. É uma biblioteca, não
um driver substituto. Sua presença não confirma aceleração.

### 5.3 libinput e gerenciamento de seat

libinput interpreta eventos evdev e oferece comportamento consistente para
touchpads, ponteiros e teclados. logind/libseat controla qual sessão possui
acesso ao seat e aos dispositivos.

### 5.4 Xorg

Xorg será o servidor da sessão estável. O stack deve incluir:

```text
xserver-xorg-core
xserver-xorg-input-all
xserver-xorg-video-all ou seleção validada
x11-xserver-utils
```

Em muitos dispositivos modernos, o driver genérico `modesetting` do Xorg usa
KMS e Mesa. Não instalar indiscriminadamente drivers DDX antigos sem necessidade
medida.

### 5.5 Wayland

Wayland é o protocolo. `libwayland-server` auxilia implementações de servidor,
mas não é por si só um compositor. `wayland-protocols` contém descrições de
protocolos complementares.

### 5.6 Labwc

Labwc será avaliado como primeiro compositor Wayland para o XFCE. A escolha é
experimental e não representa aprovação de produção. Precisam ser testados:

- múltiplos monitores;
- escala;
- atalhos;
- gerenciamento de energia;
- bloqueio de tela;
- painel e desktop XFCE;
- captura e compartilhamento;
- aplicações Xwayland;
- jogos em fullscreen;
- suspend/resume.

### 5.7 Xwayland

Xwayland atende clientes X11 dentro da sessão Wayland. Ele não é usado como
servidor principal na sessão X11 e não transforma aplicações X11 em Wayland
nativas.

## 6. Modelo de pacotes

### 6.1 Flavor do kernel

Pacotes esperados:

```text
linux-image-<abi>-playos-graphics
linux-modules-<abi>-playos-graphics
linux-modules-extra-<abi>-playos-graphics
linux-headers-<abi>-playos-graphics
```

O nome da ABI só será definido após adaptar o empacotamento. Não publicar
pacotes PlayOS com exatamente a mesma versão de um pacote Ubuntu diferente.

### 6.2 Metapacote

```text
Package: playos-graphics-stack
Architecture: amd64
Depends:
 linux-image-...-playos-graphics,
 linux-modules-...-playos-graphics,
 playos-xfce-sessions,
 xserver-xorg-core,
 xwayland,
 labwc,
 xfce4-session,
 xfwm4,
 mesa-utils,
 libwayland-server0
```

Esse exemplo é conceitual. `linux-firmware`, drivers Mesa, portals, áudio e
dependências precisam ser resolvidos na embalagem real. Um metapacote não deve
fixar nomes de ABI eternamente; normalmente depende de outro metapacote do
kernel que acompanha a ABI corrente.

### 6.3 Pacote de sessões

`playos-xfce-sessions` deve conter:

```text
/usr/share/xsessions/playos-xfce-x11.desktop
/usr/share/wayland-sessions/playos-xfce-wayland.desktop
/usr/bin/start-playos-xfce-x11
/usr/bin/start-playos-xfce-wayland
```

Os scripts devem:

- validar dependências;
- exportar somente variáveis necessárias;
- registrar falha clara no journal;
- retornar código não zero em erro;
- não executar como root;
- não alterar configurações permanentes a cada login.

## 7. Arquivos de sessão propostos

### 7.1 X11

```ini
[Desktop Entry]
Name=PlayOS XFCE (X11)
Comment=Sessão estável PlayOS com Xorg e xfwm4
Exec=/usr/bin/start-playos-xfce-x11
TryExec=/usr/bin/start-playos-xfce-x11
Type=Application
DesktopNames=XFCE;PlayOS;
```

Script conceitual:

```bash
#!/bin/sh
set -eu
export XDG_CURRENT_DESKTOP=XFCE:PlayOS
export XDG_SESSION_DESKTOP=playos-xfce
exec startxfce4
```

### 7.2 Wayland

```ini
[Desktop Entry]
Name=PlayOS XFCE (Wayland Experimental)
Comment=Sessão experimental PlayOS com Labwc
Exec=/usr/bin/start-playos-xfce-wayland
TryExec=/usr/bin/start-playos-xfce-wayland
Type=Application
DesktopNames=XFCE;PlayOS;
```

O comando exato de composição entre Labwc e `startxfce4 --wayland` precisa ser
confirmado em runtime. Não copiar um script não testado para o pacote de
produção. A entrada deve incluir “Experimental” até passar os gates.

## 8. Uso pelo usuário

### 8.1 Escolher sessão

Na tela de login:

1. selecionar o usuário;
2. abrir o seletor de sessão;
3. escolher `PlayOS XFCE (X11)` para compatibilidade;
4. escolher `PlayOS XFCE (Wayland Experimental)` para testes;
5. autenticar normalmente.

A última sessão pode ser lembrada pelo display manager. O sistema deve sempre
manter X11 disponível como recuperação.

### 8.2 Confirmar a sessão

```bash
printf '%s\n' "$XDG_SESSION_TYPE"
printf '%s\n' "$XDG_CURRENT_DESKTOP"
loginctl show-session "$XDG_SESSION_ID" -p Type -p Desktop -p Remote
```

Resultados principais:

```text
Type=x11
```

ou:

```text
Type=wayland
```

### 8.3 Identificar o servidor

X11:

```bash
pgrep -a Xorg
pgrep -a xfwm4
xdpyinfo | sed -n '1,20p'
```

Wayland:

```bash
pgrep -a labwc
printf '%s\n' "$WAYLAND_DISPLAY"
```

Xwayland só deve aparecer quando iniciado pelo compositor ou necessário:

```bash
pgrep -a Xwayland || true
```

### 8.4 Fallback

Se Wayland falhar:

1. retornar ao gerenciador de login;
2. selecionar `PlayOS XFCE (X11)`;
3. entrar novamente;
4. coletar journal da tentativa Wayland;
5. não apagar configurações nem trocar drivers antes de guardar evidências.

Se a tela ficar preta, tentar mudar para um VT com `Ctrl+Alt+F3`, autenticar e
inspecionar logs. O atalho depende de firmware, teclado e configuração.

## 9. Uso específico por cenário

### 9.1 Desktop geral

Padrão: X11 até o Wayland atingir paridade suficiente. Validar áudio, rede,
clipboard, suspensão, bloqueio, brilho, teclado multimídia e monitores.

### 9.2 Jogos

Não presumir que Wayland sempre melhora desempenho. Testar separadamente:

- jogos Vulkan nativos;
- Steam/Wine/Proton via Xwayland;
- fullscreen e borderless;
- taxa de atualização variável;
- múltiplos monitores;
- captura/overlay;
- controle e force feedback;
- latency e frame pacing.

Registrar GPU, driver kernel, Mesa, Vulkan ICD, sessão e compositor em cada
resultado. FPS sem baseline e repetição não é evidência de superioridade.

### 9.3 Aplicações legadas X11

Na sessão X11, executam diretamente no Xorg. Na sessão Wayland, usam Xwayland.
Problemas de automação, captura global, injeção de input ou posicionamento podem
ser limitações de segurança/protocolo, não defeitos do kernel.

### 9.4 Captura e compartilhamento de tela

X11 permite acesso global mais amplo. Em Wayland, captura deve passar pelo
compositor e normalmente por `xdg-desktop-portal` e PipeWire. O stack final
precisará escolher e testar um backend portal compatível com Labwc/XFCE.

Sem portal correto, navegadores e aplicações de reunião podem abrir sem oferecer
compartilhamento de tela.

### 9.5 Máquinas virtuais

Testar inicialmente com virtio-gpu ou QXL conforme a VM. `spice-vdagent` pode
oferecer integração adicional. Um resultado em VM não prova suporte a GPU real.

### 9.6 Headless e CI

VKMS pode fornecer KMS virtual para testes DRM sem display físico. Weston ou
Cage podem ser usados em testes isolados de protocolo, mas não substituem o
teste final Labwc/XFCE.

### 9.7 Recuperação

Manter alvo texto e console VT. Um kernel gráfico não deve depender de Xorg ou
Wayland para oferecer shell de recuperação.

## 10. GPUs e drivers

### 10.1 Intel

O kernel local habilita i915 como módulo. Verificar geração suportada, firmware,
mensagens de probe, conectores e render node. Hardware Intel posterior ao escopo
do kernel 6.8 pode exigir kernel mais novo.

### 10.2 AMD

AMDGPU está modular. Conferir firmware correspondente, aceleração Mesa/RADV,
saídas, suspend/resume e reset após falha. Firmware ausente pode permitir console
e ainda impedir aceleração correta.

### 10.3 NVIDIA aberta

Nouveau deve ser testado como caminho aberto, sem prometer desempenho ou suporte
completo a todas as GPUs.

### 10.4 NVIDIA proprietária

É uma matriz separada:

- módulo precisa corresponder ao kernel/ABI;
- DKMS ou módulo pré-compilado deve concluir;
- assinatura pode ser exigida por Secure Boot;
- modesetting DRM precisa estar coerente;
- Xorg, Wayland e Xwayland devem ser testados individualmente.

O módulo proprietário não deve entrar no primeiro MVP mínimo.

### 10.5 Renderização por software

llvmpipe pode fazer o desktop abrir quando a GPU não acelera. Isso é fallback,
não sucesso gráfico completo. Sempre conferir o renderizador.

## 11. Diagnóstico

### 11.1 Inventário

```bash
uname -a
lspci -nnk | sed -n '/VGA\|3D\|Display/,+4p'
lsmod | grep -E 'amdgpu|i915|nouveau|nvidia|virtio_gpu|vkms'
ls -l /dev/dri /dev/input 2>/dev/null
```

### 11.2 Kernel e DRM

```bash
journalctl -b -k | grep -Ei 'drm|kms|gpu|firmware|amdgpu|i915|nouveau|nvidia'
dmesg --level=err,warn
modetest -c
```

`dmesg` pode exigir privilégio dependendo da política do sistema.

### 11.3 Renderização

```bash
glxinfo -B
eglinfo
vulkaninfo --summary
```

Verificar se o renderizador é a GPU esperada ou software.

### 11.4 Sessão e display manager

```bash
systemctl status display-manager --no-pager
journalctl -b -u display-manager
loginctl list-sessions
loginctl session-status
```

### 11.5 Xorg

```bash
journalctl -b _COMM=Xorg
grep -E '\(EE\)|\(WW\)' ~/.local/share/xorg/Xorg.0.log 2>/dev/null
```

O local do log varia conforme display manager e configuração.

### 11.6 Wayland/Labwc

```bash
journalctl --user -b | grep -Ei 'labwc|wayland|wlroots|xwayland|xfce'
printf 'session=%s display=%s\n' "$XDG_SESSION_TYPE" "${WAYLAND_DISPLAY-}"
```

### 11.7 Árvore de decisão

```text
sem imagem desde o boot
├── verificar firmware/UEFI/bootloader
├── verificar simpledrm/framebuffer
└── verificar driver GPU e initramfs

console funciona, login gráfico não
├── display-manager
├── Xorg/Labwc ausente ou falhando
├── permissões de seat/DRM
└── arquivo de sessão inválido

X11 funciona, Wayland não
├── Labwc/wlroots
├── XFCE experimental
├── portal/seat/input
└── driver DRM/atomic modesetting

Wayland funciona, app X11 não
├── pacote Xwayland
├── processo Xwayland
├── DISPLAY
└── integração XWM do compositor

desktop abre, desempenho ruim
├── renderizador software
├── firmware ausente
├── driver userspace/ICD incorreto
└── sincronização/compositor/configuração
```

## 12. Live ISO

### 12.1 Conteúdo

A Live deve carregar:

- kernel e módulos PlayOS da mesma ABI;
- firmware selecionado;
- SquashFS e OverlayFS;
- stack userspace gráfico;
- ambas as sessões;
- X11 como padrão;
- ferramentas mínimas de diagnóstico.

### 12.2 Ordem de construção

1. gerar `.deb` do kernel;
2. verificar pacotes e ABI;
3. inserir em `config/packages.chroot/`;
4. usar `--linux-packages none`;
5. instalar stack gráfico no rootfs;
6. gerar initramfs depois dos módulos;
7. compor SquashFS;
8. gerar ISO híbrida;
9. testar console, X11 e Wayland separadamente.

### 12.3 Boot padrão

O GRUB não precisa perguntar X11 ou Wayland. Ele seleciona kernel e parâmetros.
A escolha da sessão pertence ao display manager. Pode existir uma entrada de
recuperação que inicie `multi-user.target` sem desktop.

### 12.4 Persistência

Não adicionar no primeiro build. Quando implementada, deve preservar `/home` e
configurações sem tornar a base SquashFS mutável. Mudanças persistentes de
driver podem impedir boot e precisam de fallback.

## 13. Atualização e rollback

### 13.1 Atualizações independentes

O metapacote coordena, mas não funde artefatos. Isso permite:

- atualizar Xwayland por vulnerabilidade sem recompilar kernel;
- atualizar kernel e módulos sem substituir XFCE;
- atualizar Labwc experimental sem mudar sessão X11;
- reverter compositor sem reverter firmware.

### 13.2 Kernel anterior

Manter ao menos um kernel previamente validado no sistema instalado. O
bootloader deve permitir selecioná-lo. A Live ISO contém apenas o kernel definido
por sua release, salvo decisão explícita de recuperação.

### 13.3 Versionamento

Registrar:

```text
PlayOS release
kernel package version e Git tree
ABI e hashes dos módulos
firmware package
Mesa/libdrm/libinput
Xorg/Xwayland
Wayland protocols
Labwc
XFCE
arquivo de sessão/defaults
```

## 14. Segurança

### 14.1 Privilégios

Xorg e compositor não devem executar dentro do kernel. Acesso a DRM/input deve
ser limitado à sessão ativa por logind/seat. Não usar permissões globais para
corrigir problemas.

### 14.2 Isolamento Wayland

Wayland reduz algumas formas de acesso global típicas do X11, mas não é uma
garantia completa de segurança. Compositor, portal, PipeWire e políticas de
aplicação precisam estar corretos.

### 14.3 Secure Boot

O kernel local não recebe assinatura Canonical automaticamente. Laboratório
começa com Secure Boot desativado. Uma release exige chave PlayOS, assinatura de
kernel/módulos, certificado, enrollment e política de rotação/revogação.

### 14.4 Atualizações de segurança

Empacotar tudo num único binário impediria correções independentes. O
metapacote é deliberadamente apenas uma declaração de dependências.

## 15. Testes e critérios de aceitação

### 15.1 Kernel

- imagem e módulos compilam;
- ABI coincide;
- initramfs contém módulos Live essenciais;
- console funciona;
- DRM cria dispositivos esperados;
- não há oops, lockup ou firmware crítico ausente.

### 15.2 X11

- login e logout repetidos;
- XFCE abre;
- xfwm4 funciona;
- resolução e múltiplos monitores;
- OpenGL/EGL/Vulkan identificados;
- suspend/resume;
- retorno após troca de VT.

### 15.3 Wayland

- sessão é realmente `wayland`;
- Labwc é servidor;
- painel, desktop e configurações essenciais;
- input, hotplug e escala;
- logout sem travamento;
- falha retorna ao login;
- limitações conhecidas documentadas.

### 15.4 Xwayland

- aplicativo X11 abre;
- clipboard e input;
- janela normal e fullscreen;
- escala e múltiplos monitores;
- processo termina no logout.

### 15.5 Live

- BIOS e UEFI;
- root em SquashFS/OverlayFS;
- rede e áudio;
- X11 padrão;
- Wayland selecionável;
- console de recuperação;
- SHA-256 e manifesto.

## 16. Níveis de maturidade

| Nível | Significado |
|---|---|
| G0 | documento apenas |
| G1 | kernel e módulos empacotados |
| G2 | console/KMS inicializa em VM |
| G3 | XFCE/X11 funcional em VM |
| G4 | Wayland/Labwc funcional em VM |
| G5 | Xwayland e portals validados |
| G6 | matriz de hardware executada |
| G7 | instalação, update e rollback testados |
| G8 | Secure Boot e critérios de release atendidos |

Estado atual: **G0**.

## 17. Antipadrões proibidos

- compilar Xorg ou compositor dentro do `vmlinux`;
- iniciar desktop dentro do initramfs permanente;
- copiar somente `bzImage` sem módulos correspondentes;
- chamar Linux 6.8.4 local de kernel oficial Resolute;
- instalar `linux-generic` junto sem decidir sobre segundo kernel;
- usar Wayland como padrão antes dos gates;
- remover X11 antes de obter paridade suficiente;
- declarar aceleração apenas porque `/dev/dri` existe;
- usar `chmod 777` em DRM/input;
- prometer compatibilidade universal com GPUs ou jogos;
- misturar resultados de VM com validação em hardware.

## 18. Perguntas frequentes

### O kernel contém Wayland?

Não. Contém DRM/KMS, input e drivers usados pelo compositor Wayland.

### O kernel contém X11?

Não. Xorg é o servidor X11 de userspace e usa interfaces do kernel.

### Por que chamar de Graphics Kernel Stack?

Porque é um produto integrado que inclui kernel e stack gráfico por
dependências, manifestos e testes, não por ligação binária.

### É possível usar somente Wayland?

Tecnicamente em alguns ambientes, mas não é a decisão inicial. XFCE 4.20
Wayland é experimental e aplicações legadas ainda podem exigir Xwayland.

### Xwayland substitui Xorg?

Não. Ele atende aplicações X11 dentro de um compositor Wayland.

### Por que Labwc?

É recomendado pelo XFCE para experimentação com 4.20 e tem escopo adequado ao
MVP. A escolha final depende dos testes.

### O stack melhora FPS?

Não determinado. Desempenho depende de GPU, driver, Mesa, jogo, compositor e
configuração. Precisa de benchmark controlado.

### Funciona com NVIDIA?

Não determinado para o PlayOS. Nouveau e driver proprietário exigem matrizes
separadas.

### Pode existir um modo gráfico de recuperação?

Sim, futuramente com software rendering ou compositor mínimo, mas o fallback
obrigatório é console, não outro stack gráfico complexo.

## 19. Próximos trabalhos

1. criar especificação Debian do flavor `linux-playos-graphics`;
2. criar `playos-graphics-stack`;
3. criar pacote `playos-xfce-sessions`;
4. definir launcher Wayland e ambiente;
5. avaliar LightDM com sessões Wayland;
6. escolher portal e integração PipeWire;
7. empacotar o kernel local em staging;
8. produzir Live de console;
9. habilitar sessão X11;
10. adicionar sessão Wayland experimental;
11. criar testes e matriz de hardware;
12. documentar resultados em vez de substituir esta proposta por afirmações.

## 20. Fontes primárias

- [Wayland — arquitetura](https://wayland.freedesktop.org/architecture.html)
- [Wayland — conceito de servidor/compositor](https://wayland.freedesktop.org/)
- [Wayland — Xwayland](https://wayland.freedesktop.org/docs/book/Xwayland.html)
- [Linux — DRM userspace API](https://docs.kernel.org/gpu/drm-uapi.html)
- [Linux — DRM/KMS](https://docs.kernel.org/next/gpu/drm-kms.html)
- [Linux — input/evdev](https://kernel.org/doc/html/latest/input/input.html)
- [Linux — dma-buf](https://docs.kernel.org/7.1/userspace-api/dma-buf-alloc-exchange.html)
- [Linux — VKMS](https://docs.kernel.org/6.17/gpu/vkms.html)
- [XFCE 4.20 — documentação](https://docs.xfce.org/)
- [XFCE 4.20 — changelog](https://xfce.org/download/changelogs/4.20)
- [XFCE 4.20 — Wayland, Labwc e Wayfire](https://xfce.org/about/tour?lang=oc)

## 21. Relação com outros documentos

- `ARQUITETURA_PLAYOS_GRAPHICS_KERNEL_STACK_2026-08-26.md`: decisão e visão
  arquitetural resumida;
- `AUDITORIA_KERNEL_LOCAL_LIVE_RESOLUTE_XFCE_2026-08-26.md`: identidade e
  capacidade da fonte de kernel;
- `COMPARACAO_FEDORA_KNOPPIX_LIVE_XFCE_KERNEL_LOCAL_2026-08-26.md`: escolha do
  pipeline da Live ISO;
- `LIVE_CD_RESOLUTE_XFCE_MINIMAL_KNOPPIX.md`: primeiro desenho da Live mínima.
