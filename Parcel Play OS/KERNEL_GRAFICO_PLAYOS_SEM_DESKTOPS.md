# Kernel gráfico PlayOS sem XFCE, GNOME ou KDE

## Estado e decisão

- **Classificação:** `decision`, `architecture` e `proposal`.
- **Data:** 2026-08-26.
- **Artefato proposto:** `linux-playos-graphics`.
- **Desktops dentro do kernel:** nenhum.
- **Implementação/build/boot:** ainda não realizados por este documento.

O kernel gráfico PlayOS será independente de XFCE, GNOME e KDE Plasma. Esses
ambientes não serão compilados, empacotados nem inicializados como parte do
kernel. Também não serão incorporados ao kernel Xorg, Wayland, Xwayland,
LightDM, GDM, SDDM, Mesa, PipeWire ou toolkits gráficos.

O termo **kernel gráfico** significa um kernel Linux preparado para fornecer
interfaces gráficas eficientes e compatíveis ao userspace. Não significa um
kernel que desenha desktop, painel ou janelas.

Vulkan é suportado como API userspace sobre os render nodes DRM. O kernel não
contém o loader ou os ICDs Vulkan; eles pertencem ao
`playos-vulkan-runtime`. Consulte `VULKAN_NO_PLAYOS_GRAPHICS_CORE.md`.

> **Composição restaurada:** todos os componentes não-desktop — serviços,
> XDG, Mesa, input, fontes, Xorg, Wayland, Xwayland, Labwc, LightDM, PipeWire e
> WirePlumber — voltam ao produto integrado `playos-graphics-core`. Eles
> continuam fora do `vmlinux`. A especificação está em
> `PLAYOS_GRAPHICS_CORE_COMPLETO_SEM_DESKTOPS.md`.

## 1. Nova fronteira

```text
KERNEL GRÁFICO PLAYOS
├── DRM/KMS
├── drivers de GPU
├── dma-buf e sincronização
├── console/framebuffer de recuperação
├── evdev e infraestrutura de input
├── firmware loader, PCI, IOMMU e energia
└── interfaces estáveis para userspace

---------------- fronteira kernel/userspace ----------------

USERSPACE GRÁFICO OPCIONAL
├── libdrm + Mesa
├── Xorg, Wayland e Xwayland
├── compositor ou servidor gráfico
└── desktop opcional: XFCE, GNOME, KDE ou outro
```

Sem userspace gráfico, o mesmo kernel inicializa em console. Quando um stack
gráfico for instalado, ele consome as interfaces do kernel sem alterar o
`vmlinux`.

## 2. O que fica no kernel

### DRM

Direct Rendering Manager fornece a infraestrutura de dispositivos gráficos,
controle de acesso, render nodes, gerenciamento de memória e integração com os
drivers de GPU.

Interfaces esperadas depois do boot:

```text
/dev/dri/card0
/dev/dri/renderD128
/sys/class/drm/
```

Os números podem mudar e não devem ser fixados em scripts.

### KMS

Kernel Mode Setting controla conectores, modos, resoluções, CRTCs, planes e o
scanout para monitores. Ele permite console gráfico e oferece a base usada por
Xorg ou compositores Wayland.

KMS não cria janelas. Ele configura como buffers chegam ao monitor.

### Drivers de GPU

Perfis candidatos:

- Intel: i915 e drivers futuros compatíveis com a base escolhida;
- AMD: amdgpu e compatibilidade necessária;
- NVIDIA aberto: nouveau, condicionado a firmware e hardware;
- máquinas virtuais: virtio-gpu, QXL, VMware e Hyper-V conforme escopo;
- fallback de firmware/framebuffer: simpledrm e console compatível.

Cada driver deve ser módulo quando isso favorecer compatibilidade e manutenção.
Drivers built-in ficam restritos ao necessário para boot/console definido.

### dma-buf, fences e sincronização

Esses mecanismos permitem compartilhar buffers e coordenar acesso entre GPU,
display, vídeo e outros dispositivos. São necessários para stacks gráficos
modernos, mas não selecionam desktop nem protocolo de janelas.

### Input

