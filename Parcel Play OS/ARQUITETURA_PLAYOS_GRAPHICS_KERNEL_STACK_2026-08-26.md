# PlayOS Graphics Kernel Stack: X11 e Wayland como produto integrado

- ID: `PLAYOS-GRAPHICS-STACK-001`
- tipo: `architecture-analysis`
- estado: proposta; não implementada; não compilada; não testada
- confiança: alta para separação kernel/userspace; média para sessão XFCE Wayland
- data: 2026-08-26
- fonte do kernel: Ubuntu Noble `6.8.0-30.30`, Linux 6.8.4

## Veredito

Não é tecnicamente correto colocar os servidores Wayland e Xorg dentro do
kernel Linux. Wayland é um protocolo e o servidor Wayland é um compositor de
userspace; Xorg também é um processo de userspace. O kernel fornece os
mecanismos usados por ambos: drivers GPU, DRM/KMS, dma-buf, sincronização,
evdev, HID, consoles e gerenciamento de memória.

É possível colocar binários de userspace dentro de um initramfs distribuído com
o kernel, mas isso não os transforma em código do kernel. Para Xorg, Mesa e um
compositor completo, essa solução aumentaria o initramfs, dificultaria
atualizações de segurança e acoplaria componentes com ciclos de atualização
diferentes. Ela foi rejeitada.

A necessidade do projeto pode ser atendida por um produto integrado:

```text
PlayOS Graphics Kernel Stack
├── kernel playos-graphics
├── módulos DRM/KMS/input
├── firmware
├── Mesa/libdrm/libinput
├── Xorg + xfwm4
├── compositor Wayland + Xwayland
├── XFCE 4.20
└── perfis de sessão X11 e Wayland
```

Para o usuário, isso pode ser instalado e atualizado por um único metapacote.
Internamente, permanece dividido em kernel e userspace, preservando segurança,
ABI e manutenção.

## Onde cada componente pertence

| Camada | Componentes | Espaço |
|---|---|---|
| hardware | GPU, conectores, teclado, mouse | físico |
| kernel | DRM/KMS, drivers, dma-buf, sync, evdev, HID | kernelspace |
| bibliotecas | Mesa, libdrm, libinput, libwayland | userspace |
| servidor X11 | Xorg | userspace |
| WM X11 | xfwm4 | userspace |
| servidor Wayland | Labwc/Wayfire ou futuro Xfwl4 | userspace |
| compatibilidade X11 em Wayland | Xwayland | userspace |
| desktop | sessão, painel, Thunar, xfdesktop | userspace |

O kernel expõe dispositivos como `/dev/dri/card*`, `/dev/dri/renderD*` e
`/dev/input/event*`. O compositor ou Xorg consome essas interfaces. Colocar
parsing de protocolos gráficos, política de janelas, temas ou clientes no
kernel ampliaria a superfície privilegiada e violaria essa separação.

## Estado do kernel local

A auditoria de `debian.master/config/annotations` confirmou para amd64:

```text
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_SIMPLEDRM=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_SYNC_FILE=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_UINPUT=y
CONFIG_FB=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_VT=y
CONFIG_VT_CONSOLE=y

CONFIG_DRM_AMDGPU=m
CONFIG_DRM_I915=m
CONFIG_DRM_NOUVEAU=m
CONFIG_DRM_VKMS=m
CONFIG_HID=m
CONFIG_HID_GENERIC=m
CONFIG_I2C_HID=m
```

Logo, a fonte já oferece a base comum para X11 e Wayland. Não existem opções
`CONFIG_WAYLAND` ou `CONFIG_X11` porque esses protocolos não são implementados
pelo kernel.

## Novo modelo de flavor

O nome técnico recomendado é:

```text
linux-playos-graphics
```

Ele não deve conter os servidores gráficos no `vmlinux`. Deve representar um
contrato de distribuição:

### Pacotes de kernel

```text
linux-image-...-playos-graphics
linux-modules-...-playos-graphics
linux-modules-extra-...-playos-graphics
linux-headers-...-playos-graphics
```

### Metapacote do produto

```text
playos-graphics-stack
```

Dependências conceituais:

