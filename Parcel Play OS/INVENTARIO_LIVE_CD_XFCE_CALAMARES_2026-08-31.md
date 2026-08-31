# Inventário da Live CD Noble + XFCE + Calamares

Data de verificação: 2026-08-31  
Tipo: `audit`  
Estado: `fact` para o manifesto; `implementation` para o perfil versionável  
Confiança: alta

## Escopo e fontes de verdade

Este documento descreve o que existe na primeira Live CD Ubuntu Noble + XFCE +
Calamares além do kernel e do ambiente XFCE.

A fonte primária do conteúdo instalado é o manifesto
`Live cd Xfce-calamares filesystem.packages`, extraído da ISO. Ele possui 1.110
linhas, uma por pacote binário instalado. A receita versionável fica em
`live-build/playos-graphics-core-noble/`.

Essas fontes não são equivalentes: o manifesto registra a ISO efetivamente
compilada; o perfil pode conter mudanças posteriores ainda não recompiladas.

## Resumo do sistema

- base: Ubuntu Noble 24.04;
- arquitetura: amd64;
- kernel da ISO auditada: `linux-image-6.8.0-138-generic`;
- desktop Live: XFCE 4.18;
- instalador presente: Calamares 3.3.5;
- infraestrutura Live presente: `live-boot`, `live-config` e `live-tools`;
- display manager: LightDM com greeter GTK;
- quantidade do manifesto: 1.110 pacotes.

## Boot e sessão Live

O conjunto `live-boot` localiza e monta o filesystem comprimido da mídia. O
`live-config` configura a sessão efêmera, usuário, locale e demais parâmetros de
inicialização. `live-tools` acrescenta utilitários próprios do ambiente Live.

GRUB fornece os componentes de boot por BIOS e UEFI por meio de pacotes como
`grub-pc-bin` e `grub-efi-amd64-bin`. A existência dos pacotes é `fact`; boot
bem-sucedido em todas as máquinas continua dependendo de teste de runtime.

## Instalador e armazenamento

O Calamares 3.3.5 é o instalador gráfico disponível pelo menu do XFCE. A Live
também inclui ferramentas usadas por instalação e manutenção de discos:

- `parted` para particionamento;
- `dosfstools` para FAT/EFI;
- `e2fsprogs` para ext2/ext3/ext4;
- `btrfs-progs` para Btrfs;
- `rsync` para cópia de árvores;
- `squashfs-tools` para imagens SquashFS;
- UDisks2 para acesso a volumes pela sessão gráfica.

Presença no manifesto não comprova que o fluxo completo de instalação foi
concluído com sucesso.

### Correção: Casper, Subiquity e Curtin

O manifesto desta primeira ISO **não contém** pacotes chamados `casper`,
`subiquity-server` ou `curtin`. Eles aparecem na lista de pacotes do perfil
versionável atual, resultado de trabalho posterior de integração híbrida.

Portanto:

- primeira ISO compilada: `live-boot` + Calamares;
- receita atual posterior: solicita adicionalmente Casper, Subiquity e Curtin;
- uma nova compilação precisa gerar novo manifesto para determinar quais deles
  foram realmente resolvidos e instalados.

Não se deve usar a receita atual para reescrever retroativamente o conteúdo da
ISO histórica.

## Pilha gráfica

Além do XFCE, a imagem reúne uma plataforma gráfica compartilhada:

- X.Org/X11, incluindo `xserver-xorg`;
- Xwayland para aplicativos X11 sobre Wayland;
- Wayland e protocolos associados;
- Labwc como compositor Wayland técnico;
- Mesa e libdrm para renderização e acesso DRM;
- OpenGL e Vulkan, incluindo loader e drivers Mesa;
- ferramentas X11 e utilitários de diagnóstico gráfico.

Esses componentes são userspace, exceto as interfaces e drivers DRM/KMS do
kernel. Eles não fazem parte do binário do kernel.

## Login, autorização e IPC