O kernel fornece evdev e drivers HID para teclado, mouse, touchpad, touchscreen,
tablet e controles. `libevdev` e `libinput` permanecem no userspace.

### Console e recuperação

O kernel deve manter console legível antes e depois da carga do driver DRM. O
objetivo é permitir diagnóstico mesmo sem display manager ou desktop.

## 3. O que é retirado do conceito de kernel gráfico

| Componente | Motivo para ficar fora do kernel |
|---|---|
| XFCE | desktop userspace, depende de bibliotecas, sessão e aplicações |
| GNOME | GNOME Shell/Mutter são userspace e possuem ciclo próprio |
| KDE Plasma | Plasma/KWin/Qt/KDE Frameworks são userspace |
| X.Org | servidor gráfico userspace e protocolo X11 |
| Wayland | protocolo e bibliotecas userspace; compositor separado |
| Xwayland | servidor X userspace dentro de sessão Wayland |
| Labwc/Mutter/KWin | compositores e gerenciadores de janelas userspace |
| Mesa/libdrm | bibliotecas e drivers userspace que consomem DRM |
| LightDM/GDM/SDDM | autenticação e criação de sessões userspace |
| PipeWire/WirePlumber | mídia e política da sessão userspace |
| GTK/Qt | toolkits de aplicações userspace |

Nenhum desses itens deve aparecer no Kbuild, ser ligado ao `vmlinux`, entrar na
ABI interna do kernel ou ser iniciado pelo initramfs normal.

## 4. Configuração candidata do kernel

Os símbolos abaixo representam áreas a validar na fonte e configuração reais;
não afirmam que todas já estejam habilitadas:

```text
CONFIG_DRM
CONFIG_DRM_KMS_HELPER
CONFIG_DRM_FBDEV_EMULATION
CONFIG_DRM_SIMPLEDRM
CONFIG_DRM_I915
CONFIG_DRM_AMDGPU
CONFIG_DRM_NOUVEAU
CONFIG_DRM_VIRTIO_GPU
CONFIG_DRM_QXL
CONFIG_DRM_VMWGFX
CONFIG_DMA_SHARED_BUFFER
CONFIG_SYNC_FILE
CONFIG_INPUT
CONFIG_INPUT_EVDEV
CONFIG_VT
CONFIG_VT_CONSOLE
CONFIG_FRAMEBUFFER_CONSOLE
CONFIG_FW_LOADER
CONFIG_IOMMU_SUPPORT
```

O nome exato e a disponibilidade de símbolos variam entre versões. O processo
de build deve usar `scripts/config`, `olddefconfig` e auditoria do `.config`, não
apenas copiar esta lista.

## 5. Produto e pacotes

### Pacotes do kernel

```text
linux-image-<abi>-playos-graphics
linux-modules-<abi>-playos-graphics
linux-headers-<abi>-playos-graphics
linux-playos-graphics-meta
```

Responsabilidades:

- imagem contém somente o kernel;
- módulos contêm drivers correspondentes à mesma ABI;
- headers permitem módulos externos quando suportados;
- metapacote aponta para a ABI PlayOS atual;
- kernel anterior permanece disponível para rollback.

### Userspace mínimo separado

Um pacote opcional `playos-graphics-core` pode instalar ferramentas e
bibliotecas comuns sem desktop:

```text
libdrm
Mesa/EGL/OpenGL/Vulkan conforme perfil
libevdev/libinput
ferramentas de diagnóstico DRM/Mesa
regras udev mantidas pelos pacotes upstream
playos-graphicsctl
```

Esse pacote não é parte do `vmlinux`. Ele apenas permite usar e testar as
interfaces gráficas do kernel.

### Desktops opcionais

```text
playos-session-xfce
playos-session-gnome
playos-session-kde
```

Os três dependem de `playos-graphics-core` e do metapacote do kernel, nunca o
contrário. Assim, remover um desktop não remove o kernel e instalar um novo
desktop não exige recompilar o kernel.

## 6. Grafo correto de dependências

```text
linux-playos-graphics-meta
             ↑
playos-graphics-core
       ↑        ↑        ↑
    XFCE      GNOME     KDE
   opcional  opcional  opcional
```