```text
playos-graphics-stack
├── kernel PlayOS Graphics
├── linux-firmware ou seleção medida
├── libdrm + Mesa
├── libinput + libseat/logind
├── xserver-xorg-core
├── xserver-xorg-input-all
├── wayland-protocols + libwayland-server0
├── xwayland
├── xfce4-session + painel + desktop
├── xfwm4
└── compositor Wayland selecionado
```

O metapacote oferece a experiência de “kernel gráfico incluído”, sem mentir
sobre a arquitetura.

## Estratégia de duas sessões

### Sessão padrão: PlayOS XFCE X11

```text
LightDM → Xorg → xfwm4 → XFCE 4.20
```

É o padrão recomendado porque `xfwm4` 4.20 continua X11-only e o upstream
classifica Wayland no XFCE 4.20 como experimental.

### Sessão experimental: PlayOS XFCE Wayland

```text
gerenciador de login → Labwc → startxfce4 --wayland
                                  └── Xwayland para aplicações X11
```

O XFCE 4.20 não possui compositor Wayland próprio pronto nessa versão. O
upstream recomenda Labwc ou Wayfire para testes. Para a Live mínima, Labwc é a
primeira opção por ter escopo menor; isso ainda precisa de teste comparativo.

Arquivos conceituais:

```text
/usr/share/xsessions/playos-xfce-x11.desktop
/usr/share/wayland-sessions/playos-xfce-wayland.desktop
/usr/bin/start-playos-xfce-wayland
```

O suporte do gerenciador de login escolhido a ambas as entradas deve ser
testado. Se LightDM não iniciar a sessão Wayland corretamente, não adicionar
workaround silencioso: avaliar greetd ou SDDM numa variante experimental.

## Papel do Xwayland

Xwayland não é uma segunda sessão X11 completa. Na sessão Wayland ele funciona
como servidor para aplicações X11 e como cliente do compositor Wayland. Assim:

- sessão X11 nativa: Xorg + xfwm4;
- sessão Wayland: compositor Wayland + Xwayland sob demanda;
- aplicações Wayland nativas não passam por Xwayland.

Esse arranjo oferece compatibilidade, mas não garante que toda aplicação,
driver ou jogo funcione igualmente nas duas sessões.

## Initramfs gráfico

O initramfs deve conter apenas o necessário para localizar rootfs e apresentar
console/boot visual básico. Pode antecipar módulos de armazenamento e, quando
necessário, DRM para KMS/Plymouth:

```text
simpledrm
amdgpu/i915/nouveau conforme política e hardware
hid_generic/i2c_hid conforme necessidade
overlay/isofs/squashfs para Live boot
```

Não colocar Mesa, Xorg, Xwayland, XFCE ou Labwc no initramfs normal. Eles devem
permanecer no SquashFS e no sistema instalado.

Forçar todos os drivers GPU no initramfs aumenta tamanho e pode causar
regressões. O primeiro build deve usar a descoberta normal de
`initramfs-tools`; inclusões explícitas serão orientadas por falhas de boot.

## Pacotes disponíveis no Resolute

Verificação local do arquivo APT em 2026-08-26:

| Pacote | Versão candidata |
|---|---:|
| `libwayland-server0` | 1.24.0-2 |
| `wayland-protocols` | 1.47-1 |
| `xserver-xorg-core` | 21.1.22-1ubuntu1 |
| `xwayland` | 24.1.10-1 |
| `xfwm4` | 4.20.0-1build1 |
| `xfce4-session` | 4.20.4-1 |
| `labwc` | 0.9.3-1 |
| `wayfire` | 0.10.0-1 |

Versões podem mudar enquanto Resolute recebe atualizações; o build deve
registrar manifesto e snapshot.

## Pacotes propostos no repositório PlayOS

```text
packages/
├── playos-graphics-stack/
│   └── debian/control
├── playos-xfce-sessions/
│   ├── usr/share/xsessions/playos-xfce-x11.desktop
│   ├── usr/share/wayland-sessions/playos-xfce-wayland.desktop
│   └── usr/bin/start-playos-xfce-wayland
└── playos-graphics-defaults/
    └── configuração conservadora e fallbacks
```