- LightDM gerencia o login e o autologin da conta Live;
- `lightdm-gtk-greeter` fornece a tela gráfica;
- systemd inicia e supervisiona os serviços;
- D-Bus fornece comunicação entre processos;
- PolicyKit controla operações administrativas solicitadas pela sessão;
- `dbus-user-session` fornece o barramento da sessão do usuário.

## Rede, energia e dispositivos

- NetworkManager administra Ethernet, Wi-Fi e perfis de rede;
- UPower expõe bateria e energia ao desktop;
- UDisks2 integra discos e mídias removíveis;
- `libinput` e componentes relacionados tratam teclado, mouse e touchpad;
- `pciutils` e `usbutils` inventariam hardware PCI e USB;
- `kmod` administra módulos do kernel.

A disponibilidade do pacote ou driver não garante compatibilidade com todo
hardware.

## Áudio

A Live utiliza ALSA no nível de dispositivos e PipeWire no userspace, com
WirePlumber como gerenciador de sessão/políticas. O conjunto fornece a base para
áudio de aplicativos, Bluetooth e compatibilidade PulseAudio quando os plugins
e serviços correspondentes estão ativos.

## Fontes e texto

Fontconfig, FreeType, HarfBuzz e conjuntos de fontes como Noto/DejaVu cuidam de
descoberta, rasterização e composição de texto. Esses componentes atendem XFCE,
aplicativos X11/Wayland, navegador e instalador.

## Integração XDG

O sistema inclui utilitários e padrões XDG para:

- arquivos `.desktop` e menu de aplicações;
- tipos MIME;
- diretórios do usuário;
- abertura de URLs e arquivos pelo aplicativo padrão;
- portais usados por aplicações isoladas e sessões Wayland.

É por essa camada que o lançador `Instalar PlayOS` aparece no menu do XFCE e
executa o wrapper do Calamares.

## Firmware e CPU

A imagem contém `linux-firmware`, microcódigo Intel e microcódigo AMD, além de
`linux-modules` e `linux-modules-extra` correspondentes ao kernel. Esses itens
ampliam a cobertura de hardware, mas precisam ser validados por boot e testes
em cada equipamento-alvo.

## Utilitários gerais

Entre as ferramentas disponíveis estão terminal XFCE, XTerm, Thunar, `curl`,
`nano`, `less`, `procps`, `7zip`, ferramentas de certificados e utilitários
básicos GNU/Linux. Locales e configuração de console permitem o perfil
`pt_BR.UTF-8` e teclado brasileiro definido no boot.

## Branding PlayOS

O perfil inclui identidade visual, wallpaper, arquivos de release, branding do
Calamares e o lançador de instalação PlayOS. Branding não altera a identidade
técnica da base: esta ISO continua sendo uma composição Ubuntu Noble.

## Estado de validação

- `fact`: os 1.110 registros e versões presentes no manifesto;
- `fact`: Calamares, `live-boot`, XFCE, LightDM e kernel Noble aparecem no
  manifesto;
- `fact`: Casper, Subiquity e Curtin não aparecem nesse manifesto;
- `implementation`: existe uma receita `live-build` versionável;
- `result`: a ISO e sua estrutura foram auditadas estaticamente em tarefas
  anteriores;
- `unknown`: instalação completa bem-sucedida pelo Calamares;
- `unknown`: cobertura real de hardware;
- `unknown`: resultado de uma recompilação usando o perfil híbrido atual.

## Referências locais

- `Live cd Xfce-calamares filesystem.packages`;
- `live-build/playos-graphics-core-noble/`;
- `LIVE_ISO_NOBLE_XFCE_SOBRE_GRAPHICS_CORE_2026-08-27.md`;
- `LIVE_ISO_NOBLE_GRAPHICS_CORE_CALAMARES_2026-08-27.md`;
- `RECRIAR_PRIMEIRA_ISO_CALAMARES_XFCE.md`.