O kernel não possui dependência sobre os pacotes acima dele. As setas indicam
que o userspace depende da base inferior.

## 7. Inicialização sem desktop

```text
UEFI
 ↓
GRUB
 ↓
linux-playos-graphics + initramfs
 ↓
drivers DRM/KMS, input e armazenamento
 ↓
systemd
 ↓
multi-user.target
 ↓
console de login
```

O primeiro gate do kernel gráfico termina no console. Não se instala display
manager e `graphical.target` não é requisito para validar o kernel.

Comandos de identificação:

```bash
uname -a
cat /proc/cmdline
systemctl get-default
ls -l /dev/dri
cat /sys/class/drm/card*/device/uevent
journalctl -b -k
```

## 8. Inicialização com userspace gráfico, mas sem desktop

Para teste, uma imagem de laboratório pode iniciar somente um compositor de
teste ou executar ferramentas DRM a partir do console. Isso valida KMS, EGL e
renderização sem confundir sucesso do kernel com sucesso de GNOME/KDE/XFCE.

Fluxo de laboratório:

```text
kernel gráfico → libdrm/Mesa → teste KMS/EGL → monitor
```

Ferramentas candidatas, fora da ISO final:

- `modetest` para recursos KMS;
- `drm_info` para propriedades DRM;
- `kmscube` para EGL/KMS;
- `glxinfo`, `eglinfo` e `vulkaninfo` quando os runtimes existirem;
- IGT GPU Tools para testes específicos, quando compatível.

Não executar testes que alterem modeset em uma sessão gráfica ativa sem
planejamento.

## 9. Initramfs

O initramfs contém apenas o necessário para localizar a raiz, carregar módulos
indispensáveis e permitir o boot. Um desktop não pertence ao initramfs.

Regras:

- ABI do kernel, `/lib/modules/<abi>` e initramfs devem coincidir;
- incluir driver gráfico cedo somente quando necessário para console, splash,
  criptografia visível ou requisito medido;
- firmware exigido pelo driver precisa estar disponível na fase correta;
- falha de GPU não pode impedir o boot em console quando houver fallback seguro;
- Plymouth, se usado, é userspace inicial e não parte do kernel.

## 10. Segurança

- render nodes recebem permissões pela política de sessão/udev, não `chmod 777`;
- interfaces debugfs não ficam expostas indiscriminadamente;
- módulos externos seguem política de assinatura/Secure Boot;
- firmware tem origem, versão e licença rastreáveis;
- parâmetros inseguros de IOMMU ou DRM não viram defaults sem evidência;
- o kernel não implementa autenticação gráfica nem política de desktop;
- acesso a dispositivos é mediado por logind/udev no userspace.

## 11. Desempenho

O kernel gráfico deve ser medido isoladamente antes de comparar desktops:

- tempo do firmware até console;
- tempo para carregar o driver DRM;
- erros e timeouts no journal;
- consumo de memória antes do desktop;
- modeset e detecção de conectores;
- estabilidade em suspend/resume;
- desempenho de transferência e sincronização sob testes reproduzíveis.

FPS de um desktop ou jogo não mede somente o kernel. Mesa, compositor,
aplicação, resolução, driver e hardware precisam ser controlados.

## 12. Compatibilidade de hardware

Perfis mínimos de validação:

| Perfil | Driver/caminho | Estado |
|---|---|---|
| Intel integrada | DRM Intel + Mesa posterior | pendente |
| AMD integrada/dedicada | amdgpu + firmware | pendente |
| NVIDIA aberta | nouveau + firmware/Mesa | pendente |
| NVIDIA proprietária | módulo externo e assinatura | pendente/separado |
| QEMU/KVM | virtio-gpu | pendente |
| VMware | vmwgfx | pendente |
| fallback UEFI | simpledrm/console | pendente |

“Driver compilado” não equivale a hardware validado.

## 13. Diagnóstico `playos-graphicsctl kernel`

A ferramenta proposta deve relatar sem depender de desktop:

```text
kernel_release
kernel_package
module_abi
gpu_pci_id
kernel_driver
firmware_status
drm_cards
render_nodes
connectors
active_modes
iommu_status
kernel_warnings
```

Subcomandos:

```text
playos-graphicsctl kernel status
playos-graphicsctl kernel drm
playos-graphicsctl kernel connectors
playos-graphicsctl kernel firmware
playos-graphicsctl kernel report --json
```

Nenhum deles requer XFCE, GNOME, KDE, Xorg ou Wayland.

## 14. Live ISO de validação do kernel

Antes da ISO desktop, criar uma ISO técnica pequena:

```text
kernel PlayOS gráfico
initramfs + live-boot
SquashFS/OverlayFS
systemd + console
firmware selecionado
playos-graphicsctl
ferramentas DRM em perfil de teste
sem XFCE, GNOME, KDE ou display manager
```

Objetivos:

- provar boot UEFI e fallback;
- descobrir GPU e carregar o driver;
- confirmar `/dev/dri` e conectores;
- coletar journal;
- testar console, desligamento e reboot;
- separar defeitos do kernel de defeitos do desktop.

Essa ISO não é a edição final de usuário.

## 15. Build proposto

1. identificar a fonte Linux e a configuração baseline;
2. criar fragmento `playos-graphics.config` mínimo e revisável;
3. aplicar `olddefconfig` e guardar o `.config` resultante;
4. comparar cada símbolo com o baseline;
5. compilar imagem, módulos e headers;
6. instalar em staging, sem escrever no host;
7. gerar pacotes `.deb` e initramfs coerentes;
8. executar análise de módulos e símbolos;
9. iniciar em QEMU até console;
10. produzir ISO técnica sem desktop;
11. testar hardware;
12. só depois conectar userspace e desktops opcionais.

## 16. Gates

| Gate | Evidência | Estado |
|---|---|---|
| KG0 | arquitetura sem desktop aprovada | presente |
| KG1 | fonte e ABI identificadas | pendente |
| KG2 | fragmento de configuração auditado | pendente |
| KG3 | kernel e módulos compilados | pendente |
| KG4 | pacotes `.deb` produzidos | pendente |
| KG5 | initramfs coerente | pendente |
| KG6 | boot até console em VM | pendente |
| KG7 | DRM/KMS e render node em VM | pendente |
| KG8 | ISO técnica inicializada | pendente |
| KG9 | suspend/resume e rollback | pendente |
| KG10 | Intel/AMD/NVIDIA/VMs testados | pendente |
| KG11 | userspace Mesa testado separadamente | pendente |

## 17. Critérios de aceitação

O kernel poderá ser chamado de “PlayOS Graphics Kernel” quando:

- inicializar sem qualquer desktop instalado;
- chegar ao console com ABI e módulos coerentes;
- detectar GPUs e criar interfaces DRM esperadas;
- manter console/fallback quando a aceleração falhar;
- suportar Mesa/Xorg/Wayland instalados posteriormente;
- não depender de XFCE, GNOME, KDE ou display manager;
- passar por rollback e por hardware representativo;
- possuir resultados reproduzíveis guardados.

Até esses gates, o estado é **arquitetura proposta de kernel gráfico sem
desktop**, não kernel gráfico PlayOS validado.

## 18. Relação com os desktops anteriormente documentados

XFCE, GNOME e KDE continuam possíveis produtos PlayOS, mas mudam de posição:

```text
antes: kernel/produto gráfico apresentado junto aos desktops
agora: kernel gráfico independente → userspace comum → desktop opcional
```

`ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md` passa a documentar somente
as camadas opcionais de desktop. Ela não define o conteúdo do kernel.

## Documentos relacionados

- `ARQUITETURA_PLAYOS_GRAPHICS_KERNEL_STACK_2026-08-26.md`;
- `MANUAL_COMPONENTES_BASE_PLAYOS_DESKTOP.md`;
- `ARQUITETURA_MULTI_DESKTOP_PLAYOS_XFCE_GNOME_KDE.md`;
- `INICIALIZACAO_PLAYOS_GRAPHICS_PLATFORM.md`.