Separar pacotes permite atualizar Mesa/Xorg/Xwayland sem recompilar o kernel e
atualizar o kernel sem reconstruir o desktop.

## Integração com a Live ISO

O perfil `live-build` continua com `--linux-packages none`, recebendo os `.deb`
do kernel local por `config/packages.chroot/`. A lista de pacotes adiciona:

```text
playos-graphics-stack
playos-xfce-sessions
```

Durante o primeiro ciclo, antes dos metapacotes existirem, a lista pode
declarar explicitamente Xorg, XFCE, Labwc e Xwayland. Isso é bootstrap, não a
arquitetura final.

## Segurança e manutenção

### Por que não kernelspace

- falha no servidor gráfico não deve provocar kernel panic;
- Xorg/compositor precisam atualizar sem reiniciar num kernel novo;
- parsing de clientes não deve executar com privilégios do kernel;
- drivers proprietários e Mesa possuem ciclos distintos;
- Wayland, X11 e desktop têm licenças e ABIs próprias;
- depuração e rollback ficam muito mais seguros em processos separados.

### Contrato de compatibilidade

O contrato não é “mesma versão para sempre”. É uma matriz validada:

```text
kernel build ID
× módulos/firmware
× Mesa/libdrm
× Xorg/Xwayland
× compositor Wayland
× XFCE
× GPUs testadas
```

O manifesto da ISO deve registrar cada eixo.

## Gates

1. **Kernel:** empacotar imagem e módulos; validar DRM, input e initramfs.
2. **Console/KMS:** boot sem servidor gráfico; testar conectores e resolução.
3. **X11:** Xorg + xfwm4 + XFCE, software rendering e GPU real.
4. **Wayland:** Labwc + XFCE experimental, inicialmente sem Xwayland.
5. **Xwayland:** executar aplicações X11 dentro da sessão Wayland.
6. **Fallback:** falha Wayland retorna ao seletor e permite X11.
7. **GPU:** Intel, AMD, nouveau e NVIDIA proprietário em matrizes separadas.
8. **Suspend/hotplug:** monitores, docking, suspend/resume e mudança de VT.
9. **Segurança:** permissões DRM/input, logind/seat, assinatura e updates.
10. **Release:** X11 continua padrão até Wayland passar critérios definidos.

## Critérios de teste

```bash
uname -r
ls -l /dev/dri /dev/input
modetest -c
loginctl session-status
printf '%s\n' "$XDG_SESSION_TYPE"
glxinfo -B
eglinfo
vulkaninfo --summary
```

Na sessão Wayland:

```bash
test "$XDG_SESSION_TYPE" = wayland
pgrep -a labwc
pgrep -a Xwayland
```

Na sessão X11:

```bash
test "$XDG_SESSION_TYPE" = x11
pgrep -a Xorg
pgrep -a xfwm4
```

Presença de processo não comprova aceleração. Renderizador, logs, falhas DRM e
comportamento visual precisam ser avaliados.

## Decisão proposta

Rejeitar a incorporação literal de Xorg/Wayland no kernel. Adotar
`linux-playos-graphics` como flavor de kernel e `playos-graphics-stack` como
metapacote indivisível para o produto. Entregar X11 estável como padrão e
Wayland/Labwc + Xwayland como sessão experimental selecionável.

## Fontes primárias

- [Wayland — arquitetura](https://wayland.freedesktop.org/architecture.html)
- [Wayland — compositor como servidor](https://wayland.freedesktop.org/)
- [Wayland — arquitetura do Xwayland](https://wayland.freedesktop.org/docs/book/Xwayland.html)
- [Linux DRM — interfaces de userspace](https://docs.kernel.org/gpu/drm-uapi.html)
- [Linux DRM/KMS](https://docs.kernel.org/next/gpu/drm-kms.html)
- [Linux input/evdev](https://kernel.org/doc/html/latest/input/input.html)
- [XFCE 4.20 — changelog X11/Wayland](https://xfce.org/download/changelogs/4.20)
- [XFCE 4.20 — aviso sobre Wayland experimental](https://docs.xfce.org/)
- [XFCE 4.20 — Labwc/Wayfire e limitações](https://xfce.org/about/tour?lang=oc)
